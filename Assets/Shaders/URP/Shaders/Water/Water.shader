Shader "CURP/Water"
{
    Properties
    {
        //WaterColor
        _ShallowColor("Shallow Color",Color) = (1,1,1,1)
        _DeepColor("Deep Color",Color) = (1,1,1,1)
        _DeepRange("Deep Range",Range(0,100)) = 1
        //菲涅颜色，平视的时候让水平面颜色有个过渡
        _FresnelColor("Fresnel Color",Color) = (1,1,1,1)
        _FresnelPower("Fresnel Power",Range(0.1,20)) = 1
        //Surface Normal
        _NormalMap("Normal Map",2D) = "white" {}
        _NormalSpeed("Normal Speed",Vector) = (1,1,1,1)
        _NormalScale("Normal Scale",Range(0,6)) = 1
        
        _ReflectDistortion("Reflect Distortion",Range(0,1)) = 1
        _ReflectPower("Reflect Power",Float) = 1
        _ReflectIntensity("Reflect Intensity",Float) = 1
        _GlossPower("Gloss Power",Float) = 1 //高光强度
        
        _UnderWaterDistort("UnderWater Distort",Float) = 1
        
        //焦散效果
        _CausticsMap("Caustics Map",2D) = "white" {}
        _CausticsScale("Caustics Scale",Float) = 1
        _CausticsSpeed("Caustics Speed",Vector) = (0,0,0,0)
        _CausticsIntensity("Caustics Intensity",Float) = 1
        _CausticsRange("Caustics Range",Range(0,100)) = 1

    }
    SubShader
    {
        Tags {"RenderType"="Transparent" "RenderPipeline" = "UniversalPipeline"}

        Cull Off
        ZWrite Off
        ZTest LEqual
        Blend SrcAlpha OneMinusSrcAlpha
        
        Pass
        {
            Tags {"LightMode" = "UniversalForwardOnly" "RenderQueue" = "Transparent" }
            
            HLSLPROGRAM
            #include "../../Librarys/Water/Water.hlsl"
            #pragma vertex Vert;
            #pragma fragment Frag;
            ENDHLSL
        }
    }
    CustomEditor "URPShaderEditor.WaterEditorGUI"
}
