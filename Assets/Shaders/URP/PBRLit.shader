Shader "CALF/PBRLit"
{
    Properties
    {
        //MRA贴图 r-金属度,g-粗糙度,b-ao
        _MRAMap("MRA Map",2D) = "white" {}
        _HasMRAMap("Has MRA Map",Float) = 0
        //基础贴图
        _BaseMap("BaseMap",2D) = "white" {}
        _BaseColor("BaseColor",Color) = (1,1,1,1)
        _NormalMap("NormalMap",2D) = "white" {}
        //细节贴图
        _DetailMap("Detail Map",2D) = "white" {}
        _DetailMapColor("Detail Map Color",Color) = (1,1,1,1)
        _DetailNormalMap("Detail NormalMap",2D) = "white" {}
        _DetailScale("Detail Scale",Range(0,2)) = 1.0
        
        [HideInInspector] _DefaultTex("DefaultTex",2D) = "white" {}
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/Shaders/URP/Library/SurfacePBR_URP.hlsl"
            
            #pragma vertex vert;
            #pragma fragment frag;

            TEXTURE2D(_BlendMap);
            SAMPLER(sampler_BlendMap);

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            TEXTURE2D(_DetailMap);
            SAMPLER(sampler_DetailMap);
            TEXTURE2D(_DetailNormalMap);
            SAMPLER(sampler_DetailNormalMap);
            TEXTURE2D(_MRAMap);
            SAMPLER(sampler_MRAMap);

            CBUFFER_START(UnityMatVar)
                float _DetailScale;
                float _HasMRAMap;
                float4 _BaseColor;
                float4 _DetailMapColor;
                float4 _DetailMap_ST;
                float4 _BaseMap_ST;
            CBUFFER_END


            Varyings vert(Attributes IN)
            {
                //r-金属 g-粗糙 b-ao
                Varyings OUT = Vert(IN);
                OUT.color = float4(0.5,0.5,0.5,1);
                OUT.uv = IN.uv * _BaseMap_ST.xy + _BaseMap_ST.zw;
                OUT.uv1 = IN.uv * _DetailMap_ST.xy + _DetailMap_ST.zw;
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                float4 mraMap = SAMPLE_TEXTURE2D(_MRAMap, sampler_MRAMap,IN.uv);
                float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap, IN.uv) * _BaseColor;
                float4 normalMap = SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,IN.uv);
                float4 detailMap = SAMPLE_TEXTURE2D(_DetailMap, sampler_DetailMap,IN.uv1) * _DetailMapColor;
                float4 detailNormal = SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailMap, IN.uv1);
                detailMap =  half(2.0) * detailMap * _DetailScale - _DetailScale + half(1.0);

                float metalV = GetMetalness();
                if(_HasMRAMap)
                {
                    metalV = 1.0;
                }
                float ao = _HasMRAMap ? mraMap.b : 1.0;
                float roughness = _HasMRAMap ? mraMap.g : 1.0;
                
                MaterialData mat;
                mat.albedoAlpha = baseMap * detailMap;
                mat.metalness = metalV;
                mat.emission = GetEmission();
                mat.occlusion = ao;
                mat.perceptualRoughness = roughness;
                mat.specularity = GetSpecularity();
                float3 normalTS = UnpackNormal(normalMap);
                normalTS = float3(normalTS.rg * GetNormalStrength(), lerp(1, normalTS.b, saturate(GetNormalStrength())));
                normalTS = normalize(normalTS);
                float3 detailNormalTS = UnpackNormal(detailNormal);
                detailNormalTS = float3(detailNormalTS.rg * GetNormalStrength(), lerp(1, detailNormalTS.b, saturate(GetNormalStrength())));
                detailNormalTS = normalize(detailNormalTS);
                float3 blendNormalTS = lerp(normalTS, BlendNormalRNM(normalTS, detailNormalTS),1);
                mat.normalTS = blendNormalTS;
                
                float4 col = Frag(IN, mat);
                return col;
            }
            
            ENDHLSL
        }
    }
    CustomEditor "URPShader.PBRLitEditorGUI"
}
