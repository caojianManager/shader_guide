using System;
using UnityEditor;
using UnityEditor.Rendering;
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

            MaterialProperty _BaseMap = FindProperty("_BaseMap", properties);
            MaterialProperty _BaseColor = FindProperty("_BaseColor", properties);
            MaterialProperty _NoiseMap = FindProperty("_NoiseMap", properties);
            MaterialProperty _EdgeColor = FindProperty("_EdgeColor", properties);
            MaterialProperty _EdgeColorIntensity = FindProperty("_EdgeColorIntensity", properties);
            MaterialProperty _EdgeWidth = FindProperty("_EdgeWidth", properties);
            MaterialProperty _Amout = FindProperty("_Amout", properties);
            MaterialProperty _Spreed = FindProperty("_Spreed", properties);
            MaterialProperty _AutoDisslove = FindProperty("_AutoDisslove", properties);
            
            DrawOptions();

            void DrawOptions()
            {
                EditorGUI.indentLevel++;
                CommonEditorGUI.DrawConditionalTextureProperty(materialEditor,new GUIContent("Base Map"),_BaseMap,_BaseColor);
                CommonEditorGUI.DrawConditionalTextureProperty(materialEditor,new GUIContent("Noise Map"),_NoiseMap,_EdgeColor);
                materialEditor.ShaderProperty(_Amout,new GUIContent("Amout"));
                materialEditor.ShaderProperty(_EdgeColorIntensity,new GUIContent("Edge Color Intensity"));
                materialEditor.ShaderProperty(_EdgeWidth,new GUIContent("Edge Width"));
                materialEditor.ShaderProperty(_Spreed,new GUIContent("Spreed"));
                materialEditor.ShaderProperty(_AutoDisslove,new GUIContent("AutoDisslove"));
            }
        }
    }
}