Shader "CURP/Water"
{
    Properties
    {
        //WaterColor
        _ShallowColor("Shallow Color",Color) = (1,1,1,1)
        _DeepColor("Deep Color",Color) = (1,1,1,1)
        _DeepRange("Deep Range",Range(0,100)) = 1
        //菲你颜色，平视的时候让水平面颜色有个过渡
        _FresnelColor("Fresnel Color",Color) = (1,1,1,1)
        _FresnelPower("Fresnel Power",Float) = 1
        //Surface Normal
        _NormalMap("Normal Map",2D) = "white" {}
        _NormalSpeed("Normal Speed",Vector) = (1,1,1,1)
        _NormalScale("Normal Scale",Float) = 1
        
        _DiffuseColor("Diffuse Color",Color) = (1,1,1,1)
        _SpecularColor("Specular Color",Color) = (1,1,1,1)
        _ReflectDistortion("Reflect Distortion",Range(0,1)) = 1
        _ReflectPower("Reflect Power",Float) = 1
        _ReflectIntensity("Reflect Intensity",Float) = 1

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

}
