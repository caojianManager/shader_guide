using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CopyTransparentColorPass : ScriptableRenderPass
{

    const string CommandBufferTag = "AdditionalPostProcessing Pass";      // 标签名字

    public Material m_Material;                                           // 后处理材质
    ColorAdjustment m_ColorAdjustment;                                    // 属性参数组件

    RenderTargetIdentifier m_ColorAttachment;                             // 渲染输入的原图
    RenderTargetHandle m_TemporaryColorTexture01;                         // 临时渲染结果(临时RT)

    public void Setup(RenderTargetIdentifier _ColorAttachment, Material material)
    {

        this.m_ColorAttachment = _ColorAttachment;                               // 初始化输入纹理
        m_Material = material;                                                   // 初始化材质
    }
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {

        var stack = VolumeManager.instance.stack;                                              // 获取所有继承Volume框架的脚本。
        m_ColorAdjustment = stack.GetComponent<ColorAdjustment>();                             // 查找对应的属性参数组件
        var cmd = CommandBufferPool.Get(CommandBufferTag);                                     // 从命令缓冲区池中获取一个带标签的命令缓冲区，该标签名可以在后续帧调试器中见到

        Render(cmd, ref renderingData);                                                          // 调用渲染函数

        context.ExecuteCommandBuffer(cmd);                                                       // 执行命令缓冲区
        CommandBufferPool.Release(cmd);                                                          // 释放缓存区
        cmd.ReleaseTemporaryRT(m_TemporaryColorTexture01.id);                                    // 输出临时RT
    }

    void Render(CommandBuffer cmd, ref RenderingData renderingData)
    {
        // 判断组件是否开启，且非Scene视图摄像机
        if(m_ColorAdjustment.IsActive() && !renderingData.cameraData.isSceneViewCamera)
        {
                                                                                                               // 写入参数 获取Shader的数据和Vol组件的绑定
            m_Material.SetFloat("_Brightness", m_ColorAdjustment.brightness.value);
            m_Material.SetFloat("_Saturation", m_ColorAdjustment.saturation.value);
            m_Material.SetFloat("_Contrast", m_ColorAdjustment.contrast.value);

            RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;              // 创建RT

            opaqueDesc.depthBufferBits = 0;                                                                    // 设置深度缓存区，就深度缓冲区的精度为0，
            cmd.GetTemporaryRT(m_TemporaryColorTexture01.id, opaqueDesc);                                      // 通过目标相机的渲染信息创建临时缓冲区
            cmd.Blit(m_ColorAttachment, m_TemporaryColorTexture01.Identifier(), m_Material);                   // 输入纹理经过材质计算输出到缓冲区
            cmd.Blit(m_TemporaryColorTexture01.Identifier(), m_ColorAttachment);                               // 再从临时缓冲区存入主纹理
        }
    }
} 