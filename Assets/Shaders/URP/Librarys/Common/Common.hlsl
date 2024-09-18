#ifndef COMMON_INCLUDED
#define COMMON_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"

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

#endif