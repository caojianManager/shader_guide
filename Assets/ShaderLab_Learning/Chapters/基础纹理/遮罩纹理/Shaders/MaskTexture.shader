Shader "ShaderLab_Learning/MaskTexture"
{
    Properties
    {
        _Color("Color Tint",Color) = (1,1,1,1)
        _MainTex("Main Tex",2D) = "white" {}
        _BumpMap("Bump Map",2D) = "white" {}
        _BumpScale("Bump Scale",Float) = 1.0
        _SpecualrMask("Specualr Mask",2D) = "white" {}
        _SpecualrScale("Specualr Scale",Float) = 1.0
        _Specualr ("Specualr",Color) =  (1,1,1,1)
        _Gloss("Gloss",Range(8.0,256)) = 20.0
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}
        
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            
            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_BumpMap);
            SAMPLER(sampler_BumpMap);
            TEXTURE2D(_SpecualrMask);
            SAMPLER(sampler_SpecualrMask);
            
            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _Specualr;
                float _BumpScale;
                float _Gloss;
                float _SpecualrScale;
                float4 _MainTex_ST;
            CBUFFER_END

            #pragma vertex Vert;
            #pragma fragment Frag;

            struct Attributes
            {
                float4 positionOS: POSITION;
                float3 normalOS: NORMAL;
                float4 tangentOS: TANGENT;
                float4 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS:SV_POSITION;
                float2 uv: TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            Varyings Vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.uv = IN.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                
                OUT.lightDir = half3(_MainLightPosition.xyz);
                float3 positionWS = TransformObjectToWorld(IN.positionOS);
                OUT.viewDir = normalize(GetWorldSpaceViewDir(positionWS));
                return OUT;
            }

            float4 Frag(Varyings IN):SV_TARGET
            {
                float3 lightDirTS = TransformWorldToTangent(IN.lightDir,);
                float3 viewDirTS = TransformWorldToTangent(IN.viewDir);
                return float4(IN.color,1);
            }

            ENDHLSL
        }
      
    }
    FallBack "Diffuse"
}
