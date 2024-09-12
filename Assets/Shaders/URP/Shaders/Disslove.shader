Shader "CURP/Disslove"
{
    Properties
    {
        //基础贴图
        _BaseMap("BaseMap",2D) = "white" {}
        _BaseColor("BaseColor",Color) = (1,1,1,1)
        _NoiseMap("NoiseMap",2D) = "white" {}
        _EdgeColor("Edge Color",Color) = (1,1,1,1)
        _EdgeColorIntensity("EdgeColorIntensity",Float) = 1
        _EdgeWidth("Edge Width",Range(0,1)) = 0.0
        _Amout("Amout",Range(0,1)) = 0              //消融进度
        _Spreed("Spreed",Range(0.1,1)) = 1            //消融程度
        [Toggle(_AutoDisslove)] _AutoDisslove("_AutoDisslove",Float) = 0    //是否自动进行消融动画
        
        // Surface
        _Surface("Surface", Float) = 0.0
        _Blend("Blend", Float) = 0.0
        _AlphaClip("Alpha Clip", Range(0.0, 1.0)) = 0.0
        [HideInInspector]_NormalMap ("Normal Map", 2D) = "bump" {}
        //Advanced Properties
        [Toggle(_ReceiveFogEnabled)] _ReceiveFogEnabled ("Receive Fog", Float) = 1
        [Toggle(_ReceiveShadowsEnabled)] _ReceiveShadowsEnabled ("Receive Shadow", Float) = 1
        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}
        LOD 200
        
        Pass
        {
            Tags {"LightMode" = "UniversalForwardOnly"}
            Cull Off
            ZWrite On
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
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            
            #pragma vertex Vert;
            #pragma fragment Frag;
            #include "../Librarys/Disslove/Disslove.hlsl"
            
            
            ENDHLSL
        }

        Pass
        {
            Name "Lit_ShadowCaster"
            
            Tags {"LightMode" = "ShadowCaster"}
            ZWrite On
            ZTest LEqual
            ZClip Off
            
            HLSLPROGRAM
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            
            #pragma vertex Vert
            #pragma fragment FragmentDepthOnly
            #define CAST_SHADOWS_PASS
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            
            #include "../Librarys/Disslove/Disslove.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "URPShaderEditor.DissloveEditorGUI"
}
