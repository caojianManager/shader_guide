#ifndef DISSLOVE_INCLUDED
#define DISSLOVE_INCLUDED

#include "../../Librarys/Common/PBRCommon.hlsl"
#include "Disslove_Maps.hlsl"
#include "Disslove_Properties.hlsl"


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
    
    // float alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv.xy).a * _BaseColor.a;
    // AlphaDiscard(alpha, _AlphaClip);

    #ifdef LOD_FADE_CROSSFADE
        LODFadeCrossFade(IN.positionHCS);
    #endif
    
    
    return 0;
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

void InitializeMaterialData(float2 uv,out MaterialData mat,float noiseMap_R)
{
    float2 baseUV = uv * _BaseMap_ST.xy + _BaseMap_ST.zw;

    //基础贴图
    float4 albedoMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap, baseUV).rgba * _BaseColor;
    mat.albedoAlpha = albedoMap;
    float4 normalMap = SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap, baseUV).rgba;
    float3 normalTS = UnpackNormal(normalMap);
    normalTS = float3(normalTS.rg * 1, lerp(1, normalTS.b, saturate(1)));
    normalTS = normalize(normalTS);
    mat.normalTS = normalTS;
    mat.emission = float3(0,0,0);
    //金属度
    mat.metalness = 0;
    mat.occlusion = 1;
    mat.perceptualRoughness = 1;
    mat.specularity = 0.08;
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
    
    //噪声贴图
    float noiseMap_R = SAMPLE_TEXTURE2D(_NoiseMap,sampler_NoiseMap,IN.uv);
    clip(noiseMap_R - _Amout);
    InitializeMaterialData(IN.uv,mat,noiseMap_R);

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
    if(_ReceiveShadowsEnabled == 0)
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
    float fresnel = Fresnel(f0, NoV, perceptualRoughness).x;
    
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
    if (_ReceiveFogEnabled == 1)
    {
        float fogFactor = InitializeInputDataFog(float4(IN.positionWS, 1), 0);
        color = MixFog(color, fogFactor);
    }
    
    return float4(color, mat.albedoAlpha.a);
}

#endif
