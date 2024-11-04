using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[System.Serializable,]
public sealed class ColorAdjustment : VolumeComponent, IPostProcessComponent
{
    [Tooltip("是否开启效果")]
    public BoolParameter enableEffect = new BoolParameter(true);

    public ClampedFloatParameter brightness = new ClampedFloatParameter(1f, 0, 3);
    public ClampedFloatParameter saturation = new ClampedFloatParameter(1f, 0, 3);
    public ClampedFloatParameter contrast = new ClampedFloatParameter(1f, 0, 3);


    // 实现接口
    public bool IsActive() => enableEffect == true;
    public bool IsTileCompatible() => false;
} 