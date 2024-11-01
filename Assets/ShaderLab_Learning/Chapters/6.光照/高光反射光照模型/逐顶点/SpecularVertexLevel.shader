Shader "ShaderLab_Learning/URP/SpecularVertexLevel"
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
                float3 color: TEXCOORD0;
            };

            Varyings Vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz; //场景中的环境光
                float3 normalWS = TransformObjectToWorld(IN.normalOS); //世界法线
                float3 lightDirWS = half3(_MainLightPosition.xyz);     //光照方向
                float3 diffuse = _MainLightColor.rgb * _DiffuseColor * saturate(dot(normalWS,lightDirWS)); //漫反射光照

                //计算高光
                float3 reflectDir = normalize(reflect(-lightDirWS,normalWS));
                float3 positionWS = TransformObjectToWorld(IN.positionOS);
                float3 viewDirWS = normalize(GetWorldSpaceViewDir(positionWS));
                float3 specular = _MainLightColor.rgb * _Specular*pow(saturate(dot(reflectDir,viewDirWS)),_Gloss);
                OUT.color = ambient + diffuse + specular; //Phong模型
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
