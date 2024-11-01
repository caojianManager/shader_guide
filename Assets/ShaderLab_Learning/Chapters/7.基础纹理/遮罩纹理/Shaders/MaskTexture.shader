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
                float3 lightDirTS : TEXCOORD1;
                float3 viewDirTS : TEXCOORD2;
            };

            Varyings Vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.uv = IN.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                 //世界空间的法线
                 float3 normalWS = TransformObjectToWorldNormal(IN.normalOS);
                 //世界空间的切线
                 float3 tangentWS = TransformObjectToWorldDir(IN.tangentOS.xyz);
                 //世界空间的副切线
                 float3 bitangentWS = cross(normalWS, tangentWS) * IN.tangentOS.w;
                 //创建切线空间矩阵
                 float3x3 tangentToWorld = float3x3(tangentWS,bitangentWS,normalWS);
                
                 float3 positionWS = TransformObjectToWorld(IN.positionOS);
                
                 //获取世界空间的光照方向
                 float3 lightDirectionWS = half3(_MainLightPosition.xyz);
                 //世界空间的观看方向
                 float3 viewDirectionWS = GetWorldSpaceViewDir(positionWS);
                
                // 计算切线空间下的光照方向
                 OUT.lightDirTS = mul(tangentToWorld, lightDirectionWS);
                 //计算切线空间下的观察方向
                 OUT.viewDirTS = mul(tangentToWorld, viewDirectionWS);

                
                return OUT;
            }

            half4 Frag(Varyings IN):SV_Target
            {
                float3 lightDirTS = normalize(IN.lightDirTS);
                float3 viewDirTS = normalize(IN.viewDirTS);
                
                float4 normalMap = SAMPLE_TEXTURE2D(_BumpMap,sampler_BumpMap,IN.uv);
                float3 normalTS = UnpackNormal(normalMap); //等同于 (normalMap.xy * 2 - 1)
                normalTS.xy *= _BumpScale;
                normalTS.z = sqrt(1.0 - saturate(dot(normalTS.xy, normalTS.xy)));
                
                float3 albedo = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.uv) * _Color.rgb;
                
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz; //场景中的环境光
                
                float3 diffuse = _MainLightColor.rgb * albedo * saturate(dot(normalTS,lightDirTS)); //漫反射光照
                
                float3 halfDir = normalize(lightDirTS + viewDirTS); //半程向量
                
                //遮罩纹理
                float specularMask = SAMPLE_TEXTURE2D(_SpecualrMask,sampler_SpecualrMask,IN.uv).r *  _SpecualrScale;
                
                float3 specular = _MainLightColor.rgb * _Specualr *pow(saturate(dot(normalTS,halfDir)),_Gloss) * specularMask;
                
                float3 color = ambient + diffuse  + specular;
                return float4(color,1.0f);
            }

            ENDHLSL
        }
      
    }
    FallBack "Diffuse"
}
