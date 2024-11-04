Shader "ShaderLab_Learning/BrightnessSaturationAndContrast"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
		_Brightness ("Brightness", Float) = 1
		_Saturation("Saturation", Float) = 1
		_Contrast("Contrast", Float) = 1
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        
        Pass
        {
            Tags{"LightMode" = "UniversalForward"}
            
            ZTest Always Cull Off ZWrite Off
            
            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)
                float _Brightness;
                float _Saturation;
                float _Contrast;
            CBUFFER_END

            #pragma vertex Vert;
            #pragma fragment Frag;

            struct Attributes
            {
                float4 positionOS: POSITION;
                float4 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS:SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings Vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.uv = IN.uv;
                return OUT;
                
            }

            float4 Frag(Varyings IN):SV_TARGET
            {
                float4 renderTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.uv);

                //Apply Brightness
                float3 finalColor = renderTex.rgb * _Brightness;

                //Apply Saturation
                float iuminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
                float3 iuminanceColor = float3(iuminance,iuminance,iuminance);
                finalColor = lerp(iuminanceColor,finalColor,_Saturation);

                //Apply contrast
                float3 avgColor = float3(0.5,0.5,0.5);
                finalColor = lerp(avgColor,finalColor,_Contrast);
               
                return float4(finalColor,renderTex.a);
            }

            ENDHLSL
        }
      
    }
    FallBack "Diffuse"
}
