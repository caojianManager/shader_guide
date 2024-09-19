#ifndef WATER_INCLUDED
#define WATER_INCLUDED

#include "../../Librarys/Common/Common.hlsl"
#include "../../Librarys/Common/PBRCommon.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
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

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 8);
#ifdef DYNAMICLIGHTMAP_ON
    float2  dynamicLightmapUV : TEXCOORD9;
#endif

	UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

////////////////////////////////////////////////////////////////////////////////////////////
///                                 Water Color                                         ///
///////////////////////////////////////////////////////////////////////////////////////////

//从深度纹理重建像素的世界空间位置
//https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@11.0/manual/writing-shaders-urp-reconstruct-world-position.html
float3 ReconstructWorldPositionFromDepth(float2 positionHCS)
{
    float2 UV = positionHCS.xy / _ScaledScreenParams.xy;
    #if UNITY_REVERSED_Z
        real depth=SampleSceneDepth(UV);
    #else
        // Adjust Z to match NDC for OpenGL ([-1, 1])
        real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(UV));
    #endif
    // Reconstruct the world space positions.
    return ComputeWorldSpacePosition(UV, depth, UNITY_MATRIX_I_VP);
}

float GetWaterDepth(float positionWS_Y, float reconstructPositionWS_Y_FromDepth)
{
    return positionWS_Y - reconstructPositionWS_Y_FromDepth;
}

float4 WaterColor(float3 normalWS, float3 viewDirectionWS,float4 positionHCS,float3 positionWS)
{
     //计算WaterColor
    float waterDepth = GetWaterDepth(positionWS.y, ReconstructWorldPositionFromDepth(positionHCS).y);
    float depthLerp = clamp(exp(-waterDepth/_DeepRange),0,1);
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
    float2 normalSpeedXY = float2(_NormalSpeed.x - 10,_NormalSpeed.y);
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
   return clamp(_ReflectIntensity*FresnelEffect(normalWS,viewDir,_FresnelPower),0,1);
}

///////////////////////////////////////////////////////////////////////////////
//                     UnderWaterColor                                       //
///////////////////////////////////////////////////////////////////////////////


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
    OUT.uv = IN.uv;
    OUT.viewDirectionWS = (GetWorldSpaceViewDir(OUT.positionWS));

    OUT.tangentWS = float4(TransformObjectToWorldDir(IN.tangentOS.xyz), IN.tangentOS.w);
    OUT.viewDirectionTS = GetViewDirectionTangentSpace(OUT.tangentWS, OUT.normalWS, OUT.viewDirectionWS);
    OUTPUT_LIGHTMAP_UV(IN.staticLightmapUV, unity_LightmapST, OUT.staticLightmapUV);
#ifdef DYNAMICLIGHTMAP_ON
    OUT.dynamicLightmapUV = IN.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif
    OUTPUT_SH(OUT.normalWS.xyz, OUT.vertexSH);

    OUT.color = IN.color;
    
    return OUT;
}

///////////////////////////////////////////////////////////////////////////////
//                      Fragment                                             //
///////////////////////////////////////////////////////////////////////////////

//PBR-材质基础颜色
struct MaterialData
{
    float4 albedoAlpha;              //基础颜色-数值
    float3 normalTS;
    float metalness;                //金属度
    float perceptualRoughness;      //粗糙度
    float occlusion;                //AO
    float3 emission;
    float specularity;              //镜面值
};

void InitializeMaterialData(Varyings IN,out MaterialData mat)
{
    float4 waterColor = WaterColor(IN.normalWS,IN.viewDirectionWS,IN.positionHCS,IN.positionWS);
    float2 normalUV = IN.uv * _NormalMap_ST.xy + _NormalMap_ST.zw;
    float3 normalTS = SurfaceNormal(normalUV);
    normalTS = ReflectNormalLerp(normalTS);
    normalTS = normalize(normalTS);

    mat.albedoAlpha = waterColor;
    mat.normalTS = normalTS;
    mat.emission =  float3(0,0,0);
    mat.metalness = 0;
    mat.occlusion = GetOcclusion(IN.normalWS,IN.viewDirectionWS);
    mat.perceptualRoughness = 0.05;
    mat.specularity = 1;
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
    
    
    ///////////////////////////////
    //   SETUP                   //
    ///////////////////////////////

    // Setup Normals
    IN.normalWS = NormalTangentToWorld(mat.normalTS, IN.normalWS, IN.tangentWS);
    IN.normalWS = normalize(IN.normalWS);
    
    // Setup View direction
    IN.viewDirectionWS = normalize(IN.viewDirectionWS);
    float2 normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.positionHCS);

    
    ///////////////////////////////
    //   LIGHTING                //
    ///////////////////////////////

    Light mainLight;
    float4 shadowMask = SAMPLE_SHADOWMASK(IN.staticLightmapUV);
    GetMainLightData(IN.positionWS, shadowMask, mainLight);
    
    // Albedo
    float3 albedo = mat.albedoAlpha.rgb;
    float3 emission = mat.emission;
    // Occlusion
    float occlusion = mat.occlusion;
    // Roughness
    float perceptualRoughness = mat.perceptualRoughness;
    // Metalness
    float metalness = mat.metalness;
    float specularity = mat.specularity;
    float subsurfaceThickness = 1;
    
    // Lighting--固定接受阴影
    // if(_ReceiveShadowsEnabled == 0)
    // {
    //     mainLight.shadowAttenuation = 1;
    // }

    float3 lightingModel;
    float NoV, NoL, NoH, VoH, VoL, LoH;

    NoV = dot01(IN.normalWS, IN.viewDirectionWS);
    
    ///////////////////////////////
    //   CALCULATE COLOR         //
    ///////////////////////////////

// Apply Decals to Albedo
#if defined(_DBUFFER)
    ApplyDecalToBaseColor(IN.positionHCS, albedo);
#endif

    // BRDF
    BRDF brdf;
    brdf.diffuse = 0;
    brdf.specular = 0;
    brdf.subsurface = float3(0,0,0);

    float3 f0 = F0(albedo, specularity, metalness);
    
    EvaluateLighting(albedo, specularity, perceptualRoughness, metalness, subsurfaceThickness, f0, NoV, IN.normalWS, IN.viewDirectionWS, mainLight, brdf);
    GetAdditionalLightData(albedo, specularity, perceptualRoughness, metalness, subsurfaceThickness, f0, NoV, normalizedScreenSpaceUV, IN.positionWS, IN.normalWS, IN.viewDirectionWS, brdf);
    
    
    // IBL
    LightInputs lightInputs = GetLightInputs(IN.normalWS, IN.viewDirectionWS, mainLight.direction);
    OcclusionData occlusionData = GetAmbientOcclusionData(GetNormalizedScreenSpaceUV(IN.positionHCS));
    ApplyDirectOcclusion(occlusionData, brdf);

    float3 bakedGI;
    #if defined(DYNAMICLIGHTMAP_ON)
    bakedGI = SAMPLE_GI(IN.staticLightmapUV, IN.dynamicLightmapUV, IN.vertexSH, IN.normalWS);
    #else
    bakedGI = SAMPLE_GI(IN.staticLightmapUV, IN.vertexSH, IN.normalWS);
    #endif
    
    MixRealtimeAndBakedGI(mainLight, IN.normalWS, bakedGI);
    
    float indirectSpecularOcclusion = lerp(1, (NoV + 1.0) * 0.5, perceptualRoughness);
    float fresnel = Fresnel(f0, NoV, perceptualRoughness).x;
    
    float3 indirectSpecular = GetReflection(IN.viewDirectionWS, IN.normalWS, IN.positionWS, perceptualRoughness, normalizedScreenSpaceUV) * (1.0 - perceptualRoughness) * indirectSpecularOcclusion;
    float3 indirectDiffuse = bakedGI * albedo * lerp(1, 0, metalness);
    brdf.specular += indirectSpecular * occlusionData.indirect * occlusion * lerp(1.0, albedo, metalness * (1.0 - fresnel)) * lerp(fresnel, 1.0, metalness);
    brdf.diffuse += indirectDiffuse * occlusionData.indirect * occlusion;
    return float4(brdf.diffuse + indirectSpecular,mat.albedoAlpha.a);
    //最终输出的颜色 漫反射 + 镜面反射
    float3 color = (brdf.diffuse + brdf.specular);
    // Subsurface Lighting
    color += brdf.subsurface;
    // Emission
    color += emission;
    
    // Mix Fog
    // if (_ReceiveFogEnabled == 1)
    // {
    //     float fogFactor = InitializeInputDataFog(float4(IN.positionWS, 1), 0);
    //     color = MixFog(color, fogFactor);
    // }
    
    return float4(color, mat.albedoAlpha.a);
}

#endif