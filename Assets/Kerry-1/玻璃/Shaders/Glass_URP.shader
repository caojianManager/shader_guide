Shader "Unlit/GlassURP"
{
    Properties
    {
    	//使用matcap模拟反射效果
    	_MatcapMap("MatcapMap", 2D) = "white" {}  
    	[HideInspector] _DefaultTex("DefaultTex", 2D) = "white" {}
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
        	
        	#pragma vertex Vertex
            #pragma fragment Fragment
        	
        	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        	#include "Assets/Shaders/URP/Library/SamplePBR.hlsl"

        	TEXTURE2D(_MatcapMap);
        	SAMPLER(sampler_MatcapMap);
        	
            CBUFFER_START(UnityPerMaterial)
      
            CBUFFER_END

        	
        	Varyings Vertex(Attributes IN)
			{
            	Varyings OUT;
				OUT = Vert(IN);
            	float2 normalVS_XY = mul(unity_WorldToCamera, OUT.normalWS).xy * 0.5 + 0.5;
            	OUT.uv = normalVS_XY;
        		return OUT;
			}

            half4 Fragment(Varyings IN) : SV_Target
			{
				MaterialInputData inputData;
				InitMaterialInputData(inputData);
				inputData.emissionMap = _MatcapMap;
				float4 col = Frag(IN,inputData);
				return col;
			}
        	
        	ENDHLSL
        }

    }

}
