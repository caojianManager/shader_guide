using System;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

namespace URPShaderEditor
{
    public class DissloveEditorGUI : ShaderGUI
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