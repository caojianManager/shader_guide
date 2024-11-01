Shader "ShaderLab_Learning/GlassRefractionShader"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_Cubemap ("Environment Cubemap", Cube) = "_Skybox" {}
		_Distortion ("Distortion", Range(0, 100)) = 10
		_RefractAmount ("Refract Amount", Range(0.0, 1.0)) = 1.0

    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline"  "Queue"="Transparent"  "RenderType"="Opaque" }
        
        
        Pass
        {
            Tags {"LightMode" = "UniversalForward"}
            
            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            TEXTURE2D(_BumpMap);
            SAMPLER(sampler_BumpMap);
            
            TEXTURECUBE(_Cubemap);
            SAMPLER(sampler_Cubemap);
            
            
            CBUFFER_START(UnityPerMaterial)
                float _Distortion;
                float _RefractAmount;
                float4 _MainTex_ST;
                float4 _BumpMap_ST;
                float4 _CameraOpaqueTexture_TexelSize;
            CBUFFER_END

            #pragma vertex Vert;
            #pragma fragment Frag;

            struct Attributes
            {
                float4 positionOS: POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS:SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
            };

            Varyings Vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.uv.xy = TRANSFORM_TEX(IN.uv,_MainTex);
                OUT.uv.zw = TRANSFORM_TEX(IN.uv,_BumpMap);
                
                //世界坐标
                float3 positionWS = TransformObjectToWorld(IN.positionOS);
                 //世界空间的法线
                float3 normalWS = TransformObjectToWorldNormal(IN.normalOS);
                //世界空间的切线
                float3 tangentWS = TransformObjectToWorldDir(IN.tangentOS.xyz);
                //世界空间的副切线
                float3 bitangentWS = cross(normalWS, tangentWS) * IN.tangentOS.w;

                OUT.TtoW0 = float4(tangentWS.x,bitangentWS.x,normalWS.x, positionWS.x);
                OUT.TtoW1 = float4(tangentWS.y,bitangentWS.y,normalWS.y, positionWS.y);
                OUT.TtoW2 = float4(tangentWS.z,bitangentWS.z,normalWS.z, positionWS.z);
                return OUT;
            }

            half4 Frag(Varyings IN):SV_Target
            {
                float3 positionWS = float3(IN.TtoW0.w,IN.TtoW1.w,IN.TtoW2.w);
                float3 viewDirWS =   normalize(GetWorldSpaceViewDir(positionWS));

                // Get the normal in tangent space
                float4 normalMap = SAMPLE_TEXTURE2D(_BumpMap,sampler_BumpMap,IN.uv.zw);
                float3 normalTS = UnpackNormal(normalMap); //等同于 (normalMap.xy * 2 - 1)
                float3 normalWS = normalize(half3(dot(IN.TtoW0.xyz,normalTS),dot(IN.TtoW1.xyz,normalTS),dot(IN.TtoW2.xyz,normalTS)));
                
                // Compute the offset in tangent space
                float2 offset = normalTS.xy * _Distortion * _CameraOpaqueTexture_TexelSize.xy;

                //获取屏幕uv,另一种方法
                float2 srcUV = GetNormalizedScreenSpaceUV(IN.positionCS);
                srcUV = srcUV + offset;
                float3 refrCol = SampleSceneColor(srcUV);

                // 反射
                half3 reflDir = reflect(-viewDirWS, normalWS);
                half3 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,IN.uv.xy);
                half3 reflCol = SAMPLE_TEXTURECUBE(_Cubemap, sampler_Cubemap, reflDir).rgb * texColor.rgb;
 
                half3 finalColor = refrCol * _RefractAmount + reflCol * (1 - _RefractAmount);
                return half4(finalColor,0.5f);
            }

            ENDHLSL
        }
      
    }
    FallBack "Diffuse"
}
