#ifndef WATER_PROPERTIES_INCLUDED
#define WATER_PROPERTIES_INCLUDED

CBUFFER_START(UnityPerMaterial)
    float _DeepRange;
    float _FresnelPower;
    float _NormalScale;
    float4 _NormalSpeed;
    float4 _DeepColor;
    float4 _ShallowColor;
    float4 _FresnelColor;
    float4 _SpecularColor;
    float4 _DiffuseColor;
    float4 _NormalMap_ST;
CBUFFER_END

#endif