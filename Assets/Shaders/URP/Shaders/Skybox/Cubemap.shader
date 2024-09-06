Shader "CURP/Skybox/Cubemap"
{
    Properties
    {
        //cubemap
        _Cubemap("Cubemap", CUBE) = "black" {}
        _CubemapExposure("Cubemap Exposure",Range(0,8)) = 1.0
        _CubemapTintColor("Cubemap Tint Color",Color) = (1,1,1,1)
        _CubemapPosition("Cubemap Position",Float) = 1
        
        //Rotation Settings
        [Toggle(_RotationEnable)] _RotationEnable("Rotation Enable",Float) = 0 
        _Rotation("Rotation",Range(0,360)) = 0
        _RotationSpeed("Rotation Speed",Float) = 1
        
        //Fog Settings
        [Toggle(_FogEnable)] _FogEnable("Fog Enable",Float) = 0
        _FogIntensity("Fog Intensity",Range(0,1)) = 1
        _FogHeight("Fog Height",Range(0,1)) = 1
        _FogSmoothness("Fog Smoothness",Range(0.1,1)) = 1
        _FogFill("Fog Fill",Range(0,1)) = 1
        _FogPosition("Fog Position",Float) = 0
    }
    
    SubShader
    {
    	Tags { "RenderType"="Background" "Queue"="Background" "PreviewType"="Skybox" }
        LOD 0
        
        Blend Off
		AlphaToMask Off
		Cull Off
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
			
        Pass
        {
       
        	HLSLPROGRAM

        	#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
        	
			#pragma multi_compile_instancing
        	#pragma multi_compile_fog

        	#pragma vertex Vert
        	#pragma fragment Frag
			#include "../../Librarys/Skybox/Cubemap.hlsl"
        	
        	ENDHLSL
        }
    }
	CustomEditor "URPShaderEditor.Skybox.CubemapEditorGUI"
	Fallback "Skybox/Cubemap"
}