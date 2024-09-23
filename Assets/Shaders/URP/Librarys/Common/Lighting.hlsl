#ifndef LIGHTING_INCLUDED
#define LIGHTING_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

//Blinn-Phong光照模型 --获取高光
float3 GetLightSpecular(float3 specualrColor,Light light,float3 viewDirectionWS,float3 normalWS,float glossPow)
{
    float3 halfDir = normalize(light.direction + viewDirectionWS); //半程向量
    float3 specular = light.color * specualrColor*pow(saturate(dot(normalWS,halfDir)),glossPow);
    return specular;
}

#endif
