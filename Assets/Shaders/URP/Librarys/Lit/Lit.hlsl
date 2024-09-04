#ifndef OS_LIT_INCLUDE
#define OS_LIT_INCLUDE

///////////////////////////////////////////////////////////////////////////////
//                      Global Defines                                       //
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//                      Includes                                             //
///////////////////////////////////////////////////////////////////////////////

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
// See ShaderVariablesFunctions.hlsl in com.unity.render-pipelines.universal/ShaderLibrary/ShaderVariablesFunctions.hlsl

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
//
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

    // Subsurface
    // [branch]
    // if(_SubsurfaceEnabled == 1)
    // {
    //     float3 halfDirectionWS = normalize(-light.direction + normalWS * _SubsurfaceDistortion);
    //     float3 lightColor = light.color * light.distanceAttenuation;
    //     float subsurfaceAmount = pow(dot01(viewDirectionWS, halfDirectionWS), _SubsurfaceFalloff) + _SubsurfaceAmbient;
    //     float3 subsurface = subsurfaceAmount * (1.0 - subsurfaceThickness) * _SubsurfaceColor;
    //     brdf.subsurface += subsurface * lightColor * albedo;
    // }
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
//                      一些默认材质属性计算（Struct -->MaterialData）                                    //
//        如果这些计算不满足你需要的属性，可自己重新计算                             //
///////////////////////////////////////////////////////////////////////////////

//默认的基础颜色---如有图片混合 可自己重写
float4 GetAlbedoAlpha(Texture2D albedo, SamplerState sampler_albedo, float2 uv, float4 baseColor)
{
    //Albedo + Alpha
    return SAMPLE_TEXTURE2D(albedo,sampler_albedo, uv).rgba * baseColor;
}

//默认的金属度计算--采用金属度贴图
float GetMetalness()
{
    float metalness = 0.0f;
    //使用金属度贴图计算金属度
    // metalness = saturate(SAMPLE_TEXTURE2D(metalnessMap, sampler_metalnessMap, uv).r + metalnessMapExposure);
    return metalness;
}

//默认自发光属性--Emission控制从表面发出的光的颜色和强度
float3 GetEmission()
{
    float3 emission = float3(0,0,0);
    //使用自发光贴图计算自发光颜色
    //emission = SAMPLE_TEXTURE2D(emissionMap, sampler_emissionMap, uv).rgb;
    return emission;
}

//法线长度-Default
float GetNormalStrength()
{
    return 1.6f;
}

//高光-通过这个方法获取
float GetSpecularity(float specularity = 1.0f)
{
    return specularity * 0.08; // Remaps specularity to [0, 0.08]
}

float GetRoughnessWithMap(Texture2D roughnessMap,SamplerState sampler_roughnessMap, float2 uv, float roughnessMapExposure)
{
    return saturate(SAMPLE_TEXTURE2D(roughnessMap, sampler_roughnessMap, uv).r + roughnessMapExposure);
}

///////////////////////////////////////////////////////////////////////////////
//                      Fragment                                             //
///////////////////////////////////////////////////////////////////////////////

float FragmentDepthOnly(Varyings IN) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(IN);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
    
    // float alpha = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv.xy).a * _BaseColor.a;
    // AlphaDiscard(alpha, _AlphaClip);

    #ifdef LOD_FADE_CROSSFADE
        LODFadeCrossFade(IN.positionHCS);
    #endif
    
    
    return 0;
}

float4 FragmentDepthNormalsOnly(Varyings IN) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(IN);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
    
    // float alpha = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv.xy).a * _BaseColor.a;
    // AlphaDiscard(alpha, _AlphaClip);
    
    #ifdef LOD_FADE_CROSSFADE
        LODFadeCrossFade(IN.positionHCS);
    #endif
    
    return float4(normalize(IN.normalWS), 0);
}


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

float2 GetBlendFactors(float height1, float a1, float height2, float a2)
{
    float depth = 0.2;
    float ma = max(height1 + a1, height2 + a2) - depth;
    
    float b1 = max(height1 + a1 - ma, 0);
    float b2 = max(height2 + a2 - ma, 0);
    float b3 = max(rcp(b1 + b2), 1e-7);
    return float2(b1 * b3, b2 * b3);
}

float4 Frag(Varyings IN,MaterialData mat,float IsRecivedFog = 0,float IsRecivedShadow = 0,float alphaClip = 0.0) 
{
    UNITY_SETUP_INSTANCE_ID(IN);  // --- 仅当要在片元着色器中访问任何实例化属性时才需要
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
    
    #ifdef LOD_FADE_CROSSFADE
        LODFadeCrossFade(IN.positionHCS);
    #endif
    
    ///////////////////////////////
    //   Alpha Clipping          //
    ///////////////////////////////

    AlphaDiscard(mat.albedoAlpha.a, alphaClip);
    
    
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
    // Subsurface
    // float subsurfaceThickness = _SubsurfaceThickness;
    // if(_HasSubsurfaceMap == 1)
    // {
    //     subsurfaceThickness *= SAMPLE_TEXTURE2D(_SubsurfaceThicknessMap, sampler_SubsurfaceThicknessMap, IN.uv).r;
    // }

    
    // Lighting--固定接受阴影
    if(IsRecivedShadow == 0)
    {
        mainLight.shadowAttenuation = 1;
    }

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
    float fresnel = Fresnel(f0, NoV, perceptualRoughness);
    
    //不同的Fresnel系数 结果不同
    // f0 = lerp(f0, albedo, metalness);
    // float mFresnel = Fresnel(f0, NoV, perceptualRoughness);
    
    float3 indirectSpecular = GetReflection(IN.viewDirectionWS, IN.normalWS, IN.positionWS, perceptualRoughness, normalizedScreenSpaceUV) * (1.0 - perceptualRoughness) * indirectSpecularOcclusion;
    float3 indirectDiffuse = bakedGI * albedo * lerp(1, 0, metalness);
    
    brdf.specular += indirectSpecular * occlusionData.indirect * occlusion * lerp(1.0, albedo, metalness * (1.0 - fresnel)) * lerp(fresnel, 1.0, metalness);
    brdf.diffuse += indirectDiffuse * occlusionData.indirect * occlusion;
    //最终输出的颜色 漫反射 + 镜面反射
    float3 color = (brdf.diffuse + brdf.specular);
    
    // Subsurface Lighting
    color += brdf.subsurface;

    // Emission
    color += emission;
   
    
    // Mix Fog
    if (IsRecivedFog == 1)
    {
        float fogFactor = InitializeInputDataFog(float4(IN.positionWS, 1), 0);
        color = MixFog(color, fogFactor);
    }
    
    return float4(color, mat.albedoAlpha.a);
}
#endif 