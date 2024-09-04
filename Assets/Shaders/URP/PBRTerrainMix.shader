Shader "CALF/PBRTerrainMix"
{
    Properties
    {
        _BlendContrast("Blend Contrast",Range(0,1)) = 0.1
        _BlendMap("Blend Map",2D) = "white" {}
        
        //Layer01
        _Layer1_BaseMap("Layer1 BaseMap",2D) = "white" {}
        _Layer1_BaseColor("Layer1 BaseColor",Color) = (1,1,1,1)
        _Layer1_NormalMap("Layer1 NormalMap",2D) = "white" {}
        _Layer1_HRA("Layer1 HRA",2D) = "white" {}
        _Layer1_HeightContrast("Layer1 Height Contrast",Range(0,1)) = 0.0
        //Layer02
        _Layer2_BaseMap("Layer2 BaseMap",2D) = "white" {}
        _Layer2_BaseColor("Layer2 BaseColor",Color) = (1,1,1,1)
        _Layer2_NormalMap("Layer2 NormalMap",2D) = "white" {}
        _Layer2_HRA("Layer2 HRA",2D) = "white" {}
        _Layer2_HeightContrast("Layer2 Height Contrast",Range(0,1)) = 0.0
        //Layer03
        _Layer3_BaseMap("Layer3 BaseMap",2D) = "white" {}
        _Layer3_BaseColor("Layer3 BaseColor",Color) = (1,1,1,1)
        _Layer3_NormalMap("Layer3 NormalMap",2D) = "white" {}
        _Layer3_HRA("Layer3 HRA",2D) = "white" {}
        _Layer3_HeightContrast("Layer3 Height Contrast",Range(0,1)) = 0.0
        //Layer04
        _Layer4_BaseMap("Layer4 BaseColor",2D) = "white" {}
        _Layer4_BaseColor("Layer4 BaseColor",Color) = (1,1,1,1)
        _Layer4_NormalMap("Layer4 NormalMap",2D) = "white" {}
        _Layer4_HRA("Layer4 HRA",2D) = "white" {}
        _Layer4_HeightContrast("Layer4 Height Contrast",Range(0,1)) = 0.0
        
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}
            HLSLPROGRAM
            #include "Librarys\PBR.hlsl"
            
            #pragma vertex vert;
            #pragma fragment frag;

            TEXTURE2D(_BlendMap);
            SAMPLER(sampler_BlendMap);

            TEXTURE2D(_Layer1_BaseMap);
            SAMPLER(sampler_Layer1_BaseMap);
            TEXTURE2D(_Layer1_NormalMap);
            SAMPLER(sampler_Layer1_NormalMap);
            TEXTURE2D(_Layer1_HRA);
            SAMPLER(sampler_Layer1_HRA);

            TEXTURE2D(_Layer2_BaseMap);
            SAMPLER(sampler_Layer2_BaseMap);
            TEXTURE2D(_Layer2_NormalMap);
            SAMPLER(sampler_Layer2_NormalMap);
            TEXTURE2D(_Layer2_HRA);
            SAMPLER(sampler_Layer2_HRA);

            TEXTURE2D(_Layer3_BaseMap);
            SAMPLER(sampler_Layer3_BaseMap);
            TEXTURE2D(_Layer3_NormalMap);
            SAMPLER(sampler_Layer3_NormalMap);
            TEXTURE2D(_Layer3_HRA);
            SAMPLER(sampler_Layer3_HRA);

            TEXTURE2D(_Layer4_BaseMap);
            SAMPLER(sampler_Layer4_BaseMap);
            TEXTURE2D(_Layer4_NormalMap);
            SAMPLER(sampler_Layer4_NormalMap);
            TEXTURE2D(_Layer4_HRA);
            SAMPLER(sampler_Layer4_HRA);

            CBUFFER_START(UnityMatVar)
                float4 _Layer1_BaseMap_ST;
                float4 _Layer2_BaseMap_ST;
                float4 _Layer3_BaseMap_ST;
                float4 _Layer4_BaseMap_ST;
                float4 _Layer1_BaseColor;
                float4 _Layer2_BaseColor;
                float4 _Layer3_BaseColor;
                float4 _Layer4_BaseColor;
                float _BlendContrast;
                float _Layer1_HeightContrast;
                float _Layer2_HeightContrast;
                float _Layer3_HeightContrast;
                float _Layer4_HeightContrast;
            CBUFFER_END

            //一个来自UE4 计算heightLerp的公式
            float HeightLerp(float height, float transition, float blendeContrast)
            {
                return clamp(lerp(0 - blendeContrast, blendeContrast + 1, clamp((height - 1) + (transition * 2),0,1)),0,1);
            }

            //一个来自UE4 图片对比度计算公式
            float CheapContrast(float input, float blendeContrast)
            {
                return clamp(lerp((0 - blendeContrast), (blendeContrast + 1), input),0,1);
            }

            //基于权重的混合因子
            float4 WeightBlend(float4 vec4,float blendContrast)
            {
                float w1 = max(max(max(vec4.x,vec4.y),vec4.z),vec4.w) - blendContrast;
                float c1 = max(0,vec4.x - w1);
                float c2 = max(0, vec4.y - w1);
                float c3 = max(0, vec4.z - w1);
                float c4 = max(0, vec4.w - w1);
                float4 blendWieght = float4(c1,c2,c3,c4) / (c1 + c2 + c3 + c4);
                return blendWieght; //blendweight中保存着四个权重值
            }
            
            Varyings vert(Attributes IN)
            {
                Varyings OUT = Vert(IN);
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                float4 blendMap = SAMPLE_TEXTURE2D(_BlendMap,sampler_BlendMap, IN.uv);
                
                //注意HRA贴图 R通道-->保存高度Height信息 G通道-->roughness B通道-->AO
                float2 uw1 = IN.uv * _Layer1_BaseMap_ST.xy + _Layer1_BaseMap_ST.zw;
                float4 layer1_baseColor = SAMPLE_TEXTURE2D(_Layer1_BaseMap,sampler_Layer1_BaseMap, uw1)  * _Layer1_BaseColor;
                float4 layer1_normal = SAMPLE_TEXTURE2D(_Layer1_NormalMap,sampler_Layer1_NormalMap, uw1);
                float4 layer1_hra = SAMPLE_TEXTURE2D(_Layer1_HRA,sampler_Layer1_HRA, uw1);
                float layer1_height = CheapContrast(layer1_hra.x, _Layer1_HeightContrast);
                
                float2 uv2 = IN.uv * _Layer2_BaseMap_ST.xy + _Layer2_BaseMap_ST.zw;
                float4 layer2_baseColor = SAMPLE_TEXTURE2D(_Layer2_BaseMap,sampler_Layer2_BaseMap, uv2)  * _Layer2_BaseColor;
                float4 layer2_normal = SAMPLE_TEXTURE2D(_Layer2_NormalMap,sampler_Layer2_NormalMap, uv2);
                float4 layer2_hra = SAMPLE_TEXTURE2D(_Layer2_HRA,sampler_Layer2_HRA, uv2);
                float layer2_height = CheapContrast(layer2_hra.x, _Layer2_HeightContrast);

                float2 uv3 = IN.uv * _Layer3_BaseMap_ST.xy + _Layer3_BaseMap_ST.zw;
                float4 layer3_baseColor = SAMPLE_TEXTURE2D(_Layer3_BaseMap,sampler_Layer3_BaseMap, uv3)  * _Layer3_BaseColor;
                float4 layer3_normal = SAMPLE_TEXTURE2D(_Layer3_NormalMap,sampler_Layer3_NormalMap, uv3);
                float4 layer3_hra = SAMPLE_TEXTURE2D(_Layer3_HRA,sampler_Layer3_HRA, uv3);
                float layer3_height = CheapContrast(layer3_hra.x, _Layer3_HeightContrast);

                float2 uv4 = IN.uv * _Layer4_BaseMap_ST.xy + _Layer4_BaseMap_ST.zw;
                float4 layer4_baseColor = SAMPLE_TEXTURE2D(_Layer4_BaseMap,sampler_Layer4_BaseMap, uv4)  * _Layer4_BaseColor;
                float4 layer4_normal = SAMPLE_TEXTURE2D(_Layer4_NormalMap,sampler_Layer4_NormalMap, uv4);
                float4 layer4_hra = SAMPLE_TEXTURE2D(_Layer4_HRA,sampler_Layer4_HRA, uv4);
                float layer4_height = CheapContrast(layer4_hra.x, _Layer4_HeightContrast);
                
                float4 blend_vec4 = float4(blendMap.x + layer1_height, blendMap.y + layer2_height, blendMap.z + layer3_height, blendMap.w + layer4_height);
                float4 blendWieght = WeightBlend(blend_vec4, _BlendContrast);
                float4 baseColor = layer1_baseColor * blendWieght.x + layer2_baseColor * blendWieght.y + layer3_baseColor * blendWieght.z + layer4_baseColor * blendWieght.w;
                float roughness = layer1_hra.y * blendWieght.x  + layer2_hra.y * blendWieght.y + layer3_hra.y * blendWieght.z + layer4_hra.y * blendWieght.w;
                float ao = layer1_hra.z * blendWieght.x  + layer2_hra.z * blendWieght.y + layer3_hra.z * blendWieght.z + layer4_hra.z * blendWieght.w;
                float4 normalMap = layer1_normal * blendWieght.x + layer2_normal * blendWieght.y + layer3_normal * blendWieght.z + layer4_normal * blendWieght.w;
                
                MaterialData mat;
                mat.albedoAlpha = baseColor;
                mat.metalness = GetMetalness();
                mat.emission = GetEmission();
                mat.occlusion = ao;
                mat.perceptualRoughness = roughness;
                mat.specularity = GetSpecularity();
                float3 normalTS = UnpackNormal(normalMap);
                normalTS = float3(normalTS.rg * GetNormalStrength(), lerp(1, normalTS.b, saturate(GetNormalStrength())));
                normalTS = normalize(normalTS);
                mat.normalTS = normalTS;
  
                float4 col = Frag(IN, mat);
                return col;
            }
            
            
            ENDHLSL
        }

        Pass
        {
            Tags {"LightMode" = "ShadowCaster"}
            ZWrite On
            ZTest LEqual
            ZClip Off
            
            HLSLPROGRAM
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            
            #pragma vertex Vert
            #pragma fragment FragmentDepthOnly
            #define CAST_SHADOWS_PASS
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            
            #include "Librarys\PBR.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "URPShaderEditor.PBRTerrainMixEditorGUI"
}
