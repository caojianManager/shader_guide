Shader "ShaderLab_Learning/BillboardShader"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_VerticalBillboarding ("Vertical Restraints", Range(0, 1)) = 1 
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"  "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True"}
        
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
                float _VerticalBillboarding;
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

                float3 center = float3(0.0,0.0,0.0);
                float viewer = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos,1));

                float3 normalDir = viewer - center;
                normalDir.y = normalDir.y * _VerticalBillboarding;
                normalDir = normalize(normalDir);

                float3 upDir = abs(normalDir.y) > 0.999 ? float3(0,0,1) : float3(0,1,0);
                float3 rightDir = normalize(cross(upDir, normalDir));
                upDir = normalize(cross(normalDir,rightDir));

                float3 centerOffset = IN.uv.xyz - center;
                float3 localPos = center + rightDir * centerOffset.x + upDir * centerOffset.y + normalDir * centerOffset.z;
                
                OUT.positionCS = TransformObjectToHClip(float4(localPos,1));
                OUT.uv = IN.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                return OUT;
            }

            float4 Frag(Varyings IN):SV_TARGET
            {
                float4 albedo  = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                albedo.rgb *= _Color.rgb;
                return albedo;
            }

            ENDHLSL
        }
      
    }
    FallBack "Diffuse"
}
