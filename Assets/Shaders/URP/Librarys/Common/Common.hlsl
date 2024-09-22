#ifndef COMMON_INCLUDED
#define COMMON_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#if defined(REQUIRE_DEPTH_TEXTURE)
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
#endif

#if defined(REQUIRE_OPAQUE_TEXTURE)
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"
#endif

/**
 * \brief 菲涅耳效应 (Fresnel Effect) 是根据视角不同而在表面上产生不同反射率（接近掠射角时的反射光增多）的效果
 * Fresnel Effect 节点通过计算表面法线和视图方向之间的角度来模拟这一点。该角度越宽，返回值越大。这种效果通常用于实现在许多艺术风格中很常见的边缘光照。
 * \param Normal -- 法线方向。默认情况下绑定到世界空间法线
 * \param ViewDir -- 视图方向。默认情况下绑定到世界空间视图方向
 * \param Power -- 强度计算指数
 * \return 
 */
float Fresnel(float3 Normal, float3 ViewDir, float Power)
{
    return  pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
}

//判断是正反面
float IsFrontFace(float3 normalTS, float3 viewDirectionTS)
{
    float NoV = dot(normalize(normalTS),normalize(viewDirectionTS));
    return NoV >= 0;
}

/*
 * 镜面法线，用于双面渲染，让back Face看起来和正面一样
 */
float3 MirrorNormal(float3 normalTS, float3 viewDirectionTS)
{
    float isFrontFace = IsFrontFace(normalTS,viewDirectionTS);
    normalTS.z *= isFrontFace ? 1 : -1;
    return normalTS;
}

/**
 * FlipNormal 用于双面渲染，让Back Face看起来和正面一样。背面的normal等于正面normal旋转180
 */
float3 FlipNormal(float3 normalTS, float3 viewDirectionTS)
{
    float isFrontFace = IsFrontFace(normalTS,viewDirectionTS);
    normalTS *= isFrontFace ? 1 : -1;
    return normalTS;
}

float3 DoubleSidedNormal(float model, float3 normalTS, float3 viewDirectionTS)
{
    if(model == 0)
    {
        return FlipNormal(normalTS,viewDirectionTS);
    }else if(model == 1)
    {
        return MirrorNormal(normalTS,viewDirectionTS);
    }
    return normalTS;
}

//法线切线空间转换到世界空间
float3 TranformNormalTangentToWorld(float3 normalTS, float3 normalWS, float4 tangentWS)
{
    float3x3 tangentToWorld = CreateTangentToWorld(normalWS, tangentWS.xyz, tangentWS.w);
    return TransformTangentToWorld(normalTS, tangentToWorld);
}

//菲涅尔效应
float FresnelEffect(float3 Normal, float3 ViewDir, float Power)
{
    return pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
}

float4 MainLightShadowCoord(float3 PositionWS)
{
    #if defined(_MAIN_LIGHT_SHADOWS_SCREEN)
    float4 clipPos = TransformWorldToHClip(PositionWS);
    return ComputeScreenPos(clipPos);
    #else
    return TransformWorldToShadowCoord(PositionWS);
    #endif
}

Light GetMainLightData(float3 PositionWS, float4 shadowMask)
{
    float4 shadowCoord = MainLightShadowCoord(PositionWS);
    Light light = GetMainLight(shadowCoord, PositionWS, shadowMask);
    return light;
}

//根据pos计算屏幕坐标曲率
float4 ComputeGrabScreenPos(float4 pos)
{
    #if UNITY_UV_STARTS_AT_TOP
    float scale = -1.0;
    #else
    float scale = 1.0;
    #endif
    float4 o = pos;
    o.y = pos.w * 0.5f;
    o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
    return o;
}

//根据深度重建世界空间坐标(Depth/从深度纹理重建像素的世界空间位置) --计算水的深度可以用到，将裁剪空间的坐标重新转换到世界空间(依据Depth)
//https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@11.0/manual/writing-shaders-urp-reconstruct-world-position.html
float3 ReconstructWorldPositionFromDepth(float4 clipPosition,float3 viewDierectionWS)
{
    float4 screenPos = ComputeScreenPos(clipPosition);
    float3 ndcPos = screenPos.xyz / screenPos.w;
    float2 screenUV = ndcPos.xy;
    float depthRaw = SampleSceneDepth(screenUV);
    float depthEye = LinearEyeDepth(depthRaw,_ZBufferParams);
    
    #if UNITY_REVERSED_Z
    real rawDepth = depthRaw;
    #else
    // Adjust z to match NDC for OpenGL
    real rawDepth = lerp(UNITY_NEAR_CLIP_VALUE, 1, depthRaw);
    #endif
    
    //return ComputeWorldSpacePosition(screenPos.xy / screenPos.w, rawDepth, UNITY_MATRIX_I_VP);
    
    #if defined(ORTHOGRAPHIC_SUPPORT)
    //View to world position
    float4 viewPos = float4((screenPos.xy/screenPos.w) * 2.0 - 1.0, rawDepth, 1.0);
    float4x4 viewToWorld = UNITY_MATRIX_I_VP;
    #if UNITY_REVERSED_Z //Wrecked since 7.3.1 "fix" and causes warping, invert second row https://issuetracker.unity3d.com/issues/shadergraph-inverse-view-projection-transformation-matrix-is-not-the-inverse-of-view-projection-transformation-matrix
    //Commit https://github.com/Unity-Technologies/Graphics/pull/374/files
    viewToWorld._12_22_32_42 = -viewToWorld._12_22_32_42;              
    #endif
    float4 viewWorld = mul(viewToWorld, viewPos);
    float3 viewWorldPos = viewWorld.xyz / viewWorld.w;
    #endif
    
    //Projection to world position
    float3 camPos = GetCurrentViewPosition().xyz;
    float3 worldPos = depthEye * (viewDierectionWS/screenPos.w) - camPos;
    float3 perspWorldPos = -worldPos;
    
    #if defined(ORTHOGRAPHIC_SUPPORT)
    return lerp(perspWorldPos, viewWorldPos, unity_OrthoParams.w);
    #else
    return perspWorldPos;
    #endif
}

#endif