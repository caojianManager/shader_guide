using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
 
namespace UnityEngine.Rendering.Universal
{
    [Serializable,VolumeComponentMenu("Post-Processing/Outline")]
    public class OutlineVolume : VolumeComponent, IPostProcessComponent
    {
        [Tooltip("边缘颜色")]
        public ColorParameter  OutlineColor = new ColorParameter(Color.white);
        [Tooltip("边缘检测大小")]
        public ClampedFloatParameter Scale = new ClampedFloatParameter(1f, 0f, 10f);
        [Tooltip("深度")]
        public ClampedFloatParameter DepthThreshold = new ClampedFloatParameter(0.2f, 0f, 10f);
 
        [Tooltip("法线深度")]
        public ClampedFloatParameter NormalThreshold = new ClampedFloatParameter(0.4f, 0f, 1f);
        public ClampedFloatParameter DepthNormalThreshold = new ClampedFloatParameter(0.5f, 0f, 1f);
        public ClampedFloatParameter DepthNormalThresholdScale = new ClampedFloatParameter(7f, 0f, 10f);
 
 
        public bool IsActive() => Scale.value > 0;
 
        public bool IsTileCompatible() => false;
 
    }
}