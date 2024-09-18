Shader "ShaderLab_Learning/URP/DiffusePixelLevel"
{
    Properties
    {
        _DiffuseColor ("Diffuse Color", Color) = (1,1,1,1)
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
            };

            Varyings Vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.normalWS = TransformObjectToWorld(IN.normalOS); //世界法线
                return OUT;
            }

            float4 Frag(Varyings IN):SV_TARGET
            {
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                float3 normalWS = normalize(IN.normalWS);
                float3 lightDir = half3(_MainLightPosition.xyz);
                float3 diffuse = _MainLightColor * _DiffuseColor * saturate(dot(normalWS,lightDir));
                float3 color = ambient + diffuse; //兰伯特光照模型  环境光+漫反射
                return float4(color,1);
            }

            ENDHLSL
        }
      
    }
    FallBack "Diffuse"
}
