Shader "ShaderLab_Learning/URP/RampTextureShader"
{
    Properties
    {
        _Color ("Color Tint",Color) = (1,1,1,1)
        _RampTex ("Ramp Tex",2D) = "white" {}
        _Specular ("Specualr",Color) = (1,1,1,1)
        _Gloss ("Gloss",Range(8.0,256)) = 20
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}

        Pass
        {
            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_RampTex);
            SAMPLER(sampler_RampTex);

            CBUFFER_START(UnityMatVar)
                float4 _Color;
                float4 _Specular;
                float _Gloss;
                float4 _RampTex_ST;
            CBUFFER_END
            
            struct Atrributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 uv : TEXCOORD0;
            };

            struct Varings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            #pragma vertex Vert;
            #pragma fragment Frag;

            Varings Vert(Atrributes IN)
            {
                Varings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS);
                OUT.normalWS = TransformObjectToWorld(IN.normalOS);
                OUT.uv = TRANSFORM_TEX(IN.uv,_RampTex); //用内置的TRANSFORM_TEX宏来计算经过平铺和偏移后的纹理坐标 
                return OUT;
            }

            half4 Frag(Varings IN) : SV_Target
            {
                float3 normalWS = normalize(IN.normalWS);

                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz; //场景中的环境光
                float3 lightDirWS = half3(_MainLightPosition.xyz);     //光照方向
                float halfLambert = 0.5 * dot(normalWS,lightDirWS) + 0.5;
                float3 diffuseColor = SAMPLE_TEXTURE2D(_RampTex,sampler_RampTex,float2(halfLambert,halfLambert)).rgb * _Color;

                float3 diffuse = _MainLightColor.rgb * diffuseColor;
                
                //计算高光Blinn光照模型--避免计算光线反射(比较耗时）
                float3 viewDirWS = normalize(GetWorldSpaceViewDir(IN.positionWS));
                float3 halfDir = normalize(lightDirWS + viewDirWS); //半程向量
                float3 specular = _MainLightColor.rgb * _Specular*pow(saturate(dot(IN.normalWS,halfDir)),_Gloss);
                
                float3 color = ambient + diffuse  + specular;
                return half4(color,1);
            }
            
            ENDHLSL
        }
    }
}
