Shader "Unlit/VineURP"
{
    Properties
    {
	    _Cutoff( "Mask Clip Value", Float ) = 0.5
		_VineBaseColor("Vice_BaseColor", 2D) = "white" {}
		_VineNormalMap("Vice_NormalMap", 2D) = "bump" {}
		_VineRoughness("Vice_Roughness", 2D) = "white" {}
		_Grow("Grow", Range( -2 , 2)) = 0
		_GrouMin1("GrouMin", Range( 0 , 1)) = 0
		_GrowMax1("GrowMax", Range( 0 , 1.5)) = 0.9176471
		_EndMin1("EndMin", Range( 0 , 1)) = 0
		_EndMax1("EndMax", Range( 0 , 1.5)) = 0
		_Offset("Offset", Float) = 0
		_Scale("Scale", Float) = 0
    	[HideInspector]_DefaultTex("DefaultTex", 2D) = "white" {}
    }	
    
    SubShader
    {
        Tags {"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        Cull Off //双面显示打开，背面剔除关闭
        
        Pass
        {
        	Tags{"LightMode" = "UniversalForward"}
            Cull Back
            ZWrite On
            ZTest LEqual
            ZClip Off
        	
        	HLSLPROGRAM

        	
            // Render Paths
            // #pragma multi_compile _ _FORWARD_PLUS

            // Fog, Decals, SSAO
            // #pragma multi_compile_fog
            // #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            // #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
            //
            // // Transparency
            // #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
            // #pragma shader_feature_local_fragment _ALPHATEST_ON
            // #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            
            // Lighting
            // #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            // #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            // #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            // #pragma multi_compile _ _SHADOWS_SOFT

            // // Unity stuff
            // #pragma multi_compile_fragment _ _LIGHT_LAYERS
            // #pragma multi_compile_fragment _ _LIGHT_COOKIES
            // #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
            // #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            
            // // Lightmapping
            // #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            // #pragma multi_compile _ SHADOWS_SHADOWMASK
            // #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            // #pragma multi_compile _ LIGHTMAP_ON
            // #pragma multi_compile _ DYNAMICLIGHTMAP_ON

            // // Instancing
            // #pragma multi_compile_instancing
            // #pragma instancing_options renderinglayer
            // #pragma multi_compile _ DOTS_INSTANCING_ON
        	
        	#pragma vertex Vertex
            #pragma fragment Fragment
        	
        	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        	#include "./SamplePBR.hlsl"
        	
            CBUFFER_START(UnityPerMaterial)
                float _GrouMin1;
                float _GrowMax1;
                float _Grow;
                float _EndMin1;
                float _EndMax1;
        		float _Offset;
        		float _Scale;
        		float _Cutoff;
        		float4 _VineBaseColor_ST;
        		float4 _defaultColor;
            CBUFFER_END
            
        	TEXTURE2D(_VineBaseColor);
        	SAMPLER(sampler_VineBaseColor);
        	TEXTURE2D(_VineNormalMap);
        	SAMPLER(sampler_VineNormalMap);
        	TEXTURE2D(_VineRoughness);
        	SAMPLER(sampler_VineRoughness);
        	
        	Varyings Vertex(Attributes IN)
			{
        		float temp_output_68_0 = ( IN.uv.xy.y - _Grow);
				float smoothstepResult74 = smoothstep( _GrouMin1 , _GrowMax1 , temp_output_68_0);
				float smoothstepResult73 = smoothstep( _EndMin1 , _EndMax1 , IN.uv.xy.y);
				float3 ase_vertexNormal = IN.normalOS.xyz;
				IN.positionOS.xyz += ( ( max( smoothstepResult74 , smoothstepResult73 ) * ( ase_vertexNormal * 0.01 * _Offset ) ) + ( ase_vertexNormal * _Scale ) );
				IN.positionOS.w = 1;
        		return Vert(IN);
			}

            half4 Fragment(Varyings IN) : SV_Target
			{
				MaterialInputData inputData;
				InitMaterialInputData(inputData);
				inputData.baseMap = _VineBaseColor;
				inputData.samplerState = sampler_VineBaseColor; //
				inputData.baseMap_ST = _VineBaseColor_ST;
				inputData.normalMap = _VineNormalMap;
				float4 col = Frag(IN,inputData);
				float growClip = (IN.uv.y - _Grow);
				clip(( 1.0 - growClip) - _Cutoff);
				return col;
			}
        	
        	ENDHLSL
        }

    }

}
