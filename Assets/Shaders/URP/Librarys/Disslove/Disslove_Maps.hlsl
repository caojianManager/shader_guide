#ifndef DISSLOVE_MAPS_INCLUDED
#define DISSLOVE_MAPS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
TEXTURE2D(_NoiseMap);
SAMPLER(sampler_NoiseMap);

#endif
