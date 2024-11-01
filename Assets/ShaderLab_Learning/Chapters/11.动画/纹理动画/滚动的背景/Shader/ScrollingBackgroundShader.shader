Shader "ShaderLab_Learning/ScrollingBackgroundShader"
{
    Properties
    {
        _MainTex("Base Layer (RGB)", 2D) = "white" {}
        _DetialTex("2nd Layer (RGB)", 2D) = "white" {}
        _ScrollX("Base Layer Scroll Speed", Float) = 1.0
        _Scroll2X("2nd Layer Scroll Speed", Float) = 1.0
        _Multiplier("Layer Multiplier", Float) = 1.0
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent"}
        
        Pass
        {
            Tags{"LightMode" = "UniversalForward"}
            
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            
            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_DetialTex);
            SAMPLER(sampler_DetialTex);
            
            CBUFFER_START(UnityPerMaterial)
                float _ScrollX;
                float _Scroll2X;
                float _Multiplier;
                float4 _MainTex_ST;
                float4 _DetialTex_ST;
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
                float4 uv : TEXCOORD0;
            };

            Varyings Vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.uv .xy = TRANSFORM_TEX(IN.uv,_MainTex) + frac(float2(_ScrollX,0.0) * _Time.y);
                OUT.uv.zw = TRANSFORM_TEX(IN.uv,_DetialTex) + frac(float2(_Scroll2X,0.0) * _Time.y);
                return OUT;
            }

            float4 Frag(Varyings IN):SV_TARGET
            {
                float4 firstLayer  = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv.xy);
                float4 secondLayer = SAMPLE_TEXTURE2D(_DetialTex, sampler_DetialTex, IN.uv.zw);
                float4 col = lerp(firstLayer,secondLayer,secondLayer.a);
                return col;
            }

            ENDHLSL
        }
      
    }
    FallBack "Diffuse"
}
