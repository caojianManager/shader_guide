Shader "ShaderLab_Learning/URP/HalfLambert"
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
                float3 color: TEXCOORD0;
            };

            Varyings Vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz; //场景中的环境光
                float3 normalWS = TransformObjectToWorld(IN.normalOS); //世界法线
                float3 lightDirWS = half3(_MainLightPosition.xyz);     //光照方向
                float3 halfLambert = saturate(dot(normalWS,lightDirWS))*0.5 +0.5;
                float3 diffuse = _MainLightColor.rgb * _DiffuseColor * halfLambert; //漫反射光照
                OUT.color = ambient + diffuse; //半兰伯特光照模型
                return OUT;
            }

            float4 Frag(Varyings IN):SV_TARGET
            {
                return float4(IN.color,1);
            }

            ENDHLSL
        }
      
    }
    FallBack "Diffuse"
}
