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
		        float3 positionOS : POSITION;
        		float4 color : COLOR;
        		UNITY_VERTEX_INPUT_INSTANCE_ID
	        };

	        struct Varyings
	        {
		        float4 positionCS : SV_POSITION;
	        	float3 positionWS : TEXCOORD0;
	        	float4 uv : TEXCOORD1;
	        	float3 positionOS : TEXCOORD2;

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

        	float4 GetUnityColorSpacDouble()
        	{
        		#ifdef UNITY_COLORSPACE_GAMMA
        		return  float4(2.0, 2.0, 2.0, 2.0);
				#else
        		return float4(4.59479380, 4.59479380, 4.59479380, 2.0);
        		#endif
        	}

        	Varyings Vert(Attributes IN)
        	{
        		Varyings OUT;
        		UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);

        		float3 cubemap_uv;
        		//计算Cubemap采样坐标UV
        		//正交摄像机做插值lerp(1,(正交摄像机高度/正交摄像机的宽度),unity_OrthoParams.w)  --- w在摄像机为正交模式时是1.0,而在摄像机为透视模式时是0.0
        		float orthoParamsLerp = lerp(1,(unity_OrthoParams.y/unity_OrthoParams.x),unity_OrthoParams.w);
        		float3 lerp_positionOS = float3(IN.positionOS.x,IN.positionOS.y*orthoParamsLerp,IN.positionOS.z);
        		cubemap_uv = float3(lerp_positionOS.x,lerp_positionOS.y - _CubemapPosition, lerp_positionOS.z);

        		//旋转
        		if(_RotationEnable)
        		{
        			float3 lerpPositionY = float3(0,lerp_positionOS.y,0);
        			float3 nlerpPositionY = float3(lerp_positionOS.x,0,lerp_positionOS.z);
        			float rotation_angle = 1 - radians(_Rotation + (_Time.y * _RotationSpeed));
        			cubemap_uv = ((lerpPositionY + (nlerpPositionY * cos(rotation_angle))) + (cross(float3(0,1,0), nlerpPositionY))* sin(rotation_angle)) + lerpPositionY;
        		}
        		
        		OUT.uv = float4(cubemap_uv.xyz,0);
        		OUT.positionOS = IN.positionOS;
        		OUT.positionWS = TransformObjectToWorld(IN.positionOS);
        		OUT.positionCS = TransformObjectToHClip(IN.positionOS);
        		return OUT;
        	}

        	half4 Frag(Varyings IN):SV_Target
        	{
        		UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
        		//采样
        		half4 cubeMap =  SAMPLE_TEXTURECUBE(_Cubemap,sampler_Cubemap,IN.uv.xyz);
        		//计算HDR解码后的颜色
        		half4 decodeHDR = half4(DecodeHDREnvironment(cubeMap,unity_SpecCube0_HDR),1);
        		decodeHDR *= GetUnityColorSpacDouble() * _CubemapTintColor * _CubemapExposure;
        		//计算FogMask
        		float maskLerpMax = lerp(saturate(pow(abs(IN.positionOS.y - _FogPosition)/_FogHeight, 1-_FogSmoothness)),0,_FogFill);
				float fogMask = lerp(1, maskLerpMax, _FogIntensity);

        		cubeMap = half4(decodeHDR.xyz,1);
        		if(_FogEnable)
        		{
        			cubeMap = lerp(unity_FogColor,decodeHDR,fogMask);
        		}
        		return cubeMap;
        	}
        	
        	ENDHLSL
        }
    }
	Fallback "Skybox/Cubemap"
}