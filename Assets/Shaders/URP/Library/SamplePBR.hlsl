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
//
// #if defined(LOD_FADE_CROSSFADE)
//     #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
// #endif
//
//
// ///////////////////////////////////////////////////////////////////////////////
// //                      Helper Functions                                     //
// ///////////////////////////////////////////////////////////////////////////////
//
// half InverseLerp(half a, half b, half v)
// {
//     return (v - a) / (b - a);
// }
//
// half RemapUnclamped(half iMin, half iMax, half oMin, half oMax, half v)
// {
//     half t = InverseLerp(iMin, iMax, v);
//     return lerp(oMin, oMax, t);
// }
//
// half Remap(half iMin, half iMax, half oMin, half oMax, half v)
// {
//     v = clamp(v, iMin, iMax);
//     return RemapUnclamped(iMin, iMax, oMin, oMax, v);
// }
//
// float CheapSqrt(float a)
// {
//     return 1.0 - ((1.0 - a) * (1.0 - a));
// }
//

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

//
// float luminance(float3 c)
// {
//     return dot(c, float3(0.2126, 0.7152, 0.0722));
// }

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
//
// // Transforms
// float3 _LightDirection;
// float3 _LightPosition;
//
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

//
// ///////////////////////////////////////////////////////////////////////////////
// //                      Lighting Functions                                   //
// ///////////////////////////////////////////////////////////////////////////////

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
    return lerp(f0, albedo, metalness);
}

float3 Fresnel(float3 f0, float cosTheta, float roughness)
{
    return f0 + (max(1.0 - roughness, f0) - f0) * SchlickFresnel(cosTheta);
}

float FD90(float roughness, float LoH)
{
    return 0.5 + (2.0 * roughness * LoH * LoH);
}

float3 GetDiffuse(float3 baseColor, float perceptualRoughness, float LoH, float NoL, float NoV)
{
    return (baseColor / PI) * (1.0 + (FD90(perceptualRoughness, LoH) - 1.0) * SchlickFresnel(NoL)) * (1.0 + (FD90(perceptualRoughness, LoH) - 1.0) * SchlickFresnel(NoV));
}

float3 NDF(float3 f0, float perceptualRoughness, float NoH)
{
    float a2 = perceptualRoughness * perceptualRoughness;
    float NoH2 = NoH * NoH;
    float c = (NoH2 * (a2 - 1.0)) + 1.0;
    return max(f0 / (PI * c * c), 1e-7);
}

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
    float3 diffuse = GetDiffuse(albedo, perceptualRoughness, inputs.LoH, inputs.NoL, NoV);

    
    float3 ndf = NDF(f0, perceptualRoughness, inputs.NoH);
    float3 fresnel = Fresnel(f0, inputs.VoH, perceptualRoughness);
    float gsf = GSF(inputs.NoL, NoV, perceptualRoughness);
    float3 specular = (fresnel * ndf * gsf) / ((4.0 * inputs.NoL * NoV) + 1e-7);

    specular = clamp(specular, 0, 10.0);
    diffuse = lerp(diffuse, 0.0, metalness);
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

    OUT.positionWS = mul(unity_ObjectToWorld, IN.positionOS).xyz;
    OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
    OUT.normalWS = normalize(OUT.normalWS);
    OUT.positionHCS = GetClipSpacePosition(OUT.positionWS, OUT.normalWS);
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

void ApplyHeightmap(float height, float3 viewDirectionTS, float scale, inout float2 uv)
{
    uv += ParallaxOffset1Step(height, scale, viewDirectionTS);
}

struct MaterialInputData
{
    Texture2D baseMap;
    float4 baseMap_ST;
    float4 baseColor;

    Texture2D normalMap;
    float normalStrength;

    Texture2D heightMap;
    int hasHeightMap;

    Texture2D roughnessMap;
    float roughness;
    float roughnessMapExposure;
    int hasRoughnessMap;

    Texture2D metalnessMap;
    float metalness;
    float metalnessMapExposure;
    int hasMetalnessMap;

    Texture2D emissionMap;
    float3 emission;
    int hasEmissionMap;

    Texture2D occlusionMap;
    float occlusion;

    float specularity;

    SamplerState samplerState;
};

struct MaterialData
{
    float4 albedoAlpha;
    float3 normalTS;
    float metalness;
    float perceptualRoughness;
    float occlusion;
    float3 emission;
    float specularity;
};

Texture2D _DefaultTex;
SamplerState sampler_DefaultTex;

void InitMaterialInputData(out MaterialInputData inputData)
{
    inputData.baseMap = _DefaultTex;
    inputData.baseMap_ST = float4(1,1,0,0);
    inputData.baseColor = float4(255, 255, 255, 1); //默认白色
    inputData.normalMap = _DefaultTex;
    inputData.normalStrength = 1.0;
    inputData.heightMap = _DefaultTex;
    inputData.hasHeightMap = 0;
    inputData.roughnessMap = _DefaultTex;
    inputData.roughness = -1.0; 
    inputData.roughnessMapExposure = 1.0; 
    inputData.hasRoughnessMap = 1; 
    inputData.metalnessMap =_DefaultTex;
    inputData.metalness = 0.0; 
    inputData.metalnessMapExposure = 1.0; 
    inputData.hasMetalnessMap = 0; 
    inputData.emissionMap = _DefaultTex; 
    inputData.emission = float3(0, 0, 0);
    inputData.hasEmissionMap = 0; 
    inputData.occlusionMap = _DefaultTex;
    inputData.occlusion = 2.0;
    inputData.specularity = 1.0;
    inputData.samplerState = sampler_DefaultTex;
}

void InitializeMaterialData(float2 uv, MaterialInputData i, out MaterialData m)
{
    // Albedo + Alpha
    m.albedoAlpha = SAMPLE_TEXTURE2D(i.baseMap, i.samplerState, uv).rgba * i.baseColor;
    
    // Normals
    // To do: Could simplify this, probably
    float4 normalMap = SAMPLE_TEXTURE2D(i.normalMap, i.samplerState, uv);
    float3 normalTS = UnpackNormal(normalMap);
    normalTS = float3(normalTS.rg * i.normalStrength, lerp(1, normalTS.b, saturate(i.normalStrength)));
    normalTS = normalize(normalTS);
    m.normalTS = normalTS;
    
    // Roughness
    float roughness = i.roughness;
    if(i.hasRoughnessMap)
    {
        roughness = saturate(SAMPLE_TEXTURE2D(i.roughnessMap, i.samplerState, uv).r + i.roughnessMapExposure);
    }
    m.perceptualRoughness = roughness * roughness;
    
    // Metalness
    m.metalness = i.metalness;
    if(i.hasMetalnessMap)
    {
        m.metalness = saturate(SAMPLE_TEXTURE2D(i.metalnessMap, i.samplerState, uv).r + i.metalnessMapExposure);
    }
    
    // Emission
    m.emission = i.emission;
    if(i.hasEmissionMap) 
    {
        m.emission *= SAMPLE_TEXTURE2D(i.emissionMap, i.samplerState, uv).rgb;
    }
    
    // Occlusion
    m.occlusion = SAMPLE_TEXTURE2D(i.occlusionMap, i.samplerState, uv).r;
    m.occlusion = lerp(1.0, m.occlusion, i.occlusion);
    
    // specularity
    m.specularity = i.specularity * 0.08; // Remaps specularity to [0, 0.08]
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

float weightedSum(float a, float b, float2 f)
{
    return a * f.x + b * f.y;
}

float2 weightedSum(float2 a, float2 b, float2 f)
{
    return a * f.x + b * f.y;
}

float3 weightedSum(float3 a, float3 b, float2 f)
{
    return a * f.x + b * f.y;
}


float4 weightedSum(float4 a, float4 b, float2 f)
{
    return a * f.x + b * f.y;
}

float4 Frag(Varyings IN,MaterialInputData matInputData) 
{
    
    UNITY_SETUP_INSTANCE_ID(IN);  // --- 仅当要在片元着色器中访问任何实例化属性时才需要
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
    
    #ifdef LOD_FADE_CROSSFADE
        LODFadeCrossFade(IN.positionHCS);
    #endif

    float2 uv = TRANSFORM_TEX(IN.uv, matInputData.baseMap).xy;
   
    float height = 0.5;
    if(matInputData.hasHeightMap)
    {
        height = matInputData.heightMap.Sample(matInputData.samplerState,uv).r;
    }
    
    float2 blendFactors = float2(1,0);
    // blendFactors = GetBlendFactors(0.5, IN.color.r, 0.5, 1.0 - IN.color.r);

    // if(_UseVertexColors)
    // {
    //     blendFactors = GetBlendFactors(h1, IN.color.r, h2, 1.0 - IN.color.r);
    // }

    // float height = weightedSum(h1, h2, blendFactors);
    // float heightScale = weightedSum(_HeightStrength, _HeightStrength2, blendFactors);

    // ApplyHeightmap(0.5, IN.viewDirectionTS, 1, uv);
    // ApplyHeightmap(height, IN.viewDirectionTS, heightScale, uv2);

    ///////////////

    MaterialData mat;
    InitializeMaterialData(uv,matInputData, mat);
    
    ///////////////////////////////
    //   Alpha Clipping          //
    ///////////////////////////////
     
    // AlphaDiscard(m.albedoAlpha.a, _AlphaClip);
    
    
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

    return float4(albedo,1.0f);
    
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
    //
    //
    //
    // // Lighting
    // if (_ReceiveShadowsEnabled == 0)
    // {
    //     mainLight.shadowAttenuation = 1;
    // }

    // mainLight.shadowAttenuation = 1;

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
    f0 = lerp(f0, albedo, metalness);
    float mFresnel = Fresnel(f0, NoV, perceptualRoughness);
    
    float3 indirectSpecular = GetReflection(IN.viewDirectionWS, IN.normalWS, IN.positionWS, perceptualRoughness, normalizedScreenSpaceUV) * (1.0 - perceptualRoughness) * indirectSpecularOcclusion;
    float3 indirectDiffuse = bakedGI * albedo * lerp(1, 0, metalness);
    
    brdf.specular += indirectSpecular * occlusionData.indirect * occlusion * lerp(1.0, albedo, metalness * (1.0 - fresnel)) * lerp(fresnel, 1.0, metalness);
    // brdf.diffuse += indirectDiffuse * occlusionData.indirect * occlusion;

    //最终输出的颜色 漫反射 + 镜面反射
    float3 color = (brdf.diffuse + brdf.specular);
    
    // Subsurface Lighting
    // color += brdf.subsurface;
    

    // Emission
    // color += emission;
    
    // Mix Fog
    // if (_ReceiveFogEnabled == 1)
    // {
    //     float fogFactor = InitializeInputDataFog(float4(IN.positionWS, 1), 0);
    //     color = MixFog(color, fogFactor);
    // }
    
    return float4(color, mat.albedoAlpha.a);
}
#endif 