Shader "ShaderLab_Learning/URP/BlinnPhong"
{
   Properties
    {
        _DiffuseColor ("Diffuse Color", Color) = (1,1,1,1)
        _Specular ("Specular",Color) = (1,1,1,1)
        _Gloss ("Gloss",Range(8.0,256)) = 20
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}
        
        Pass
        {
            Tags{"LightMode" = "UniversalForward"}
            
            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            CBUFFER_START(UnityPerMaterial)
                float4 _DiffuseColor;
                float4 _Specular;
                float _Gloss;
            CBUFFER_END

            #pragma vertex Vert;
            #pragma fragment Frag;

            struct Attributes
            {
                float4 positionOS: POSITION;
                float3 normalOS: NORMAL;
            };

            struct Varyings
            {
                float4 positionCS:SV_POSITION;
                float3 normalWS: TEXCOORD0;
                float3 positionWS:TEXCOORD1;
            };

            Varyings Vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.normalWS = normalize(OUT.normalWS);
                return OUT;
            }

            float4 Frag(Varyings IN):SV_TARGET
            {
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz; //场景中的环境光
                float3 lightDirWS = half3(_MainLightPosition.xyz);     //光照方向
                float3 diffuse = _MainLightColor.rgb * _DiffuseColor * saturate(dot(IN.normalWS,lightDirWS)); //漫反射光照

                //计算高光Blinn光照模型--避免计算光线反射(比较耗时）
                float3 viewDirWS = normalize(GetWorldSpaceViewDir(IN.positionWS));
                float3 halfDir = normalize(lightDirWS + viewDirWS); //半程向量
                float3 specular = _MainLightColor.rgb * _Specular*pow(saturate(dot(IN.normalWS,halfDir)),_Gloss);
                
                float3 color = ambient + diffuse  + specular;
                return float4(color,1);
            }

            ENDHLSL
        }
      
    }
    FallBack "Diffuse"
}
