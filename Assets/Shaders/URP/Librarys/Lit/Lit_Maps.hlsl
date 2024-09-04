#ifndef  LIT_MAPS_INCLUDED
#define  LIT_MAPS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D(_BaseMap);                      SAMPLER(sampler_BaseMap);
float4 _BaseMap_TexelSize;
float4 _BaseMap_MipInfo;
TEXTURE2D(_MaskMap);                      SAMPLER(sampler_MaskMap);
TEXTURE2D(_SpecularColorMap);             SAMPLER(sampler_SpecularColorMap);
TEXTURE2D(_NormalMap);                    SAMPLER(sampler_NormalMap);
TEXTURE2D(_BentNormalMap);                SAMPLER(sampler_BentNormalMap);
TEXTURE2D(_HeightMap);                    SAMPLER(sampler_HeightMap);
TEXTURE2D(_ClearCoatMap);                 SAMPLER(sampler_ClearCoatMap);
TEXTURE2D(_CoatNormalMap);                SAMPLER(sampler_CoatNormalMap);
TEXTURE2D(_DetailMap);                    SAMPLER(sampler_DetailMap);
TEXTURE2D(_TransmittanceColorMap);        SAMPLER(sampler_TransmittanceColorMap);
TEXTURE2D(_EmissionMap);                  SAMPLER(sampler_EmissionMap);

#endif
