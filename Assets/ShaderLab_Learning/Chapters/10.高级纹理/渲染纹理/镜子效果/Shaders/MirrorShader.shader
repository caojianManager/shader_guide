Shader "ShaderLab_Learning/MirrorShader"
{
    Properties
    {
        _MainTex("Main Tex",2D) = "white" {}

    }
    SubShader
    {
        Tags {"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}
        
        Pass
        {

            
            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
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
                OUT.uv.x = 1 - OUT.uv.x;
                return OUT;
            }

            half4 Frag(Varyings IN):SV_Target
            {
                   
                half4 color = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.uv);
                return color;
            }

            ENDHLSL
        }
      
    }
    FallBack "Diffuse"
}
