#ifndef GLASS_INCLUDED
#define GLASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
#include "Glass_Maps.hlsl"
#include "Glass_Properties.hlsl"


//顶点数据结构
struct Attributes
{
    float4 positionOS         : POSITION;
    float3 normalOS           : NORMAL;
    float4 tangentOS          : TANGENT;
    float3 color              : COLOR;
    float2 uv                 : TEXCOORD0;
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

float4 Frag(Varyings IN) : SV_Target
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
    return float4(matcapMap.rgb + refractMatcapMap.rgb,alpha);
}

#endif