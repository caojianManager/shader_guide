#ifndef WATER_INCLUDED
#define WATER_INCLUDED

#include "../../Librarys/Common/Common.hlsl"
#include "../../Librarys/Common/Lighting.hlsl"

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Water_Maps.hlsl"
#include "Water_Properties.hlsl"

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
///                                                                           ///
///                      SHADER BODY                                          ///
///                                                                           ///
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

//顶点数据结构
struct Attributes
{
    float4 positionOS         : POSITION;
    float3 normalOS           : NORMAL;
    float4 tangentOS          : TANGENT;
    float3 color              : COLOR;
    float2 uv                 : TEXCOORD0;
    float2 staticLightmapUV   : TEXCOORD1;
    float2 dynamicLightmapUV  : TEXCOORD2;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionHCS     : SV_POSITION;
    float2 uv              : TEXCOORD0;
    float3 positionWS      : TEXCOORD1;
    float3 normalWS        : TEXCOORD2;
    float3 viewDirectionWS : TEXCOORD3;
    float4 tangentWS       : TEXCOORD4;
    float3 viewDirectionTS : TEXCOORD5;
    float3 color           : TEXCOORD6;
    float4 clipPosition    : TEXCOORD7;
	UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

struct BRDF
{
    float3 diffuse;
    float3 specular;
    float3 subsurface;
};

////////////////////////////////////////////////////////////////////////////////////////////
///                                 Water Color                                         ///
///////////////////////////////////////////////////////////////////////////////////////////

float GetWaterDepth(float positionWS_Y, float reconstructPositionWS_Y_FromDepth)
{
    return positionWS_Y - reconstructPositionWS_Y_FromDepth;
}

float4 WaterColor(float3 normalWS, float3 viewDirectionWS,float4 positionHCS,float3 positionWS,float3 reconstructPositionWSFromDepth)
{
    float waterDepth = GetWaterDepth(positionWS.y,reconstructPositionWSFromDepth.y);
    float depthLerp = clamp(exp(-waterDepth/(_DeepRange * 0.2)),0,1);
    float4 waterColor = lerp(_DeepColor, _ShallowColor,depthLerp);
    float fresnelLerp = Fresnel(normalWS,normalize(viewDirectionWS),_FresnelPower);//菲尼系数-水平面颜色
    waterColor = lerp(waterColor, _FresnelColor,fresnelLerp);
    return waterColor;
}

////////////////////////////////////////////////////////////////////////////////////////////
///                                 SurfaceNormal                                        ///
///////////////////////////////////////////////////////////////////////////////////////////

float3 BlendNormals(float3 n1, float3 n2)
{
	return normalize(half3(n1.xy + n2.xy, n1.z * n2.z));
}

float3 NormalBlendReoriented(float3 A, float3 B)
{
	float3 t = A.xyz + float3(0.0, 0.0, 1.0);
	float3 u = B.xyz * float3(-1.0, -1.0, 1.0);
	return (t / t.z) * dot(t, u) - u;
}

float3 SurfaceNormal(float2 uv)
{
    float2 normalSpeedXY = float2(_NormalSpeed.x,_NormalSpeed.y);
    float2 normalMapUV1 = uv + normalSpeedXY * _Time.y * 0.01;
    float2 normalMapUV2 = uv*2 - 0.5 * normalSpeedXY * _Time.y * 0.01;
    float4 normalMap1 = SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,normalMapUV1);
    float4 normalMap2 = SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,normalMapUV2);
    float3 blendNormals = NormalBlendReoriented(UnpackNormal(normalMap1),UnpackNormal(normalMap2));
    return saturate(blendNormals * _NormalScale);
}

///////////////////////////////////////////////////////////////////////////////
//                     RefletColor (反射--反射探针)                            //
///////////////////////////////////////////////////////////////////////////////

float3 ReflectNormalLerp(float3 surfaceNormal)
{
    return lerp(float3(0,0,1),surfaceNormal,_ReflectDistortion);
}

float GetOcclusion(float3 normalWS,float3 viewDir)
{
    float fresnel = pow(max(1-dot(normalize(normalWS),normalize(viewDir)),0.0001), _ReflectPower);
    return clamp(_ReflectIntensity*fresnel,0,1);
}

float3 GetEnvironmentReflection(float3 viewDirectionWS, float3 normalWS,float3 positionWS)
{
    float occulsion = GetOcclusion(normalWS,viewDirectionWS);
    float3 reflection = reflect(-viewDirectionWS, normalWS);
    return GlossyEnvironmentReflection(half3(reflection), positionWS, 0.05, half(occulsion));
}

///////////////////////////////////////////////////////////////////////////////
//                     UnderWaterColor                                       //
///////////////////////////////////////////////////////////////////////////////

float4 UnderWaterColor(float3 surfaceNormal,float4 clipPosition)
{
    float4 grabScreenPosition = ComputeGrabScreenPos(ComputeScreenPos(clipPosition)); //
    grabScreenPosition = grabScreenPosition / grabScreenPosition.w;
    float3 normalDistort = surfaceNormal*_UnderWaterDistort*0.01;
    float3 grabScreenColorUV = (grabScreenPosition + normalDistort).xyz;
    float4 underWaterColor = float4(SHADERGRAPH_SAMPLE_SCENE_COLOR(grabScreenColorUV),1.0);
    return underWaterColor;
}

///////////////////////////////////////////////////////////////////////////////
//                     Caustics Color                                       //
///////////////////////////////////////////////////////////////////////////////

float4 CausticsColor(float3 reconstructPositionWSFromDepth,float3 positionWS)
{
    float waterDepth = GetWaterDepth(positionWS.y,reconstructPositionWSFromDepth.y);
    float2 causticsSpeed = float2(_CausticsSpeed.x - 8,_CausticsSpeed.y);
    float2 causticsMapUV1 = (reconstructPositionWSFromDepth.xz / _CausticsScale) + (causticsSpeed * _Time.y * 0.001);
    float2 causticsMapUV2 = -1*(reconstructPositionWSFromDepth.xz / _CausticsScale) + (causticsSpeed * _Time.y * 0.001);
    float4 causticsMap1 = SAMPLE_TEXTURE2D(_CausticsMap,sampler_CausticsMap,causticsMapUV1);
    float4 causticsMap2 = SAMPLE_TEXTURE2D(_CausticsMap,sampler_CausticsMap,causticsMapUV2);
    float4 causticsMap = min(causticsMap1,causticsMap2) * _CausticsIntensity;
    float causticsMask = clamp(exp(-waterDepth/_CausticsRange),0,1);
    return causticsMap * causticsMask;
}

///////////////////////////////////////////////////////////////////////////////
//                      Vertex                                               //
///////////////////////////////////////////////////////////////////////////////

Varyings Vert(Attributes IN)
{
    Varyings OUT = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(IN);
    UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
    VertexPositionInputs position_inputs = GetVertexPositionInputs(IN.positionOS);
    OUT.positionWS = position_inputs.positionWS;
    OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
    OUT.normalWS = normalize(OUT.normalWS);
    OUT.positionHCS = position_inputs.positionCS;
    OUT.clipPosition = position_inputs.positionCS;      //注意SV_POSITION,TEXCOORD寄存器存储的值(PositionCS)不一致。
    OUT.uv = IN.uv;
    OUT.viewDirectionWS = (GetWorldSpaceViewDir(OUT.positionWS));

    OUT.tangentWS = float4(TransformObjectToWorldDir(IN.tangentOS.xyz), IN.tangentOS.w);
    OUT.viewDirectionTS = GetViewDirectionTangentSpace(OUT.tangentWS, OUT.normalWS, OUT.viewDirectionWS);
    
    OUT.color = IN.color;
    return OUT;
}

///////////////////////////////////////////////////////////////////////////////
//                      Fragment                                             //
///////////////////////////////////////////////////////////////////////////////

//PBR-材质基础颜色
struct MaterialData
{
    float4 albedoAlpha;             //水的基础颜色
    float4 underWaterColor;         //水底颜色
    float3 normalTS;
};

void InitializeMaterialData(Varyings IN,out MaterialData mat)
{
    float3 reconstructPositionWSFromDepth = ReconstructWorldPositionFromDepth(IN.clipPosition,IN.viewDirectionWS);
    
    //计算WaterColor
    float4 waterColor = WaterColor(IN.normalWS,IN.viewDirectionWS,IN.positionHCS,IN.positionWS,reconstructPositionWSFromDepth);
    mat.albedoAlpha = waterColor;
    float2 normalUV = IN.uv * _NormalMap_ST.xy + _NormalMap_ST.zw;
    float3 normalTS = SurfaceNormal(normalUV);
    mat.normalTS = ReflectNormalLerp(normalTS);

    //水底
    float4 underWater = UnderWaterColor(normalTS,IN.clipPosition);
    mat.underWaterColor = underWater;
    //焦散
    float4 causticsColor = CausticsColor(reconstructPositionWSFromDepth,IN.positionWS);
    mat.underWaterColor += causticsColor;
    
}

float2 GetBlendFactors(float height1, float a1, float height2, float a2)
{
    float depth = 0.2;
    float ma = max(height1 + a1, height2 + a2) - depth;
    
    float b1 = max(height1 + a1 - ma, 0);
    float b2 = max(height2 + a2 - ma, 0);
    float b3 = max(rcp(b1 + b2), 1e-7);
    return float2(b1 * b3, b2 * b3);
}

float4 Frag(Varyings IN) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(IN);  // --- 仅当要在片元着色器中访问任何实例化属性时才需要
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
    #ifdef LOD_FADE_CROSSFADE
        LODFadeCrossFade(IN.positionHCS);
    #endif
    MaterialData mat;
    InitializeMaterialData(IN,mat);
    // Setup Normals
    IN.normalWS = TranformNormalTangentToWorld(mat.normalTS, IN.normalWS, IN.tangentWS);
    IN.normalWS = normalize(IN.normalWS);
    // Setup View direction
    IN.viewDirectionWS = normalize(IN.viewDirectionWS);
    
    //Lighting
    Light mainLight;
    float4 shadowMask = SAMPLE_SHADOWMASK(IN.staticLightmapUV);
    mainLight = GetMainLightData(IN.positionWS, shadowMask);
    float3 specular = GetEnvironmentReflection(IN.viewDirectionWS,IN.normalWS,IN.positionWS);
    specular += GetLightSpecular(float3(1,1,1),mainLight,IN.viewDirectionWS,IN.normalWS,_GlossPower*10);
    float3 color = lerp(mat.albedoAlpha + specular,mat.underWaterColor,1 - mat.albedoAlpha.a);
    return float4(color,mat.albedoAlpha.a);
}

#endif