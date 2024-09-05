#ifndef TERRAINMIX_MAPS_INCLUDED
#define TERRAINMIX_MAPS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D(_BlendMap);
SAMPLER(sampler_BlendMap);

TEXTURE2D(_Layer1_BaseMap);
SAMPLER(sampler_Layer1_BaseMap);
TEXTURE2D(_Layer1_NormalMap);
SAMPLER(sampler_Layer1_NormalMap);
TEXTURE2D(_Layer1_MRAH);
SAMPLER(sampler_Layer1_MRAH);

TEXTURE2D(_Layer2_BaseMap);
SAMPLER(sampler_Layer2_BaseMap);
TEXTURE2D(_Layer2_NormalMap);
SAMPLER(sampler_Layer2_NormalMap);
TEXTURE2D(_Layer2_MRAH);
SAMPLER(sampler_Layer2_MRAH);

TEXTURE2D(_Layer3_BaseMap);
SAMPLER(sampler_Layer3_BaseMap);
TEXTURE2D(_Layer3_NormalMap);
SAMPLER(sampler_Layer3_NormalMap);
TEXTURE2D(_Layer3_MRAH);
SAMPLER(sampler_Layer3_MRAH);

TEXTURE2D(_Layer4_BaseMap);
SAMPLER(sampler_Layer4_BaseMap);
TEXTURE2D(_Layer4_NormalMap);
SAMPLER(sampler_Layer4_NormalMap);
TEXTURE2D(_Layer4_MRAH);
SAMPLER(sampler_Layer4_MRAH);

#endif