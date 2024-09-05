#ifndef PBRCOMMON_INCLUDED
#define PBRCOMMON_INCLUDED

///////////////////////////////////////////////////////////////////////////////
//                      Includes                                             //
///////////////////////////////////////////////////////////////////////////////

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

#if defined(LOD_FADE_CROSSFADE)
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif


///////////////////////////////////////////////////////////////////////////////
//                      Helper Functions                                     //
///////////////////////////////////////////////////////////////////////////////

half InverseLerp(half a, half b, half v)
{
    return (v - a) / (b - a);
}

half RemapUnclamped(half iMin, half iMax, half oMin, half oMax, half v)
{
    half t = InverseLerp(iMin, iMax, v);
    return lerp(oMin, oMax, t);
}

half Remap(half iMin, half iMax, half oMin, half oMax, half v)
{
    v = clamp(v, iMin, iMax);
    return RemapUnclamped(iMin, iMax, oMin, oMax, v);
}

float CheapSqrt(float a)
{
    return 1.0 - ((1.0 - a) * (1.0 - a));
}

/**
 *saturate 函数---saturate(x)的作用是如果x取值小于0，则返回值为0。如果x取值大于1，则返回值为1。若x在0到1之间，则直接返回x的值。
 *float saturate(float x)
 *{
 *    return max(0.0, min(1.0, x));
 *}
 *
 *dot函数---计算两个向量的点乘
*/
float dot01(float3 a, float3 b)
{
    return saturate(dot(a, b));
}

float luminance(float3 c)
{
    return dot(c, float3(0.2126, 0.7152, 0.0722));
}

///////////////////////////////////////////////////////////////////////////////
//                      Structs                                              //
///////////////////////////////////////////////////////////////////////////////

struct LightInputs
{
    float NoL;
    float NoH;
    float VoH;
    float VoL;
    float LoH;
};

LightInputs GetLightInputs(float3 normalWS, float3 viewDirectionWS, float3 lightDirection)
{
    LightInputs inputs;

    float3 H = normalize(lightDirection + viewDirectionWS);
    inputs.NoL = dot01(normalWS, lightDirection);
    inputs.NoH = dot01(normalWS, H);
    inputs.VoH = dot01(viewDirectionWS, H);
    inputs.VoL = dot01(viewDirectionWS, lightDirection);
    inputs.LoH = dot01(lightDirection, H);
    return inputs;
}

// //BRDF - 双向反射分布函数
struct BRDF
{
    float3 diffuse;
    float3 specular;
    float3 subsurface;
};

// ///////////////////////////////////////////////////////////////////////////////
// //                      Lighting Transforms                                  //
// ///////////////////////////////////////////////////////////////////////////////

// Transforms
float3 _LightDirection;
float3 _LightPosition;

float4 GetClipSpacePosition(float3 positionWS, float3 normalWS)
{
#if defined(CAST_SHADOWS_PASS)

#if _CASTING_PUNCTUAL_LIGHT_SHADOW
    float3 lightDirectionWS = normalize(_LightPosition - positionWS);
#else
    float3 lightDirectionWS = _LightDirection;
#endif

float4 positionHCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

#if UNITY_REVERSED_Z
    positionHCS.z = min(positionHCS.z, positionHCS.w * UNITY_NEAR_CLIP_VALUE);
#else
    positionHCS.z = max(positionHCS.z, positionHCS.w * UNITY_NEAR_CLIP_VALUE);
#endif

    return positionHCS;
#endif

    return TransformWorldToHClip(positionWS);
}

float4 GetMainLightShadowCoord(float3 positionWS, float4 positionHCS)
{
#if defined(_MAIN_LIGHT_SHADOWS_SCREEN)
    return ComputeScreenPos(positionHCS);
#else
    return TransformWorldToShadowCoord(positionWS);
#endif
}

float4 GetMainLightShadowCoord(float3 PositionWS)
{
#if defined(_MAIN_LIGHT_SHADOWS_SCREEN)
    float4 clipPos = TransformWorldToHClip(PositionWS);
    return ComputeScreenPos(clipPos);
#else
    return TransformWorldToShadowCoord(PositionWS);
#endif
}

//获取主光源信息
void GetMainLightData(float3 PositionWS, float4 shadowMask, out Light light)
{
    float4 shadowCoord = GetMainLightShadowCoord(PositionWS);
    light = GetMainLight(shadowCoord, PositionWS, shadowMask);
}

///////////////////////////////////////////////////////////////////////////////
//                      Lighting Functions                                   //
///////////////////////////////////////////////////////////////////////////////

float SchlickFresnel(float input)
{
    float v = saturate(1.0 - input);
    float v5 = v * v * v * v * v;
    return v5;
}

float3 F0(float3 albedo, float specularity, float metalness)
{
    float3 f0 = specularity.xxx;
    return f0;
    //下面这种计算方式 -- 对于金属来讲，Albedo就是FO的颜色，对于塑料来讲 FO就是Specular的颜色
    return lerp(f0, albedo, metalness);
}

//F项菲涅尔项(Specular F) : Schlick Frenel ---->F为菲涅尔反射系数
float3 Fresnel(float3 f0, float cosTheta, float roughness)
{
    return f0 + (max(1.0 - roughness, f0) - f0) * SchlickFresnel(cosTheta);
}

float FD90(float roughness, float LoH)
{
    return 0.5 + (2.0 * roughness * LoH * LoH);
}

//BRDF - 迪士尼-->漫反射模型公式
float3 GetDiffuse(float3 baseColor, float perceptualRoughness, float LoH, float NoL, float NoV)
{
    return (baseColor / PI) * (1.0 + (FD90(perceptualRoughness, LoH) - 1.0) * SchlickFresnel(NoL)) * (1.0 + (FD90(perceptualRoughness, LoH) - 1.0) * SchlickFresnel(NoV));
}

//法线分布项D(Specular D): GTR  --->D为微平面分布函数
float3 NDF(float3 f0, float perceptualRoughness, float NoH)
{
    float a2 = perceptualRoughness * perceptualRoughness;
    float NoH2 = NoH * NoH;
    float c = (NoH2 * (a2 - 1.0)) + 1.0;
    return max(f0 / (PI * c * c), 1e-7);
}

//几何项(Specualr G): Smith - GGX --->G为几何衰减/阴影项(shadowing factor)
float GSF(float NoL, float NoV, float perceptualRoughness)
{
    float a = perceptualRoughness * 0.5;
    float l = NoL / (NoL * (1 - a) + a);
    float v = NoV / (NoV * (1 - a) + a);
    return max(l * v, 1e-7);
}

struct OcclusionData
{
    float indirect;
    float direct;
};

OcclusionData GetAmbientOcclusionData(float2 ScreenPosition)
{
    OcclusionData occlusionData = (OcclusionData)0;
    occlusionData.indirect = 1;
    occlusionData.direct = 1;
#if defined(_SCREEN_SPACE_OCCLUSION)
    AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(ScreenPosition);
    occlusionData.indirect = aoFactor.indirectAmbientOcclusion;
    occlusionData.direct = aoFactor.directAmbientOcclusion;
#endif
    return occlusionData;
}

void ApplyDirectOcclusion(OcclusionData occlusionData, inout BRDF brdf)
{
    brdf.diffuse *= occlusionData.direct;
    brdf.specular *= occlusionData.direct;
}

void EvaluateLighting(float3 albedo, float specularity, float perceptualRoughness, float metalness, float subsurfaceThickness, float3 f0, float NoV, float3 normalWS, float3 viewDirectionWS, Light light, inout BRDF brdf)
{
    LightInputs inputs = GetLightInputs(normalWS, viewDirectionWS, light.direction);

    //漫反射
    float3 diffuse = GetDiffuse(albedo, perceptualRoughness, inputs.LoH, inputs.NoL, NoV);

    //镜面反射
    float3 ndf = NDF(f0, perceptualRoughness, inputs.NoH);
    float3 fresnel = Fresnel(f0, inputs.VoH, perceptualRoughness);
    float gsf = GSF(inputs.NoL, NoV, perceptualRoughness);
    float3 specular = (fresnel * ndf * gsf) / ((4.0 * inputs.NoL * NoV) + 1e-7);

    specular = clamp(specular, 0, 10.0);
    diffuse = lerp(diffuse, 0.0, metalness); //漫反射 -->金属为0，非金属为diffuse;

    //最终 漫反射和镜面反射加上环境光照。
    float3 lighting = inputs.NoL * light.color * light.shadowAttenuation * light.distanceAttenuation * PI;
    brdf.diffuse += diffuse * lighting;
    brdf.specular += specular * lighting * inputs.NoL * albedo;
}


void GetAdditionalLightData(float3 albedo, float specularity, float perceptualRoughness, float metalness, float subsurfaceThickness, float3 f0, float NoV, float2 normalizedScreenSpaceUV, float3 positionWS, float3 normalWS, float3 viewDirectionWS, inout BRDF brdf)
{
    #if defined(_ADDITIONAL_LIGHTS)
    uint count = GetAdditionalLightsCount();
    uint meshRenderingLayers = GetMeshRenderingLayer();
    
#if USE_FORWARD_PLUS

    ClusterIterator clusterIterator = ClusterInit(normalizedScreenSpaceUV, positionWS, 0);
    uint lightIndex = 0;
    [loop] while (ClusterNext(clusterIterator, lightIndex)) 
    {
        lightIndex += URP_FP_DIRECTIONAL_LIGHTS_COUNT;
        FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK

        Light light = GetAdditionalLight(lightIndex, positionWS, half4(1,1,1,1));
    /*
        #if defined(_LIGHT_LAYERS)
        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        #endif
        {
            EvaluateLighting(albedo, specularity, perceptualRoughness, metalness, subsurfaceThickness, f0, NoV, normalWS, viewDirectionWS, light, brdf);
        }
    */
    }
    #else


    for(uint lightIndex = 0; lightIndex < count; lightIndex++)
    {
        Light light = GetAdditionalLight(lightIndex, positionWS, half4(1,1,1,1));

        #if defined(_LIGHT_LAYERS)
        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        #endif
        {
            EvaluateLighting(albedo, specularity, perceptualRoughness, metalness, subsurfaceThickness, f0, NoV, normalWS, viewDirectionWS, light, brdf);
        }
    }


    #endif

    #endif
}

float3 GetReflection(float3 viewDirectionWS, float3 normalWS, float3 positionWS,  float roughness, float2 normalizedScreenSpaceUV)
{
    #define LOD_COUNT 6 // It appears that reflection probes have up to 6 mipmaps.
    float3 reflection = reflect(-viewDirectionWS, normalWS);
    float lod = roughness * LOD_COUNT;
    return GlossyEnvironmentReflection(half3(reflection), positionWS, half(roughness), half(1.0), normalizedScreenSpaceUV);
    //return DecodeHDREnvironment(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflection, lod), unity_SpecCube0_HDR);
}

//法线切线空间转换到世界空间
float3 NormalTangentToWorld(float3 normalTS, float3 normalWS, float4 tangentWS)
{
    float3x3 tangentToWorld = CreateTangentToWorld(normalWS, tangentWS.xyz, tangentWS.w);
    return TransformTangentToWorld(normalTS, tangentToWorld);
}

#endif