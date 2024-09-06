Shader "CURP/SimpleLit"
{
    Properties
    {
        //MRA贴图 r-金属度,g-粗糙度,b-ao
        _MRAMap("MRA Map",2D) = "white" {}
        [Toggle(_HasMRAMap)] _HasMRAMap("Has MRA Map",Float) = 0
        _Metalness("_Metalness",Range(0,3)) = 1
        
        _EmissionMap("Emission Map", 2D) = "black" {}
        [HDR] _EmissionColor("EmissionColor", Color) = (0,0,0)
        [Toggle(_HasEmissionMap)] _HasEmissionMap("Has Emission Map", Float) = 0
        [Toggle(_EmissionMapMultiply)] _EmissionMapMultiply("_EmissionMapMultiply", Float) = 0
        //基础贴图
        _BaseMap("BaseMap",2D) = "white" {}
        _BaseColor("BaseColor",Color) = (1,1,1,1)
        _NormalMap("NormalMap",2D) = "white" {}
        _NormalStrength("Normal Strength",Range(0,1)) = 1
        _Roughness("Roughness",Range(0,1)) = 0.0

        
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
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            
            #pragma vertex Vert;
            #pragma fragment Frag;
            #include "./Librarys/SimpleLit/SimpleLit.hlsl"
           
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
            
            #include "./Librarys/SimpleLit/SimpleLit.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "URPShaderEditor.SimpleLitEditorGUI"
}
