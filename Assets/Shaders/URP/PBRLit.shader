Shader "CALF/PBRLit"
{
    Properties
    {
        //MRA贴图 r-金属度,g-粗糙度,b-ao
        _MRAMap("MRA Map",2D) = "white" {}
        [Toggle(_HasMRAMap)] _HasMRAMap("Has MRA Map",Float) = 0
        
        _EmissionMap("Emission Map", 2D) = "black" {}
        [HDR] _EmissionColor("EmissionColor", Color) = (0,0,0)
        [Toggle(_HasEmissionMap)] _HasEmissionMap("Has Emission Map", Float) = 0
        [Toggle(_EmissionMapMultiply)] _EmissionMapMultiply("_EmissionMapMultiply", Float) = 0
        //基础贴图
        _BaseMap("BaseMap",2D) = "white" {}
        _BaseColor("BaseColor",Color) = (1,1,1,1)
        _NormalMap("NormalMap",2D) = "white" {}
        _NormalStrength("Normal Strength",Range(0,3)) = 1
        _Roughness("Roughness",Range(0,1)) = 0.0
        //细节贴图
        _EnableDetailMap("Enable Detail Map",Float) = 0
        _DetailMap("Detail Map",2D) = "white" {}
        _DetailMapColor("Detail Map Color",Color) = (1,1,1,1)
        _DetailNormalMap("Detail NormalMap",2D) = "white" {}
        _DetailScale("Detail Scale",Range(0,2)) = 1.0
        // Surface
        _Surface("Surface", Float) = 0.0
        _Blend("Blend", Float) = 0.0
        _AlphaClip("Alpha Clip", Range(0.0, 1.0)) = 0.0
        [Toggle(_AlphaClipEnabled)] _AlphaClipEnabled ("Alpha Clip Enabled", Float) = 0.0
        [HideInInspector] _SrcBlend("Source Blending", Float) = 1.0
        [HideInInspector] _DstBlend("Dest Blending", Float) = 0.0
        _SortPriority("Sort Priority", Range(-50.0, 50.0)) = 0.0
        
        //Advanced Properties
        [Toggle(_ReceiveFogEnabled)] _ReceiveFogEnabled ("Receive Fog", Float) = 1
        [Toggle(_ReceiveShadowsEnabled)] _ReceiveShadowsEnabled ("Receive Shadow", Float) = 1
        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        
        [Enum(Off, 0, On, 1)]_ZWrite ("ZWrite", Float) = 1.0 // Default to "ZWrite On"
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("Depth Test", Float) = 4 // Default to "LEqual"
        [Enum(UnityEngine.Rendering.CullMode)] _Culling ("Culling", Float) = 2 // Default to "Cull Back"

        
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}

        Pass
        {
            Tags {"LightMode" = "UniversalForwardOnly"}
            
            Blend [_SrcBlend] [_DstBlend]
            Cull [_Culling]
            ZWrite [_ZWrite]
            ZTest LEqual
            ZClip Off
            AlphaToMask Off
            
            HLSLPROGRAM
            
            // Render Paths
            #pragma multi_compile _ _FORWARD_PLUS

            // Fog, Decals, SSAO
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION

            // Transparency
            #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            
            // Lighting
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT

            // Unity stuff
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            
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
            
            #pragma vertex Vert;
            #pragma fragment FragPlus;
            #include "./Librarys/URP_PBR.hlsl"

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
            TEXTURE2D(_EmissionMap);
            SAMPLER(sampler_EmissionMap);

            CBUFFER_START(UnityPerMaterial)
                float _DetailScale;
                float _HasMRAMap;
                float _Roughness;
                float _EnableDetailMap;
                float _ReceiveFogEnabled;
                float _ReceiveShadowsEnabled;
                float _HasEmissionMap;
                float _AlphaClip;
                float _EmissionMapMultiply;
                float _NormalStrength;
                float4 _BaseColor;
                float4 _EmissionColor;
                float4 _DetailMapColor;
                float4 _DetailMap_ST;
                float4 _BaseMap_ST;
            CBUFFER_END

           float4 FragPlus(Varyings IN) : SV_Target
           {
               float2 baseUV = IN.uv * _BaseMap_ST.xy + _BaseMap_ST.zw;
               float2 detailUV = IN.uv * _DetailMap_ST.xy + _DetailMap_ST.zw;
               float4 mraMap = SAMPLE_TEXTURE2D(_MRAMap, sampler_MRAMap,IN.uv);
               float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap, baseUV).rgba * _BaseColor;
               float4 normalMap = SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,baseUV);
               float4 detailMap = SAMPLE_TEXTURE2D(_DetailMap, sampler_DetailMap,detailUV).rgba * _DetailMapColor;
               float4 detailNormal = SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailMap, detailUV);
               detailMap =  half(2.0) * detailMap * _DetailScale - _DetailScale + half(1.0);
               
               float4 emissionMap = _HasEmissionMap ? SAMPLE_TEXTURE2D(_EmissionMap,sampler_EmissionMap,IN.uv) * _EmissionColor : _EmissionColor;
               float metalV = _HasMRAMap ? saturate(mraMap.r): 0.0;
               float ao = lerp(1,mraMap.b,1);
               float roughness = _HasMRAMap ? saturate(mraMap.g * _Roughness) : _Roughness;
               
               MaterialData mat;
               float4 albedo = _EnableDetailMap ? float4(baseMap.rgb * detailMap.rgb,baseMap.a):baseMap;
               float emissionV = emissionMap.r <= 0.01f && emissionMap.g <= 0.01f && emissionMap.b <= 0.01f; //emissionV为1时 环境贴图这块像素颜色值为黑色
               float IsEmissionMapMulAndHasEmissionMap = _EmissionMapMultiply && _HasEmissionMap && (emissionV == 0);        
               mat.albedoAlpha = IsEmissionMapMulAndHasEmissionMap ? albedo * emissionMap : albedo;
               mat.metalness = metalV;
               mat.emission = _EmissionMapMultiply ? float3(0,0,0) : emissionMap.rgb;
               mat.occlusion = ao;
               mat.perceptualRoughness = roughness;
               mat.specularity = GetSpecularity();
               float3 normalTS = UnpackNormal(normalMap);
               normalTS = float3(normalTS.rg * _NormalStrength, lerp(1, normalTS.b, saturate(_NormalStrength)));
               normalTS = normalize(normalTS);
               float3 detailNormalTS = UnpackNormal(detailNormal);
               detailNormalTS = float3(detailNormalTS.rg * _NormalStrength, lerp(1, detailNormalTS.b, saturate(_NormalStrength)));
               detailNormalTS = normalize(detailNormalTS);
               float3 blendNormalTS = lerp(normalTS, BlendNormalRNM(normalTS, detailNormalTS),1);
               mat.normalTS = _EnableDetailMap ? blendNormalTS : normalTS;
               float4 col = Frag(IN, mat,_ReceiveFogEnabled,_ReceiveShadowsEnabled,_AlphaClip);
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
            
            #include "./Librarys/URP_PBR.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "URPShaderEditor.PBRLitEditorGUI"
}
