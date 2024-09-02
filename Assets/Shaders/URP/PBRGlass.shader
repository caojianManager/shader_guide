Shader "CALF/PBRGlass"
{
    Properties
    {
        //Matcap贴图
        _MatcapMap("Matcap Map",2D) = "white" {}
        _MatcapColor("Matcap Color",Color) = (1,1,1,1)
        _RefractMap("_RefractMap",2D) = "white" {}
        _RefractColor("_RefractColor",Color) = (1,1,1,1)
        _RefractIntensity("_RefractIntensity",Float) = 1.0
        //厚度贴图
        _ThickMap("Thick Map",2D) = "white" {}
        _ObjectPivotOffset("_ObjectPivotOffset",Float) = 0
        _ObjectPivotHeight("_ObjectPivotHeight",Float) = 1
        //污迹图
        _DirtMap("DirtMap",2D) = "white" {}
        _LightEdgeMin("LightEdgeMin",Float) = 0
        _LightEdgeMax("_LightEdgeMax",Float) = 1
 
        // Surface
        [HideInInspector] _SrcBlend("Source Blending", Float) = 1.0
        [HideInInspector] _DstBlend("Dest Blending", Float) = 0.0
        
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("Depth Test", Float) = 4 // Default to "LEqual"
    }
    SubShader
    {
        Tags {
            "RenderType" = "Transparency"   
            "IgnoreProjector" = "True"
            "UniversalMaterialType" = "Unlit"
             "RenderPipeline" = "UniversalPipeline"}

        Pass
        {
            Tags {"LightMode" = "UniversalForwardOnly"}
            
            Blend [_SrcBlend] [_DstBlend]
            Cull Off
            ZWrite Off
            ZTest LEqual
            ZClip Off
            
            HLSLPROGRAM
            
            // Render Paths
            #pragma multi_compile _ _FORWARD_PLUS
            
            // Transparency
            #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT

            // Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON
            
            #pragma vertex vert;
            #pragma fragment frag;
            #include "./Librarys/SurfacePBR_URP.hlsl"
            
            TEXTURE2D(_MatcapMap);
            SAMPLER(sampler_MatcapMap);
            TEXTURE2D(_RefractMap);
            SAMPLER(sampler_RefractMap);
            TEXTURE2D(_ThickMap);
            SAMPLER(sampler_ThickMap);
            TEXTURE2D(_DirtMap);
            SAMPLER(sampler_DirtMap);

            CBUFFER_START(UnityMatVar)
                float4 _RefractColor;
                float _RefractIntensity;
                float _LightEdgeMin;
                float _LightEdgeMax;
            CBUFFER_END

             //第一种matcap uv采样算法。会被拉伸，如果法线结构变化不圆润(平坦会导致采样matcap 贴图出现变形)。
            float2 MatcapUV1(float3 normalWS)
            {
                float3 normalVS = TransformWorldToView(normalWS);
                return normalVS.xy * 0.5 + 0.5;
            }

            //优化过的matcapUV采样算法
            float2 MatcapUV2(float3 normalWS,float3 positionWS)
            {
                float3 normalVS = TransformWorldToView(normalWS);
                float3 positionVS = TransformWorldToView(positionWS);
                positionVS = normalize(positionVS);
                float3 NcP = cross(positionVS, normalVS);
                float2 matcapUV = float2(-NcP.y, NcP.x);
                return matcapUV * 0.175 + 0.5;
            }

            //边缘光
            float LightEdge(float3 normalWS, float3 viewDirWS)
            {
                float VoN = dot(normalWS, viewDirWS);
                return (1 - smoothstep(_LightEdgeMin,_LightEdgeMax,VoN));
            }
            
            Varyings vert(Attributes IN)
            {
                Varyings OUT = Vert(IN);
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                //matcap map采样
                float2 matcapUV = MatcapUV2(IN.normalWS,IN.positionWS)*1;
                float4 matcapMap = SAMPLE_TEXTURE2D(_MatcapMap,sampler_MatcapMap, matcapUV);
                //厚度贴图
                float4 thickMap = SAMPLE_TEXTURE2D(_ThickMap,sampler_ThickMap,IN.uv);

                //dirt map采样
                float4 dirtMap = SAMPLE_TEXTURE2D(_DirtMap,sampler_DirtMap,IN.uv);
                
                //refractMaptcap 采样
                float3 viewDirNor = normalize(IN.viewDirectionWS);
                float lightEg = clamp(LightEdge(IN.normalWS,viewDirNor) + thickMap.r + dirtMap.a,0,1); 
                float refractThickness = lightEg * _RefractIntensity; //折射厚度
                float4 refractMatcapMap = SAMPLE_TEXTURE2D(_RefractMap, sampler_RefractMap,matcapUV + refractThickness);
                refractMatcapMap = lerp(_RefractColor*0.5,_RefractColor * refractMatcapMap,clamp(refractThickness,0,1));
                
                float alpha = clamp(max(matcapMap.r,lightEg),0,1);
                return float4(matcapMap.rgb + refractMatcapMap,alpha);
            }
            
            ENDHLSL
        }
        
    }
    CustomEditor "URPShaderEditor.PBRGlassEditor"
}
