#ifndef LIT_PROPERTIES_INCLUDED
#define LIT_PROPERTIES_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

//这样会走CBUFFER --> 走SPR Batch
CBUFFER_START(UnityPerMaterial)
float _DoubleSidedModel;
float _DetailScale;
float _HasMRAMap;
float _Roughness;
float _EnableDetailMap;
float _ReceiveFogEnabled;
float _ReceiveShadowsEnabled;
float _HasEmissionMap;
float _AlphaClip;
float _EmissionMapMultiply;
float _NormalStrength;
float _Metalness;
float4 _BaseColor;
float4 _EmissionColor;
float4 _DetailMapColor;
float4 _DetailMap_ST;
float4 _BaseMap_ST;
CBUFFER_END

// NOTE: Do not ifdef the properties for dots instancing, but ifdef the actual usage.
// Otherwise you might break CPU-side as property constant-buffer offsets change per variant.
// NOTE: Dots instancing is orthogonal to the constant buffer above.
#ifdef UNITY_DOTS_INSTANCING_ENABLED

UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
    UNITY_DOTS_INSTANCED_PROP(float, _DoubleSidedModel)
    UNITY_DOTS_INSTANCED_PROP(float , _DetailScale)
    UNITY_DOTS_INSTANCED_PROP(float, _HasMRAMap)
    UNITY_DOTS_INSTANCED_PROP(float , _Roughness)
    UNITY_DOTS_INSTANCED_PROP(float , _EnableDetailMap)
    UNITY_DOTS_INSTANCED_PROP(float , _ReceiveFogEnabled)
    UNITY_DOTS_INSTANCED_PROP(float , _ReceiveShadowsEnabled)
    UNITY_DOTS_INSTANCED_PROP(float , _HasEmissionMap)
    UNITY_DOTS_INSTANCED_PROP(float , _AlphaClip)
    UNITY_DOTS_INSTANCED_PROP(float , _EmissionMapMultiply)
    UNITY_DOTS_INSTANCED_PROP(float, _NormalStrength)

    UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor)
    UNITY_DOTS_INSTANCED_PROP(float4 , _EmissionColor)
    UNITY_DOTS_INSTANCED_PROP(float4 , _DetailMapColor)
    UNITY_DOTS_INSTANCED_PROP(float4 , _DetailMap_ST)
    UNITY_DOTS_INSTANCED_PROP(float4 , _BaseMap_ST)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

#define _DoubleSidedModel             UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _DoubleSidedModel)
#define _DetailScale             UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _DetailScale)
#define _HasMRAMap               UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _HasMRAMap)
#define _Roughness               UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Roughness)
#define _EnableDetailMap         UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _EnableDetailMap)
#define _ReceiveFogEnabled       UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _ReceiveFogEnabled)
#define _ReceiveShadowsEnabled   UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _ReceiveShadowsEnabled)
#define _HasEmissionMap          UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _HasEmissionMap)
#define _AlphaClip               UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaClip)
#define _EmissionMapMultiply     UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _EmissionMapMultiply)
#define _NormalStrength          UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _NormalStrength)

#define _BaseColor               UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _BaseColor)
#define _EmissionColor           UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4  , _EmissionColor)
#define _DetailMapColor          UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4  , _DetailMapColor)
#define _DetailMap_ST            UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4  , _DetailMap_ST)
#define _BaseMap_ST              UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4  , _BaseMap_ST)

#endif

#endif