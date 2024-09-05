#ifndef TERRAINMIX_INCLUDE
#define TERRAINMIX_INCLUDE

#include "./Librarys/Common/PBRCommon.hlsl"
#include "TerrainMix_Maps.hlsl"
#include "TerrainMix_Properties.hlsl"

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

//一个来自UE4 计算heightLerp的公式
float HeightLerp(float height, float transition, float blendeContrast)
{
    return clamp(lerp(0 - blendeContrast, blendeContrast + 1, clamp((height - 1) + (transition * 2),0,1)),0,1);
}

//一个来自UE4 图片对比度计算公式
float CheapContrast(float input, float blendeContrast)
{
    return clamp(lerp((0 - blendeContrast), (blendeContrast + 1), input),0,1);
}

//基于权重的混合因子
float4 WeightBlend(float4 vec4,float blendContrast)
{
    float w1 = max(max(max(vec4.x,vec4.y),vec4.z),vec4.w) - blendContrast;
    float c1 = max(0,vec4.x - w1);
    float c2 = max(0, vec4.y - w1);
    float c3 = max(0, vec4.z - w1);
    float c4 = max(0, vec4.w - w1);
    float4 blendWieght = float4(c1,c2,c3,c4) / (c1 + c2 + c3 + c4);
    return blendWieght; //blendweight中保存着四个权重值
}

void InitializeMaterialData(float2 uv,out MaterialData mat)
{
    float4 blendMap = SAMPLE_TEXTURE2D(_BlendMap,sampler_BlendMap, uv);
    
    //注意HRA贴图 R通道-->保存高度Height信息 G通道-->roughness B通道-->AO
    float2 uw1 = uv * _Layer1_BaseMap_ST.xy + _Layer1_BaseMap_ST.zw;
    float4 layer1_baseColor = SAMPLE_TEXTURE2D(_Layer1_BaseMap,sampler_Layer1_BaseMap, uw1)  * _Layer1_BaseColor;
    float4 layer1_normal = SAMPLE_TEXTURE2D(_Layer1_NormalMap,sampler_Layer1_NormalMap, uw1);
    float4 layer1_hra = SAMPLE_TEXTURE2D(_Layer1_HRA,sampler_Layer1_HRA, uw1);
    float layer1_height = CheapContrast(layer1_hra.x, _Layer1_HeightContrast);
    
    float2 uv2 = uv * _Layer2_BaseMap_ST.xy + _Layer2_BaseMap_ST.zw;
    float4 layer2_baseColor = SAMPLE_TEXTURE2D(_Layer2_BaseMap,sampler_Layer2_BaseMap, uv2)  * _Layer2_BaseColor;
    float4 layer2_normal = SAMPLE_TEXTURE2D(_Layer2_NormalMap,sampler_Layer2_NormalMap, uv2);
    float4 layer2_hra = SAMPLE_TEXTURE2D(_Layer2_HRA,sampler_Layer2_HRA, uv2);
    float layer2_height = CheapContrast(layer2_hra.x, _Layer2_HeightContrast);
    
    float2 uv3 = uv * _Layer3_BaseMap_ST.xy + _Layer3_BaseMap_ST.zw;
    float4 layer3_baseColor = SAMPLE_TEXTURE2D(_Layer3_BaseMap,sampler_Layer3_BaseMap, uv3)  * _Layer3_BaseColor;
    float4 layer3_normal = SAMPLE_TEXTURE2D(_Layer3_NormalMap,sampler_Layer3_NormalMap, uv3);
    float4 layer3_hra = SAMPLE_TEXTURE2D(_Layer3_HRA,sampler_Layer3_HRA, uv3);
    float layer3_height = CheapContrast(layer3_hra.x, _Layer3_HeightContrast);
    
    float2 uv4 = uv * _Layer4_BaseMap_ST.xy + _Layer4_BaseMap_ST.zw;
    float4 layer4_baseColor = SAMPLE_TEXTURE2D(_Layer4_BaseMap,sampler_Layer4_BaseMap, uv4)  * _Layer4_BaseColor;
    float4 layer4_normal = SAMPLE_TEXTURE2D(_Layer4_NormalMap,sampler_Layer4_NormalMap, uv4);
    float4 layer4_hra = SAMPLE_TEXTURE2D(_Layer4_HRA,sampler_Layer4_HRA, uv4);
    float layer4_height = CheapContrast(layer4_hra.x, _Layer4_HeightContrast);
    
    float4 blend_vec4 = float4(blendMap.x + layer1_height, blendMap.y + layer2_height, blendMap.z + layer3_height, blendMap.w + layer4_height);
    float4 blendWieght = WeightBlend(blend_vec4, _BlendContrast);
    float4 baseColor = layer1_baseColor * blendWieght.x + layer2_baseColor * blendWieght.y + layer3_baseColor * blendWieght.z + layer4_baseColor * blendWieght.w;
    float roughness = layer1_hra.y * blendWieght.x  + layer2_hra.y * blendWieght.y + layer3_hra.y * blendWieght.z + layer4_hra.y * blendWieght.w;
    float ao = layer1_hra.z * blendWieght.x  + layer2_hra.z * blendWieght.y + layer3_hra.z * blendWieght.z + layer4_hra.z * blendWieght.w;
    float4 normalMap = layer1_normal * blendWieght.x + layer2_normal * blendWieght.y + layer3_normal * blendWieght.z + layer4_normal * blendWieght.w;
    
    mat.albedoAlpha = baseColor;
    mat.metalness = GetMetalness();
    mat.emission = GetEmission();
    mat.occlusion = ao;
    mat.perceptualRoughness = roughness;
    mat.specularity = GetSpecularity();
    float3 normalTS = UnpackNormal(normalMap);
    normalTS = float3(normalTS.rg * GetNormalStrength(), lerp(1, normalTS.b, saturate(GetNormalStrength())));
    normalTS = normalize(normalTS);
    mat.normalTS = normalTS;
    
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
    InitializeMaterialData(IN.uv,mat);
    
    ///////////////////////////////
    //   Alpha Clipping          //
    ///////////////////////////////

    // AlphaDiscard(mat.albedoAlpha.a, _AlphaClip);
    
    
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
    // if (_ReceiveFogEnabled == 1)
    // {
    //     float fogFactor = InitializeInputDataFog(float4(IN.positionWS, 1), 0);
    //     color = MixFog(color, fogFactor);
    // }
    
    return float4(color, 1);
}
#endif 