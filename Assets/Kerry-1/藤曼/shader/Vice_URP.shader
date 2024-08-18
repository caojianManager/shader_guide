Shader "Unlit/VineURP"
{
    Properties
    {
	    _Cutoff( "Mask Clip Value", Float ) = 0.5
	    _defaultTex("_defaultTex", 2D) = "white" {}
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
		[HideInInspector] _Default( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
    }
    
    SubShader
    {
        Tags {"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        Cull Off //双面显示打开，背面剔除关闭
        
        Pass
        {
        	Tags{"LightMode" = "UniversalForward"}
	        
        	HLSLPROGRAM
        	
        	#pragma vertex Vertex
            #pragma fragment Fragment
        	
        	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        	#include "Assets/Shaders/URP/Library/SamplePBR.hlsl"
        	
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
            CBUFFER_END

        	TEXTURE2D(_defaultTex);
        	SAMPLER(sampler_defaultTex);
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
				inputData.baseMap_ST = _VineBaseColor_ST;
				inputData.samplerState = sampler_VineBaseColor; //
				

				float col = Frag(IN,inputData);
				float growClip = (IN.uv.y - _Grow);
				clip(( 1.0 - growClip) - _Cutoff);
				return col;
			}
        	
        	ENDHLSL
        }

    }

}
