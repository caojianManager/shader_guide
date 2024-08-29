Shader "ShaderLab_Learning/URP/NormalMapWorldSpace"
{
    Properties
    {
        _Color("Color Tint", Color) = (1,1,1,1)
        _MainTex("Main Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "white" {}  //法线贴图
        _NormalScale("Normal Scale", Float) = 1   //法线缩放--控制凹凸程度,为0时法线纹理不会对光照产生影响
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8.0,256)) = 20
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
            
            #pragma vertex vert;
            #pragma fragment frag;

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);

            CBUFFER_START(UnityMatVar)
                float4 _Color;
                float _NormalScale;
                float4 _Specular;
                float _Gloss;
                float4 _MainTex_ST;
                float4 _NormalMap_ST;
            CBUFFER_END
            
            struct Attributes
            {
                float4 positionOS : POSITION;   //模型空间中顶点坐标
                float3 normalOS : NORMAL;         //顶点法线
                float4 tangentOS : TANGENT;       //顶点切线
                float4 uv : TEXCOORD0;          //纹理坐标
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION; //裁剪空间下顶点坐标
                float4 uv : TEXCOORD0;           //纹理坐标
                //切线空间转换世界空间的变换矩阵  每一个代表矩阵每一行，3*3矩阵，w分量保存世界空间顶点w分量。
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                
                VertexPositionInputs position_inputs = GetVertexPositionInputs(IN.positionOS);
                OUT.positionCS = position_inputs.positionCS;
                
                //uv.xy 保存_MainTex的缩放和平移后的纹理坐标；   uv.zw保存_NormalMap的缩放和平移后的纹理坐标
                OUT.uv.xy = IN.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                OUT.uv.zw = IN.uv.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;

                //世界空间的法线
                float3 normalWS = TransformObjectToWorldNormal(IN.normalOS);
                //世界空间的切线
                float3 tangentWS = TransformObjectToWorldDir(IN.tangentOS.xyz);
                //世界空间的副切线
                float3 bitangentWS = cross(normalWS, tangentWS) * IN.tangentOS.w;

                //TtoWo, TtoW1, TtoW2 组成了切线空间到世界空间的变换矩阵。 w分量记录顶点世界空间坐标
                OUT.TtoW0 = float4(tangentWS.x, bitangentWS.x, normalWS.x, position_inputs.positionWS.x);
                OUT.TtoW1 = float4(tangentWS.y, bitangentWS.y, normalWS.y, position_inputs.positionWS.y);
                OUT.TtoW2 = float4(tangentWS.z, bitangentWS.z, normalWS.z, position_inputs.positionWS.z);
                
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
               
                float3 positionWS = float3(IN.TtoW0.w, IN.TtoW1.w, IN.TtoW2.w);
                
                //获取世界空间的光照方向
                Light light = GetMainLight();
                float3 lightDir = normalize(light.direction);
                float3 viewDir = normalize(GetWorldSpaceViewDir(positionWS));
                
                float4 normalMap = SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,IN.uv.zw);
                float3 normalTS = UnpackNormal(normalMap); //等同于 (normalMap.xy * 2 - 1)
                normalTS.xy *= _NormalScale;
                normalTS.z = sqrt(1.0 - saturate(dot(normalTS.xy, normalTS.xy)));
                //切线空间法线转换到世界空间法线
                float3 normalWS = normalize(float3(dot(IN.TtoW0.xyz, normalTS), dot(IN.TtoW1.xyz, normalTS), dot(IN.TtoW2.xyz, normalTS)));

                float3 albedo = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.uv.xy).rgb * _Color.rgb;
                //环境光
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                //漫反射
                float3 diffuse = _MainLightColor.rgb * albedo * max(0,dot(normalWS, lightDir));
                //半程向量
                float3 halfDir = normalize(lightDir + viewDir);
                
                //Blinn-Phone光照模型
                float3 specular = _MainLightColor.rgb * _Specular.rgb * pow(max(0, dot(normalWS, halfDir)),_Gloss);
                return float4(ambient + diffuse + specular, 1.0);
            }
            
            ENDHLSL
        }
    }
}
