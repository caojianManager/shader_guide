Shader "ShaderLab_Learning/NormalMapTangentSpace"
{
    Properties
    {
        _Color("Color Tint", Color) = (1,1,1,1)
        _MainTex("Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "white" {}  //法线贴图
        _NormalScale("Normal Scale", Float) = 1   //法线缩放--控制凹凸程度
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
                float3 normal : NORMAL;         //顶点法线
                float4 tangent : TANGENT;       //顶点切线
                float4 uv : TEXCOORD0;          //纹理坐标
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION; //裁剪空间下顶点坐标
                float4 uv : TEXCOORD0;           //纹理坐标
                float3 lightDir : TEXCOORD1;     //光照方向
                float3 viewDir : TEXCOORD2;      //观察方向
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                VertexPositionInputs position_inputs = GetVertexPositionInputs(IN.positionOS);
                VertexNormalInputs normal_inputs = GetVertexNormalInputs(IN.normal);
                OUT.positionCS = position_inputs.positionCS;
                //uv.xy 保存_MainTex的缩放和平移后的纹理坐标；uv.zw 保存_NormalMap的缩放和平移后的纹理坐标
                OUT.uv.xy = IN.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                OUT.uv.zw = IN.uv.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
                OUT.lightDir = normal_inputs.
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                return 0;
            }
            
            ENDHLSL
        }
    }
}
