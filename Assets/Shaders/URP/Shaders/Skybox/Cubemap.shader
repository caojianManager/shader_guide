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

	        struct Attributes
	        {
		        float4 positionOS : POSITION;
        		float4 color : COLOR;
        		UNITY_VERTEX_INPUT_INSTANCE_ID
	        };

	        struct Varyings
	        {
		        float4 positionCS : SV_POSITION;
	        	float3 positionWS : TEXCOORD0;
	        	float4 tex1 : TEXCOORD1;
	        	float4 tex2 : TEXCOORD2;

	        	UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
	        };

        	TEXTURECUBE(_Cubemap);
        	SAMPLER(sampler_Cubemap);
        	
        	CBUFFER_START(UnityPerMaterial)
        		float _CubemapExposure;
        		float4  _CubemapTintColor;
        		float _CubemapPosition;
        		float _RotationEnable;
        		float _Rotation;
        		float _RotationSpeed;
        		float _FogEnable;
        		float _FogIntensity;
        		float _FogHeight;
        		float _FogSmoothness;
        		float _FogFill;
        		float _FogPosition;
        	CBUFFER_END

        	Varyings Vert(Attributes IN)
        	{
        		Varyings OUT;
        		UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);

        		//正交摄像机做插值lerp(1,(正交摄像机高度/正交摄像机的宽度),unity_OrthoParams.w)  --- w在摄像机为正交模式时是1.0,而在摄像机为透视模式时是0.0
        		float orthoParamsLerp = lerp(1,(unity_OrthoParams.y/unity_OrthoParams.x),unity_OrthoParams.w);

        		float3 aR1 = float3(IN.positionOS.x,IN.positionOS.y*orthoParamsLerp,IN.positionOS.z);
        		float3 aR2 = float3(0, -_CubemapPosition,0);
        		float3 aR3 = float3(0,aR1.y,0);
        		float3 aR4 = float3(aR1.x,0,aR1.z);

        		float angle = 1 - radians(_Rotation + (_Time.y * _RotationSpeed));
				float3 switch1 = aR1 + aR2;

        		OUT.tex1 = float4(switch1.xyz,0);
        		OUT.tex2 = IN.positionOS;
        		OUT.positionWS = TransformObjectToWorld(IN.positionOS);
        		OUT.positionCS = TransformObjectToHClip(IN.positionOS);
        		return OUT;
        	}

        	half4 Frag(Varyings IN):SV_Target
        	{
        		UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
        		half4 finalCol;
        		half4 cubeMap =  SAMPLE_TEXTURECUBE(_Cubemap,sampler_Cubemap,IN.tex1.xyz);
        		#ifdef UNITY_COLORSPACE_GAMMA
        		float4 unity_ColorSpacDouble = float4(2.0, 2.0, 2.0, 2.0);
				#else
        		float4 unity_ColorSpacDouble = (4.59479380, 4.59479380, 4.59479380, 2.0);
        		#endif
        		
        		half4 decodeHDR = half4(DecodeHDREnvironment(cubeMap,unity_SpecCube0_HDR),1);
        		decodeHDR *= unity_ColorSpacDouble * _CubemapTintColor * _CubemapExposure;
			
        		float re1 = lerp(saturate(pow(0.0 + (abs(IN.tex2.y - _FogPosition) - 0) * 1 / _FogHeight, 1 - _FogSmoothness)),0,_FogFill);
				float fogMask = lerp(1, re1, _FogIntensity);
        		float4 lerp3 = lerp(unity_FogColor,decodeHDR,fogMask);

        		finalCol = half4(decodeHDR.xyz,1);
        		if(_FogEnable)
        		{
        			finalCol = lerp3;
        		}
        		return finalCol;
        	}
        	
        	ENDHLSL
        }
    }
	Fallback "Skybox/Cubemap"
}