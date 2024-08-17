Shader "Unlit/VineURP"
{
    Properties
    {
	    _Cutoff( "Mask Clip Value", Float ) = 0.5
		_VineBaseColor("Vice_BaseColor", 2D) = "white" {}
		_VineNormalMap("Vice_NormalMap", 2D) = "bump" {}
		_VineRoughness("Vice_Roughness", 2D) = "white" {}
		_Grow1("Grow", Range( -2 , 2)) = 0
		_GrouMin1("GrouMin", Range( 0 , 1)) = 0
		_GrowMax1("GrowMax", Range( 0 , 1.5)) = 0.9176471
		_EndMin1("EndMin", Range( 0 , 1)) = 0
		_EndMax1("EndMax", Range( 0 , 1.5)) = 0
		_Offset("Offset", Float) = 0
		_Scale("Scale", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
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
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
        	
            CBUFFER_START(UnityPerMaterial)
                float _GrouMin1;
                float _GrowMax1;
                float _Grow;
                float _EndMin1;
                float _EndMax1;
        		float _Offset;
        		float _Scale;
        		float _Cutoff;
            CBUFFER_END

        	TEXTURE2D(_VineBaseColor);
        	SAMPLER(sampler_VineBaseColor);
        	TEXTURE2D(_VineNormalMap);
        	SAMPLER(sampler_VineNormalMap);
        	TEXTURE2D(_VineRoughness);
        	SAMPLER(sampler_VineRoughness);

	        struct  Atrributes
	        {
		        float4 positionOS : POSITION;
	        	float2 uv : TEXCOORD0;
	        };

	        struct Varyings
	        {
	        	float4 positionCS : SV_POSITION;
		        float2 uv : TEXCOORD0;
	        	float3 positionWS : TEXCOORD1;
	        };

        	Varyings Vertex(Atrributes IN)
			{
        		Varyings OUT;
        		float growValue = smoothstep( _GrouMin1 , _GrowMax1 ,(IN.uv.xy.y - _Grow));
            	float endValue = smoothstep(_EndMin1, _EndMax1 , IN.uv.xy.y);
				float weightValue = max(growValue, endValue);

        		VertexPositionInputs position_inputs = GetVertexPositionInputs(IN.positionOS);
        		OUT.positionCS = position_inputs.positionCS;
        		OUT.positionWS = position_inputs.positionWS;
        		OUT.uv = IN.uv;
        		return OUT;
			}
        	

            half4 Fragment(Varyings IN) : SV_Target
			{
				half4 baseMap = SampleAlbedoAlpha(IN.uv,_VineBaseColor,sampler_VineBaseColor);
				half3 normalMap = SampleNormal(IN.uv,_VineNormalMap,sampler_VineNormalMap);
				half4 normalColor = half4(normalMap, 1);
				return baseMap + normalColor;
			}
        	
        	ENDHLSL
        }

    }
//	 CustomEditor "UltimateLitShader.Editor.LitMaterialEditorGUI"

}
