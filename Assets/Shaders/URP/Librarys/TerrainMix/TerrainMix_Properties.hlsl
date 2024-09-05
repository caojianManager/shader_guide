#ifndef TERRAINMIX_PROPERTIES_INCLUDED
#define TERRAINMIX_PROPERTIES_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityMatVar)
float4 _Layer1_BaseMap_ST;
float4 _Layer2_BaseMap_ST;
float4 _Layer3_BaseMap_ST;
float4 _Layer4_BaseMap_ST;
float4 _Layer1_BaseColor;
float4 _Layer2_BaseColor;
float4 _Layer3_BaseColor;
float4 _Layer4_BaseColor;
float _BlendContrast;
float _Layer1_HeightContrast;
float _Layer2_HeightContrast;
float _Layer3_HeightContrast;
float _Layer4_HeightContrast;
CBUFFER_END

#endif