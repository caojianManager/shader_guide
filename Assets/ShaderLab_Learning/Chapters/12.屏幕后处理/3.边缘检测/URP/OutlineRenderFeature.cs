using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
 
 
public class OutlineRenderFeature : ScriptableRendererFeature
{
    [System.Serializable]
    // 定义3个共有变量
    public class Settings
    {
        //public Shader shader; // 设置后处理shader
        public Material material; //后处理Material
        public RenderPassEvent renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing; // 定义事件位置，放在了官方的后处理之前
    }
 
    // 初始化一个刚刚定义的Settings类
    public Settings settings = new Settings(); 
    // 初始化Pass
    OutlinePass outlinePass;
 
    // 给pass传递变量，并加入渲染管线中
    public override void Create()
    {
        this.name = "OutlinePass"; // 外部显示的名字
        this.
        outlinePass = new OutlinePass(settings.renderPassEvent, settings.material);
    }
 
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(outlinePass);
    }
 
    
}
 
