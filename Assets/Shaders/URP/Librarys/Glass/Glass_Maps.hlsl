#ifndef GLASS_MAPS_INCLUDED
#define GLASS_MAPS_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D(_MatcapMap);
SAMPLER(sampler_MatcapMap);
TEXTURE2D(_RefractMap);
SAMPLER(sampler_RefractMap);
TEXTURE2D(_ThickMap);
SAMPLER(sampler_ThickMap);
TEXTURE2D(_DirtMap);
SAMPLER(sampler_DirtMap);

#endif