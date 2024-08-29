Shader "CALF/PBRLit"
{
    Properties
    {
        //MRA贴图 r-金属度,g-粗糙度,b-ao
        _MRAMap("MRA Map",2D) = "white" {}
        [Toggle(_HasMRAMap)] _HasMRAMap("Has MRA Map",Float) = 0
        //基础贴图
        _BaseMap("BaseMap",2D) = "white" {}
        _BaseColor("BaseColor",Color) = (1,1,1,1)
        _NormalMap("NormalMap",2D) = "white" {}
        _Roughness("Roughness",Range(0,1)) = 0.0
        //细节贴图
        _EnableDetailMap("Enable Detail Map",Float) = 0
        _DetailMap("Detail Map",2D) = "white" {}
        _DetailMapColor("Detail Map Color",Color) = (1,1,1,1)
        _DetailNormalMap("Detail NormalMap",2D) = "white" {}
        _DetailScale("Detail Scale",Range(0,2)) = 1.0
        //Other Properties
        [Toggle(_ReceiveFogEnabled)] _ReceiveFogEnabled ("Receive Fog", Float) = 1
        [Toggle(_ReceiveShadowsEnabled)] _ReceiveShadowsEnabled ("Receive Shadow", Float) = 1
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}

        Pass
        {
            Tags {"LightMode" = "UniversalForwardOnly"}

            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/Shaders/URP/Library/SurfacePBR_URP.hlsl"

            // Fog, Decals, SSAO
            #pragma multi_compile_fog
            
            // Lighting
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            
            // Lightmapping
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON

            // Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON
            
            #pragma vertex vert;
            #pragma fragment frag;

            TEXTURE2D(_BlendMap);
            SAMPLER(sampler_BlendMap);

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            TEXTURE2D(_DetailMap);
            SAMPLER(sampler_DetailMap);
            TEXTURE2D(_DetailNormalMap);
            SAMPLER(sampler_DetailNormalMap);
            TEXTURE2D(_MRAMap);
            SAMPLER(sampler_MRAMap);

            CBUFFER_START(UnityMatVar)
                float _DetailScale;
                float _HasMRAMap;
                float _Roughness;
                float _EnableDetailMap;
                float _ReceiveFogEnabled;
                float _ReceiveShadowsEnabled;
                float4 _BaseColor;
                float4 _DetailMapColor;
                float4 _DetailMap_ST;
                float4 _BaseMap_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                //r-金属 g-粗糙 b-ao
                Varyings OUT = Vert(IN);
                OUT.color = float4(0.5,0.5,0.5,1);
                OUT.uv.xy = IN.uv * _BaseMap_ST.xy + _BaseMap_ST.zw;
                OUT.uv.zw = IN.uv * _DetailMap_ST.xy + _DetailMap_ST.zw;
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                float4 mraMap = SAMPLE_TEXTURE2D(_MRAMap, sampler_MRAMap,IN.uv);
                float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap, IN.uv) * _BaseColor;
                float4 normalMap = SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,IN.uv);
                float4 detailMap = SAMPLE_TEXTURE2D(_DetailMap, sampler_DetailMap,IN.uv.zw) * _DetailMapColor;
                float4 detailNormal = SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailMap, IN.uv.zw);
                detailMap =  half(2.0) * detailMap * _DetailScale - _DetailScale + half(1.0);

                float metalV = _HasMRAMap ? saturate(mraMap.r): 0.0;
                float ao = _HasMRAMap ? mraMap.b : 1.0;
                float roughness = _HasMRAMap ? saturate(mraMap.g + _Roughness) : _Roughness;
                
                MaterialData mat;
                mat.albedoAlpha = _EnableDetailMap ? baseMap * detailMap : baseMap;
                mat.metalness = metalV;
                mat.emission = GetEmission();
                mat.occlusion = ao;
                mat.perceptualRoughness = roughness;
                mat.specularity = GetSpecularity();
                float3 normalTS = UnpackNormal(normalMap);
                normalTS = float3(normalTS.rg * GetNormalStrength(), lerp(1, normalTS.b, saturate(GetNormalStrength())));
                normalTS = normalize(normalTS);
                float3 detailNormalTS = UnpackNormal(detailNormal);
                detailNormalTS = float3(detailNormalTS.rg * GetNormalStrength(), lerp(1, detailNormalTS.b, saturate(GetNormalStrength())));
                detailNormalTS = normalize(detailNormalTS);
                float3 blendNormalTS = lerp(normalTS, BlendNormalRNM(normalTS, detailNormalTS),1);
                mat.normalTS = _EnableDetailMap ? blendNormalTS : normalTS;
                float4 col = Frag(IN, mat,_ReceiveFogEnabled,_ReceiveShadowsEnabled);
                return col;
            }
            
            ENDHLSL
        }

        Pass
        {
            Name "PBRLit_ShadowCaster"
            
            Tags {"LightMode" = "ShadowCaster"}
            ZWrite On
            ZTest LEqual
            ZClip Off
            
            
            HLSLPROGRAM

            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            
            #pragma vertex Vert
            #pragma fragment FragmentDepthOnly
            #define CAST_SHADOWS_PASS
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            
            #include "Assets/Shaders/URP/Library/SurfacePBR_URP.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "URPShader.PBRLitEditorGUI"
}
