#ifndef SKYBOX_CUBEMAP_PROPERTIES_INCLUDED
#define SKYBOX_CUBEMAP_PROPERTIES_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
float _CubemapExposure;
float4  _CubemapTintColor;
float _CubemapPosition;
float _RotationEnable;
float _Rotation;
float _RotationSpeed;
float _FogEnable;
float _FogIntensity;
float _FogHeight;
float _FogSmoothness;
float _FogFill;
float _FogPosition;
CBUFFER_END

#endif