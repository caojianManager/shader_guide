Shader "CURP/Glass"
{
    Properties
    {
        //Matcap贴图
        _MatcapMap("Matcap Map",2D) = "white" {}
        _MatcapColor("Matcap Color",Color) = (1,1,1,1)
        _RefractMap("_RefractMap",2D) = "white" {}
        _RefractColor("_RefractColor",Color) = (1,1,1,1)
        _RefractIntensity("_RefractIntensity",Float) = 1.0
        _MatcapUVIntensity("_MatcapUVIntensity",Float) = 0
        _MatcapIntensity("Matcap Intensity",Range(0.1,1)) = 1
        //厚度贴图
        _ThickMap("Thick Map",2D) = "white" {}
        _ObjectPivotOffset("_ObjectPivotOffset",Float) = 0
        _ObjectPivotHeight("_ObjectPivotHeight",Float) = 1
        //污迹图
        _DirtMap("DirtMap",2D) = "white" {}
        _LightEdgeMin("LightEdgeMin",Float) = 0
        _LightEdgeMax("_LightEdgeMax",Float) = 1
        // Surface
        [HideInInspector] _SrcBlend("Source Blending", Float) = 1.0
        [HideInInspector] _DstBlend("Dest Blending", Float) = 0.0
        
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("Depth Test", Float) = 4 // Default to "LEqual"
    }
    SubShader
    {
        Tags {
            "RenderType" = "Transparency"   
            "IgnoreProjector" = "True"
            "UniversalMaterialType" = "Unlit"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Tags {"LightMode" = "UniversalForwardOnly"}
            
            Blend [_SrcBlend] [_DstBlend]
            Cull Off
            ZWrite Off
            ZTest LEqual
            ZClip Off
            
            HLSLPROGRAM
            // Render Paths
            #pragma multi_compile _ _FORWARD_PLUS
            // Transparency
            #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
            // Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON
            
            #pragma vertex Vert;
            #pragma fragment Frag;
            #include "./Librarys/Glass/Glass.hlsl"
            
            ENDHLSL
        }
        
    }
    CustomEditor "URPShaderEditor.GlassEditor"
}
