#ifndef GLASS_PROPERTIES_INCLUDED
#define GLASS_PROPERTIES_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
float4 _RefractColor;
float _RefractIntensity;
float _LightEdgeMin;
float _LightEdgeMax;
CBUFFER_END

#ifdef UNITY_DOTS_INSTANCING_ENABLED
UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
    UNITY_DOTS_INSTANCED_PROP(float4 , _RefractColor)
    UNITY_DOTS_INSTANCED_PROP(float, _RefractIntensity)
    UNITY_DOTS_INSTANCED_PROP(float , _LightEdgeMin)
    UNITY_DOTS_INSTANCED_PROP(float , _LightEdgeMax)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

#define _RefractColor      UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4  , _RefractColor)
#define _RefractIntensity      UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _RefractIntensity)
#define _LightEdgeMin      UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _LightEdgeMin)
#define _LightEdgeMax      UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _LightEdgeMax)

#endif

#endif