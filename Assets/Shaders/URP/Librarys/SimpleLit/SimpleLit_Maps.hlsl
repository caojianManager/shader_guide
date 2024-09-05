#ifndef  SIMPLELIT_MAPS_INCLUDED
#define  SIMPLELIT_MAPS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
TEXTURE2D(_MRAMap);
SAMPLER(sampler_MRAMap);
TEXTURE2D(_EmissionMap);
SAMPLER(sampler_EmissionMap);

#endif
