using UnityEditor.Rendering;
using UnityEngine.Rendering;
using UnityEditor;
using UnityEngine;

namespace URPShaderEditor.Skybox
{
    public class CubemapEditorGUI : ShaderGUI
    {
        
        private MaterialEditor matEditor;
        private Material mat;
        
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            this.matEditor = materialEditor;
            mat = matEditor.target as Material;
        }
    }
}