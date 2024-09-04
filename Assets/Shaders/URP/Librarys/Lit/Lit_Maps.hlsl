#ifndef  LIT_MAPS_INCLUDED
#define  LIT_MAPS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D(_BlendMap);
SAMPLER(sampler_BlendMap);

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
TEXTURE2D(_DetailMap);
SAMPLER(sampler_DetailMap);
TEXTURE2D(_DetailNormalMap);
SAMPLER(sampler_DetailNormalMap);
TEXTURE2D(_MRAMap);
SAMPLER(sampler_MRAMap);
TEXTURE2D(_EmissionMap);
SAMPLER(sampler_EmissionMap);

#endif
