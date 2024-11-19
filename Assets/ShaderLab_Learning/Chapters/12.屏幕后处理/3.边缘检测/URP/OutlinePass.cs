
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class OutlinePass : ScriptableRenderPass
{
    static readonly string renderTag = "Post Effects"; // 定义渲染Tag
    Material tmaterial;
    OutlineVolume outlineVolume; // 传递到volume,OutlineVolume是Volume那个类定义的类名

    public OutlinePass(RenderPassEvent evt, Material tmaterial)
    {
        renderPassEvent = evt; // 设置渲染事件位置
        //var shader = tshader;  // 输入shader信息
        var material = tmaterial;
        if (material == null)
        {
            Debug.LogError("没有指定Material");
            return;
        }
    }

    // 后处理逻辑和渲染核心函数，相当于build-in 的OnRenderImage()
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        // 判断是否开启后处理
        if (!renderingData.cameraData.postProcessEnabled)
        {
            return;
        }

        // 渲染设置
        var stack = VolumeManager.instance.stack; // 传入volume
        outlineVolume = stack.GetComponent<OutlineVolume>(); // 拿到我们的volume
        if (outlineVolume == null)
        {
            Debug.LogError("Volume组件获取失败");
            return;
        }

        var cmd = CommandBufferPool.Get(renderTag); // 设置渲染标签
        Render(cmd, ref renderingData); // 设置渲染函数
        context.ExecuteCommandBuffer(cmd); // 执行函数
        CommandBufferPool.Release(cmd); // 释放
    }

    void Render(CommandBuffer cmd, ref RenderingData renderingData)
    {

        if (!renderingData.cameraData.isSceneViewCamera && tmaterial != null)
        {
            RenderTargetIdentifier source = renderingData.cameraData.renderer.cameraColorTarget; // 定义RT
            RenderTextureDescriptor inRTDesc = renderingData.cameraData.cameraTargetDescriptor;
            inRTDesc.depthBufferBits = 0; // 清除深度

            var camera = renderingData.cameraData.camera; // 传入摄像机
            Matrix4x4 clipToView = GL.GetGPUProjectionMatrix(camera.projectionMatrix, true).inverse;

            tmaterial.SetColor("_Color", outlineVolume.OutlineColor.value); // 获取value 组件的颜色

            tmaterial.SetMatrix("_ClipToView", clipToView); // 反向输出到Shader

            tmaterial.SetFloat("_Scale", outlineVolume.Scale.value);
            tmaterial.SetFloat("_DepthThreshold", outlineVolume.DepthThreshold.value);
            tmaterial.SetFloat("_NormalThreshold", outlineVolume.NormalThreshold.value);

            tmaterial.SetFloat("_DepthNormalThreshold", outlineVolume.DepthNormalThreshold.value);
            tmaterial.SetFloat("_DepthNormalThresholdScale", outlineVolume.DepthNormalThresholdScale.value);

            int destination = Shader.PropertyToID("Temp1");

            // 获取一张临时RT
            cmd.GetTemporaryRT(destination, inRTDesc.width, inRTDesc.height, 0, FilterMode.Bilinear,
                RenderTextureFormat.DefaultHDR); //申请一个临时图像，并设置相机rt的参数进去

            cmd.Blit(source, destination); // 设置后处理


            cmd.Blit(destination, source, tmaterial, 0);
        }
        
    }
}