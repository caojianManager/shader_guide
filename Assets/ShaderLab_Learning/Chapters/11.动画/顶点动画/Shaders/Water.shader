Shader "ShaderLab_Learning/Water"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_Magnitude ("Distortion Magnitude", Float) = 1
 		_Frequency ("Distortion Frequency", Float) = 1
 		_InvWaveLength ("Distortion Inverse Wave Length", Float) = 10
 		_Speed ("Speed", Float) = 0.5
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent"  "IgnoreProjector"="True" "DisableBatching"="True"}
        
        Pass
        {
            Tags{"LightMode" = "UniversalForward"}
            
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            
            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _MainTex_ST;
                float _Magnitude;
                float _Frequency;
                float _InvWaveLength;
                float _Speed;
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

                float4 offset;
                offset.yzw = float3(0.0,0.0,0.0);
                offset.x =  sin(_Frequency * _Time.y + IN.uv.x * _InvWaveLength + IN.uv.y * _InvWaveLength + IN.uv.z * _InvWaveLength) * _Magnitude;
                
                OUT.positionCS = TransformObjectToHClip(IN.positionOS + offset);
                OUT.uv = TRANSFORM_TEX(IN.uv,_MainTex);
                OUT.uv +=  float2(0.0,_Time.y * _Speed);
                return OUT;
                
            }

            float4 Frag(Varyings IN):SV_TARGET
            {
                float4 col = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.uv);
                col.rgb  *= _Color.rgb;
                return col;
            }

            ENDHLSL
        }
      
    }
    FallBack "Diffuse"
}
