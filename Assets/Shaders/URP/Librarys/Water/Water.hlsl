#ifndef WATER_INCLUDED
#define WATER_INCLUDED

#include "../../Librarys/Common/Common.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
#include "Water_Maps.hlsl"
#include "Water_Properties.hlsl"

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
    OUT.color = IN.color;
    
    return OUT;
}


///////////////////////////////////////////////////////////////////////////////
//                      Fragment                                             //
///////////////////////////////////////////////////////////////////////////////

float4 Frag(Varyings IN) : SV_TARGET
{
    float4 waterColor = WaterColor(IN.normalWS,IN.viewDirectionWS,IN.positionHCS,IN.positionWS);
    float2 normalUV = IN.uv * _NormalMap_ST.xy + _NormalMap_ST.zw;
    float3 normalTS = SurfaceNormal(normalUV);
    float3 normalWS = TranformNormalTangentToWorld(normalTS,IN.normalWS,IN.tangentWS);
    float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz; //场景中的环境光
    float3 lightDirWS = half3(_MainLightPosition.xyz);     //光照方向
    float3 diffuse = _MainLightColor.rgb * _DiffuseColor * saturate(dot(normalWS,lightDirWS)); //漫反射光照
    
    //计算高光Blinn光照模型--避免计算光线反射(比较耗时）
    float3 viewDirWS = normalize(GetWorldSpaceViewDir(IN.positionWS));
    float3 halfDir = normalize(lightDirWS + viewDirWS); //半程向量
    float3 specular = _MainLightColor.rgb * _SpecularColor*pow(saturate(dot(normalWS,halfDir)),1);
                
    float3 blinnPhongColor = ambient + diffuse  + specular;
    waterColor.rgb *= blinnPhongColor;
    return waterColor;
}


#endif