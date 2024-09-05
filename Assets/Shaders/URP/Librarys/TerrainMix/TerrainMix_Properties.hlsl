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

#ifdef UNITY_DOTS_INSTANCING_ENABLED
UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
    UNITY_DOTS_INSTANCED_PROP(float4 , _Layer1_BaseMap_ST)
    UNITY_DOTS_INSTANCED_PROP(float4, _Layer2_BaseMap_ST)
    UNITY_DOTS_INSTANCED_PROP(float4 , _Layer3_BaseMap_ST)
    UNITY_DOTS_INSTANCED_PROP(float4 , _Layer4_BaseMap_ST)
    UNITY_DOTS_INSTANCED_PROP(float4 , _Layer1_BaseColor)
    UNITY_DOTS_INSTANCED_PROP(float4, _Layer2_BaseColor)
    UNITY_DOTS_INSTANCED_PROP(float4 , _Layer3_BaseColor)
    UNITY_DOTS_INSTANCED_PROP(float4 , _Layer4_BaseColor)
    UNITY_DOTS_INSTANCED_PROP(float , _BlendContrast)
    UNITY_DOTS_INSTANCED_PROP(float, _Layer1_HeightContrast)
    UNITY_DOTS_INSTANCED_PROP(float , _Layer2_HeightContrast)
    UNITY_DOTS_INSTANCED_PROP(float , _Layer3_HeightContrast)
    UNITY_DOTS_INSTANCED_PROP(float , _Layer4_HeightContrast)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

#define _Layer1_BaseMap_ST          UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4  , _Layer1_BaseMap_ST)
#define _Layer2_BaseMap_ST          UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4  , _Layer2_BaseMap_ST)
#define _Layer3_BaseMap_ST          UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4  , _Layer3_BaseMap_ST)
#define _Layer4_BaseMap_ST          UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4  , _Layer4_BaseMap_ST)
#define _Layer1_BaseColor           UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4  , _Layer1_BaseColor)
#define _Layer2_BaseColor           UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4  , _Layer2_BaseColor)
#define _Layer3_BaseColor           UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4  , _Layer3_BaseColor)
#define _Layer4_BaseColor           UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4  , _Layer4_BaseColor)
#define _BlendContrast              UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _BlendContrast)
#define _Layer1_HeightContrast      UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Layer1_HeightContrast)
#define _Layer2_HeightContrast      UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Layer2_HeightContrast)
#define _Layer3_HeightContrast      UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Layer3_HeightContrast)
#define _Layer4_HeightContrast      UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Layer4_HeightContrast)
#endif

#endif