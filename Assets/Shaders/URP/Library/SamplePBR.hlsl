
///////////////////////////////////////////////////////////////////////////////
//                      Includes                                             //
///////////////////////////////////////////////////////////////////////////////


#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
// See ShaderVariablesFunctions.hlsl in com.unity.render-pipelines.universal/ShaderLibrary/ShaderVariablesFunctions.hlsl


/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
///                                                                           ///
///                      SHADER BODY                                          ///
///                                                                           ///
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

struct Attributes
{
    float4 positionOS         : POSITION;       //模型空间中的坐标
    float3 normalOS           : NORMAL;         //模型空间中的法线
    float4 tangentOS          : TANGENT;        //模型空间中的切线
    float3 color              : COLOR;
    float2 uv                 : TEXCOORD0;      //纹理坐标
    float2 staticLightmapUV   : TEXCOORD1;
    float2 dynamicLightmapUV  : TEXCOORD2;      //颜色
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionHCS     : SV_POSITION;         //裁剪空间中的坐标
    float2 uv              : TEXCOORD0;           //纹理坐标
    float3 positionWS      : TEXCOORD1;           //世界空间中的坐标
    float3 normalWS        : TEXCOORD2;           //世界空间中的法线
    float3 viewDirectionWS : TEXCOORD3;           //世界空间中的观察方向
    float4 tangentWS       : TEXCOORD4;           //世界空间中的切线
    float3 viewDirectionTS : TEXCOORD5;
    float3 color           : TEXCOORD6;           //颜色

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 8);
    #ifdef DYNAMICLIGHTMAP_ON
    float2  dynamicLightmapUV : TEXCOORD9;
    #endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};