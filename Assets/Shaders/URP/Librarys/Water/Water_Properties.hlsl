#ifndef WATER_PROPERTIES_INCLUDED
#define WATER_PROPERTIES_INCLUDED

CBUFFER_START(UnityPerMaterial)
    float _DeepRange;
    float _FresnelPower;
    float _NormalScale;
    float _ReflectDistortion;
    float _ReflectPower;
    float _ReflectIntensity;
    float _UnderWaterDistort;
    float _CausticsScale;
    float _CausticsIntensity;
    float _CausticsRange;
    float4 _CausticsSpeed;
    float4 _NormalSpeed;
    float4 _DeepColor;
    float4 _ShallowColor;
    float4 _FresnelColor;
    float4 _NormalMap_ST;
    float4 _DiffuseColor;
    float4 _SpecularColor;
CBUFFER_END

#endif