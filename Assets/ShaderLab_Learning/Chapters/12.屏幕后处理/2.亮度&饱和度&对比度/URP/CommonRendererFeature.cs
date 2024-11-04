using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


public class CommonRendererFeature : ScriptableRendererFeature
{

    public Shader shader;                                          // 用于后处理计算的Shader
    CopyTransparentColorPass postPass;                             // 后处理计算的Pass
    Material _Material = null;                                     // 根据Shader生成的材质

    public override void Create()
    {
        this.name = "BSC";                                                                  // 外部显示的名字
        postPass = new CopyTransparentColorPass();                                          // 初始化Pass
        postPass.renderPassEvent = RenderPassEvent.AfterRenderingTransparents;              // 渲染层级 = 透明物体渲染后
    }
    
    public override void SetupRenderPasses(ScriptableRenderer renderer, in RenderingData renderingData) {
        if (shader == null)                                                // 检测Shader是否存在
            return;
        if (_Material == null)                                             //创建材质
            _Material = CoreUtils.CreateEngineMaterial(shader);


        var cameraColorTarget = renderer.cameraColorTarget;              // 获取当前渲染的结果
        postPass.Setup(cameraColorTarget, _Material);                    // 设置调用后 处理Pass，初始化参数
    }
    
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(postPass);
    }
    
} 