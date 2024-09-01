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
        _Surface("Surface", Float) = 0.0
        _Blend("Blend", Float) = 0.0
        _AlphaClip("Alpha Clip", Range(0.0, 1.0)) = 0.0
        [Toggle(_AlphaClipEnabled)] _AlphaClipEnabled ("Alpha Clip Enabled", Float) = 0.0
        [HideInInspector] _SrcBlend("Source Blending", Float) = 1.0
        [HideInInspector] _DstBlend("Dest Blending", Float) = 0.0
        _SortPriority("Sort Priority", Range(-50.0, 50.0)) = 0.0
        
        //Advanced Properties
        [Toggle(_ReceiveFogEnabled)] _ReceiveFogEnabled ("Receive Fog", Float) = 1
        [Toggle(_ReceiveShadowsEnabled)] _ReceiveShadowsEnabled ("Receive Shadow", Float) = 1
        
        [Enum(Off, 0, On, 1)]_ZWrite ("ZWrite", Float) = 1.0 // Default to "ZWrite On"
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("Depth Test", Float) = 4 // Default to "LEqual"
        [Enum(UnityEngine.Rendering.CullMode)] _Culling ("Culling", Float) = 2 // Default to "Cull Back"

        
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}

        Pass
        {
            Tags {"LightMode" = "UniversalForwardOnly"}
            
            Blend [_SrcBlend] [_DstBlend]
            Cull [_Culling]
            ZWrite [_ZWrite]
            ZTest LEqual
            ZClip Off
            AlphaToMask Off
            
            HLSLPROGRAM
            
            // Render Paths
            #pragma multi_compile _ _FORWARD_PLUS

            // Fog, Decals, SSAO
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION

            // Transparency
            #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            
            // Lighting
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT

            // Unity stuff
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            
            // Lightmapping
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON

            // Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON
            
            #pragma vertex vert;
            #pragma fragment frag;
            #include "./Library/SurfacePBR_URP.hlsl"
            
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
                float _ObjectPivotOffset;
                float _ObjectPivotHeight;
                float _LightEdgeMin;
                float _LightEdgeMax;
                float _ReceiveFogEnabled;
                float _ReceiveShadowsEnabled;
                float _HasEmissionMap;
                float _AlphaClip;
                float4 _EmissionColor;
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
                return matcapUV * 0.5 + 0.5;
            }

            //边缘光
            float LightEdge(float3 normalWS, float3 viewDirWS)
            {
                float VoN = dot(normalWS, viewDirWS);
                return (1 - smoothstep(_LightEdgeMin,_LightEdgeMax,VoN));
            }
            
            Varyings vert(Attributes IN)
            {
                //r-金属 g-粗糙 b-ao
                Varyings OUT = Vert(IN);
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                //matcap map采样
                float2 matcapUV = MatcapUV2(IN.normalWS,IN.positionWS);
                float4 matcapMap = SAMPLE_TEXTURE2D(_MatcapMap,sampler_MatcapMap, matcapUV);

                //Unity Shader中获取模型中心点世界坐标的几种写法--这种计算又弊端(正确做法需要用3DMax展好UV)
                float3 objectPivot = mul(unity_ObjectToWorld , float4(0,0,0,1)).xyz;
                float pv = ((IN.positionWS.y - objectPivot.y) - _ObjectPivotOffset) / _ObjectPivotHeight;
                float2 tickMapUV = float2(0.5,pv);
                float4 thickMap = SAMPLE_TEXTURE2D(_ThickMap,sampler_ThickMap,tickMapUV);

                //dirt map采样
                float4 dirtMap = SAMPLE_TEXTURE2D(_DirtMap,sampler_DirtMap,IN.uv);
                
                //refractMaptcap 采样
                float3 viewDirNor = normalize(IN.viewDirectionWS);
                float lightEg = clamp(LightEdge(IN.normalWS,viewDirNor) + thickMap.r + dirtMap.a,0,1); 
                float refractThickness = lightEg * _RefractIntensity; //折射厚度
                float4 refractMatcapMap = SAMPLE_TEXTURE2D(_RefractMap, sampler_RefractMap,matcapUV + refractThickness);
                refractMatcapMap = lerp(_RefractColor*0.5,_RefractColor * refractMatcapMap,clamp(refractThickness,0,1));
                
                float alpha = clamp(max(matcapMap.r,lightEg),0,1);
              
                
                MaterialData mat;
                mat.albedoAlpha = float4(matcapMap.rgb + refractMatcapMap,alpha);
                mat.metalness = 0;
                mat.emission = float3(0,0,0);
                mat.occlusion = 1.0;
                mat.perceptualRoughness = 1.0;
                mat.specularity = GetSpecularity();
                mat.normalTS = float3(1,1,1);
                float4 col = Frag(IN, mat,_ReceiveFogEnabled,_ReceiveShadowsEnabled,_AlphaClip);
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
            
            #include "./Library/SurfacePBR_URP.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "URPShaderEditor.PBRGlassEditor"
}
