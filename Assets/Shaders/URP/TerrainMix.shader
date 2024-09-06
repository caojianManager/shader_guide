Shader "CURP/TerrainMix"
{
    Properties
    {
        _BlendContrast("Blend Contrast",Range(0.1,1)) = 0.1
        _BlendMap("Blend Map",2D) = "white" {}
        
        //Layer01
        _Layer1_BaseMap("Layer1 BaseMap",2D) = "white" {}
        _Layer1_BaseColor("Layer1 BaseColor",Color) = (1,1,1,1)
        _Layer1_NormalMap("Layer1 NormalMap",2D) = "white" {}
        _Layer1_NormalScale("Layer1 NormalScale",Range(0,1)) = 1 
        _Layer1_MRAH("Layer1 MRAH",2D) = "white" {}
        _Layer1_HeightContrast("Layer1 Height Contrast",Range(0,1)) = 0.0
        _Layer1_Metalness("Layer1 Metalness",Range(0,1)) = 1
        _Layer1_Roughness("Layer1 Roughness",Range(0,1)) = 1
        //Layer02
        [Toggle(_Layer2_Enable)] _Layer2_Enable("Layer2 Enable",Float) = 0
        _Layer2_BaseMap("Layer2 BaseMap",2D) = "white" {}
        _Layer2_BaseColor("Layer2 BaseColor",Color) = (1,1,1,1)
        _Layer2_NormalMap("Layer2 NormalMap",2D) = "white" {}
        _Layer2_NormalScale("Layer2 NormalScale",Range(0,1)) = 1 
        _Layer2_MRAH("Layer2 MRAH",2D) = "white" {}
        _Layer2_HeightContrast("Layer2 Height Contrast",Range(0,1)) = 0.0
        _Layer2_Metalness("Layer2 Metalness",Range(0,1)) = 1
        _Layer2_Roughness("Layer2 Roughness",Range(0,1)) = 1
        //Layer03
        [Toggle(_Layer3_Enable)] _Layer3_Enable("Layer3 Enable",Float) = 0
        _Layer3_BaseMap("Layer3 BaseMap",2D) = "white" {}
        _Layer3_BaseColor("Layer3 BaseColor",Color) = (1,1,1,1)
        _Layer3_NormalMap("Layer3 NormalMap",2D) = "white" {}
        _Layer3_NormalScale("Layer3 NormalScale",Range(0,1)) = 1 
        _Layer3_MRAH("Layer3 MRAH",2D) = "white" {}
        _Layer3_HeightContrast("Layer3 Height Contrast",Range(0,1)) = 0.0
        _Layer3_Metalness("Layer3 Metalness",Range(0,1)) = 1
        _Layer3_Roughness("Layer3 Roughness",Range(0,1)) = 1
        //Layer04
        [Toggle(_Layer4_Enable)] _Layer4_Enable("Layer4 Enable",Float) = 0
        _Layer4_BaseMap("Layer4 BaseColor",2D) = "white" {}
        _Layer4_BaseColor("Layer4 BaseColor",Color) = (1,1,1,1)
        _Layer4_NormalMap("Layer4 NormalMap",2D) = "white" {}
        _Layer4_NormalScale("Layer4 NormalScale",Range(0,1)) = 1 
        _Layer4_MRAH("Layer4 MRAH",2D) = "white" {}
        _Layer4_HeightContrast("Layer4 Height Contrast",Range(0,1)) = 0.0
        _Layer4_Metalness("Layer4 Metalness",Range(0,1)) = 1
        _Layer4_Roughness("Layer4 Roughness",Range(0,1)) = 1
        
        //Advanced Properties
        [Toggle(_ReceiveFogEnabled)] _ReceiveFogEnabled ("Receive Fog", Float) = 1
        [Toggle(_ReceiveShadowsEnabled)] _ReceiveShadowsEnabled ("Receive Shadow", Float) = 1
    }
    
    SubShader
    {
        Tags {"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}
            
            Cull Off
            ZTest LEqual
            ZClip Off
            
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
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "./Librarys/TerrainMix/TerrainMix.hlsl"
            #pragma vertex Vert;
            #pragma fragment Frag;
            
            ENDHLSL
        }

        Pass
        {
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
            
            #include "./Librarys/Lit/Lit.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "URPShaderEditor.TerrainMixEditorGUI"
}
