Shader "CURP/Water/Standard"
{
    Properties
    {
        //WaterColor
        _ShallowColor("Shallow Color",Color) = (1,1,1,1)
        _DeepColor("Deep Color",Color) = (1,1,1,1)
        _DeepRange("Deep Range",Range(0,100)) = 1
        //菲你颜色，平视的时候让水平面颜色有个过渡
        _FresnelColor("Fresnel Color",Color) = (1,1,1,1)
        _FresnelPower("Fresnel Power",Float) = 1
        
        //Surface Normal
        _NormalMap("Normal Map",2D) = "white" {}
        _NormalSpeed("Normal Speed",Float) = 1

    }
    SubShader
    {
        Tags {
            "RenderType" = "Transparency"   
            "IgnoreProjector" = "True"
            "UniversalMaterialType" = "Unlit"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Tags {"LightMode" = "UniversalForwardOnly"}
            
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            ZTest LEqual
            ZClip Off
            
            HLSLPROGRAM

            #include "../../../Librarys/Common/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #pragma vertex Vert;
            #pragma fragment Frag;

            struct Attributes
            {
                float4 positionOS         : POSITION;
                float3 normalOS           : NORMAL;
                float4 tangentOS          : TANGENT;
                float3 color              : COLOR;
                float2 uv                 : TEXCOORD0;
                float2 staticLightmapUV   : TEXCOORD1;
                float2 dynamicLightmapUV  : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionHCS     : SV_POSITION;
                float2 uv              : TEXCOORD0;
                float3 positionWS      : TEXCOORD1;
                float3 normalWS        : TEXCOORD2;
                float3 viewDirectionWS : TEXCOORD3;
                float4 tangentWS       : TEXCOORD4;
                float3 viewDirectionTS : TEXCOORD5;
                float3 color           : TEXCOORD6;

	            UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            CBUFFER_START(UnityPerMaterial)
                float _DeepRange;
                float _FresnelPower;
                float4 _DeepColor;
                float4 _ShallowColor;
                float4 _FresnelColor;
            CBUFFER_END

////////////////////////////////////////////////////////////////////////////////////////////
///                                 Water Color                                         ///
///////////////////////////////////////////////////////////////////////////////////////////

            //从深度纹理重建像素的世界空间位置
            //https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@11.0/manual/writing-shaders-urp-reconstruct-world-position.html
            float3 ReconstructWorldPositionFromDepth(float2 positionHCS)
            {
                float2 UV = positionHCS.xy / _ScaledScreenParams.xy;
                #if UNITY_REVERSED_Z
                    real depth=SampleSceneDepth(UV);
                #else
                    // Adjust Z to match NDC for OpenGL ([-1, 1])
                    real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(UV));
                #endif
                // Reconstruct the world space positions.
                return ComputeWorldSpacePosition(UV, depth, UNITY_MATRIX_I_VP);
            }

            float GetWaterDepth(float positionWS_Y, float reconstructPositionWS_Y_FromDepth)
            {
                return positionWS_Y - reconstructPositionWS_Y_FromDepth;
            }

            float4 WaterColor(float3 normalWS, float3 viewDirectionWS,float4 positionHCS,float3 positionWS)
            {
                 //计算WaterColor
                float waterDepth = GetWaterDepth(positionWS.y, ReconstructWorldPositionFromDepth(positionHCS).y);
                float depthLerp = clamp(exp(-waterDepth/_DeepRange),0,1);
                float4 waterColor = lerp(_DeepColor, _ShallowColor,depthLerp);
                float fresnelLerp = Fresnel(normalWS,normalize(viewDirectionWS),_FresnelPower);//菲尼系数-水平面颜色
                waterColor = lerp(waterColor, _FresnelColor,fresnelLerp);
                return waterColor;
            }
            

            Varyings Vert(Attributes IN)
            {
                Varyings OUT = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                VertexPositionInputs position_inputs = GetVertexPositionInputs(IN.positionOS);
                OUT.positionWS = position_inputs.positionWS;
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.normalWS = normalize(OUT.normalWS);
                OUT.positionHCS = position_inputs.positionCS;
                OUT.uv = IN.uv;
                OUT.viewDirectionWS = (GetWorldSpaceViewDir(OUT.positionWS));
                OUT.tangentWS = float4(TransformObjectToWorldDir(IN.tangentOS.xyz), IN.tangentOS.w);
                OUT.viewDirectionTS = GetViewDirectionTangentSpace(OUT.tangentWS, OUT.normalWS, OUT.viewDirectionWS);
                OUT.color = IN.color;
                return OUT;
            }

            half4 Frag(Varyings IN) : SV_Target
            {
               float4 waterColor = WaterColor(IN.normalWS,IN.viewDirectionWS,IN.positionHCS,IN.positionWS);
                // float3 normalUV = clamp()
                
                return waterColor;
            }
            
            ENDHLSL
        }
    }

}
