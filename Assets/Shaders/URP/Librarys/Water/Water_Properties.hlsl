﻿#ifndef WATER_PROPERTIES_INCLUDED
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
    float _GlossPower;
    float _ShoreRange;
    float _ShoreEdgeWidth;
    float _ShoreEdgeIntensity;
    float _WaveAmplitude;
    float _WaveLength;
    float _WaveSpeed;
    float _WaveEnable;
    float _ShoreEnable;
    float _FoamSpeed;
    float _FoamFastSpeed;
    float _FoamContrast;
    float _FoamRange;
    float _FoamEnable;
    float4 _FoamMap_ST;
    float4 _FoamColor;
    float4 _FoamDirection;
    float4 _ShoreColor;
    float4 _CausticsSpeed;
    float4 _NormalSpeed;
    float4 _DeepColor;
    float4 _ShallowColor;
    float4 _FresnelColor;
    float4 _NormalMap_ST;
CBUFFER_END

#endif