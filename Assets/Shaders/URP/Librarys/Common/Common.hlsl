#ifndef COMMON_INCLUDED
#define COMMON_INCLUDED

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

#endif