#ifndef DISSLOVE_PROPERTIES_INCLUDED
#define DISSLOVE_PROPERTIES_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

//这样会走CBUFFER --> 走SPR Batch
CBUFFER_START(UnityPerMaterial)
float _Amout;
float _EdgeWidth;
float _EdgeColorIntensity;
float _ReceiveFogEnabled;
float _ReceiveShadowsEnabled;
float _Spreed;
float _AutoDisslove;
float4 _BaseColor;
float4 _EdgeColor;
float4 _BaseMap_ST;
CBUFFER_END

// NOTE: Do not ifdef the properties for dots instancing, but ifdef the actual usage.
// Otherwise you might break CPU-side as property constant-buffer offsets change per variant.
// NOTE: Dots instancing is orthogonal to the constant buffer above.
#ifdef UNITY_DOTS_INSTANCING_ENABLED

UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
    UNITY_DOTS_INSTANCED_PROP(float , _Amout)
    UNITY_DOTS_INSTANCED_PROP(float , _EdgeWidth)
    UNITY_DOTS_INSTANCED_PROP(float , _EdgeColorIntensity)
    UNITY_DOTS_INSTANCED_PROP(float , _ReceiveFogEnabled)
    UNITY_DOTS_INSTANCED_PROP(float , _ReceiveShadowsEnabled)
    UNITY_DOTS_INSTANCED_PROP(float , _Spreed)
    UNITY_DOTS_INSTANCED_PROP(float , _AutoDisslove)
    UNITY_DOTS_INSTANCED_PROP(float4 , _BaseColor)
    UNITY_DOTS_INSTANCED_PROP(float4 , _EdgeColor)
    UNITY_DOTS_INSTANCED_PROP(float4 , _BaseMap_ST)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

#define _Amout                  UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _Amout)
#define _BaseMap_ST             UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _BaseMap_ST)
#define _EdgeColorIntensity     UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _EdgeColorIntensity)
#define _ReceiveFogEnabled      UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _ReceiveFogEnabled)
#define _ReceiveShadowsEnabled  UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _ReceiveShadowsEnabled)
#define _Spreed                 UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _Spreed)
#define _AutoDisslove           UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _AutoDisslove)
#define _BaseColor              UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _BaseColor)
#define _EdgeColor              UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _EdgeColor)
#define _BaseMap_ST             UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _BaseMap_ST)

#endif

#endif
