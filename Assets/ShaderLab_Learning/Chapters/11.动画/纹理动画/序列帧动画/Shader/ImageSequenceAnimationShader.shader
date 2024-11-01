Shader "ShaderLab_Learning/ImageSequenceAnimationShader"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex("Image Sequence", 2D) = "white" {}
        _HorizontalNum("Horizontal Num", Float) = 4
        _VerticalNum("Vertical Num", Float) = 4
        _Speed("Speed", Float) = 1
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
            
            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _MainTex_ST;
                float _HorizontalNum;
                float _VerticalNum;
                float _Speed;
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
                OUT.uv = IN.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                return OUT;
            }

            float4 Frag(Varyings IN):SV_TARGET
            {
                float time = floor(_Time.y * _Speed);
                float row = floor(time / _HorizontalNum);
                float column = time - row * _VerticalNum;

                //UV-第一种算法
                /*
                 *  half2 uv = float2(IN.uv.x/ _HorizontalNum, IN.uv.y/ _VerticalNum);
                 *  uv.x += columu / _HorizontalNum;
                 *  uv.y -= row / _VerticalNum;
                 */
                //UV-第二中算法
                half2 uv = IN.uv + half2(column, -row);
                uv.x /= _HorizontalNum;
                uv.y /= _VerticalNum;

                float4 albedo  = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
                return albedo * _Color;
            }

            ENDHLSL
        }
      
    }
    FallBack "Diffuse"
}
