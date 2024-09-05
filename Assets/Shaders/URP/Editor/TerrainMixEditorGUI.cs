using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace URPShaderEditor
{
    public class TerrainMixEditorGUI : ShaderGUI
    {
        bool showLayerOneOptions = true;
        bool showLayerTwoOptions = true;
        bool showLayerThreeOptions = true;
        bool showLayerFourOptions = true;

        private MaterialEditor matEditor;
        private Material mat;
        
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            this.matEditor = materialEditor;
            mat = matEditor.target as Material;
            
            //Material Property
            MaterialProperty _BlendContrast = FindProperty("_BlendContrast", properties);
            MaterialProperty _BlendMap = FindProperty("_BlendMap", properties);
            //Layer One
            MaterialProperty _Layer1_BaseMap = FindProperty("_Layer1_BaseMap", properties);
            MaterialProperty _Layer1_BaseColor = FindProperty("_Layer1_BaseColor", properties);
            MaterialProperty _Layer1_NormalMap = FindProperty("_Layer1_NormalMap", properties);
            MaterialProperty _Layer1_HRA = FindProperty("_Layer1_HRA", properties);
            MaterialProperty _Layer1_HeightContrast = FindProperty("_Layer1_HeightContrast", properties);
            //Layer Two
            MaterialProperty _Layer2_BaseMap = FindProperty("_Layer2_BaseMap", properties);
            MaterialProperty _Layer2_BaseColor = FindProperty("_Layer2_BaseColor", properties);
            MaterialProperty _Layer2_NormalMap = FindProperty("_Layer2_NormalMap", properties);
            MaterialProperty _Layer2_HRA = FindProperty("_Layer2_HRA", properties);
            MaterialProperty _Layer2_HeightContrast = FindProperty("_Layer2_HeightContrast", properties);
            //Layer Three
            MaterialProperty _Layer3_BaseMap = FindProperty("_Layer3_BaseMap", properties);
            MaterialProperty _Layer3_BaseColor = FindProperty("_Layer3_BaseColor", properties);
            MaterialProperty _Layer3_NormalMap = FindProperty("_Layer3_NormalMap", properties);
            MaterialProperty _Layer3_HRA = FindProperty("_Layer3_HRA", properties);
            MaterialProperty _Layer3_HeightContrast = FindProperty("_Layer3_HeightContrast", properties);
            //Layer Four
            MaterialProperty _Layer4_BaseMap = FindProperty("_Layer4_BaseMap", properties);
            MaterialProperty _Layer4_BaseColor = FindProperty("_Layer4_BaseColor", properties);
            MaterialProperty _Layer4_NormalMap = FindProperty("_Layer4_NormalMap", properties);
            MaterialProperty _Layer4_HRA = FindProperty("_Layer4_HRA", properties);
            MaterialProperty _Layer4_HeightContrast = FindProperty("_Layer4_HeightContrast", properties);
            
            DrawBlendOptions();
            DrawLayerOneOptions();
            DrawLayerTwoOptions();
            DrawLayerThreeOptions();
            DrawLayerFourOptions();

            void DrawBlendOptions()
            {
                materialEditor.ShaderProperty(_BlendContrast, new GUIContent("Blend Contrast"));
                materialEditor.TexturePropertySingleLine(
                    new GUIContent("Blend Map"),
                    _BlendMap);
            }
            
            void DrawLayerOneOptions()
            {
                showLayerOneOptions = EditorGUILayout.BeginFoldoutHeaderGroup(showLayerOneOptions, "Layer One Options");
                if (showLayerOneOptions)
                { 
                   EditorGUI.indentLevel++;
                   CommonEditorGUI.Instance.TexturePropertyWithColor(
                       materialEditor,
                        new GUIContent(
                            "Base Color",
                            "A property that defines its overall color. It serves as a starting point for calculating the final color of the surface after taking into account lighting, shadows, reflections, and other effects."
                        ),
                        _Layer1_BaseMap,
                        _Layer1_BaseColor,
                        true,
                        false
                    );
                    materialEditor.TexturePropertySingleLine(
                        new GUIContent("Normal Map"),
                        _Layer1_NormalMap);
                    materialEditor.TexturePropertySingleLine(
                        new GUIContent("HRA Map"),
                        _Layer1_HRA);
                    materialEditor.ShaderProperty(_Layer1_HeightContrast,
                        new GUIContent("Height Contrast"));
                    matEditor.TextureScaleOffsetProperty(_Layer1_BaseMap);
                    EditorGUI.indentLevel--;
                }
                EditorGUILayout.EndFoldoutHeaderGroup();
            }
            
            void DrawLayerTwoOptions()
            {
                showLayerTwoOptions = EditorGUILayout.BeginFoldoutHeaderGroup(showLayerTwoOptions, "Layer Two Options");
                if (showLayerTwoOptions)
                {
                    EditorGUI.indentLevel++;
                    CommonEditorGUI.Instance.TexturePropertyWithColor(
                        materialEditor,
                        new GUIContent(
                            "Base Color",
                            "A property that defines its overall color. It serves as a starting point for calculating the final color of the surface after taking into account lighting, shadows, reflections, and other effects."
                        ),
                        _Layer2_BaseMap,
                        _Layer2_BaseColor,
                        true,
                        false
                    );
                    materialEditor.TexturePropertySingleLine(
                        new GUIContent("Normal Map"),
                        _Layer2_NormalMap);
                    materialEditor.TexturePropertySingleLine(
                        new GUIContent("HRA Map"),
                        _Layer2_HRA);
                    materialEditor.ShaderProperty(_Layer2_HeightContrast,
                        new GUIContent("Height Contrast"));
                    matEditor.TextureScaleOffsetProperty(_Layer2_BaseMap);
                    EditorGUI.indentLevel--;
                }
             
                EditorGUILayout.EndFoldoutHeaderGroup();
            }
            
            void DrawLayerThreeOptions()
            {
                showLayerThreeOptions = EditorGUILayout.BeginFoldoutHeaderGroup(showLayerThreeOptions, "Layer Three Options");
                if (showLayerThreeOptions)
                {
                    EditorGUI.indentLevel++;
                    CommonEditorGUI.Instance.TexturePropertyWithColor(
                        materialEditor,
                        new GUIContent(
                            "Base Color",
                            "A property that defines its overall color. It serves as a starting point for calculating the final color of the surface after taking into account lighting, shadows, reflections, and other effects."
                        ),
                        _Layer3_BaseMap,
                        _Layer3_BaseColor,
                        true,
                        false
                    );
                    materialEditor.TexturePropertySingleLine(
                        new GUIContent("Normal Map"),
                        _Layer3_NormalMap);
                    materialEditor.TexturePropertySingleLine(
                        new GUIContent("HRA Map"),
                        _Layer3_HRA);
                    materialEditor.ShaderProperty(_Layer3_HeightContrast,
                        new GUIContent("Height Contrast"));
                    matEditor.TextureScaleOffsetProperty(_Layer3_BaseMap);
                    EditorGUI.indentLevel--;
                }
                EditorGUILayout.EndFoldoutHeaderGroup();
            }
            
            void DrawLayerFourOptions()
            {
                showLayerFourOptions = EditorGUILayout.BeginFoldoutHeaderGroup(showLayerFourOptions, "Layer Four Options");
                if (showLayerFourOptions)
                {
                    EditorGUI.indentLevel++;
                    CommonEditorGUI.Instance.TexturePropertyWithColor(
                        materialEditor,
                        new GUIContent(
                            "Base Color",
                            "A property that defines its overall color. It serves as a starting point for calculating the final color of the surface after taking into account lighting, shadows, reflections, and other effects."
                        ),
                        _Layer4_BaseMap,
                        _Layer4_BaseColor,
                        true,
                        false
                    );
                    materialEditor.TexturePropertySingleLine(
                        new GUIContent("Normal Map"),
                        _Layer4_NormalMap);
                    materialEditor.TexturePropertySingleLine(
                        new GUIContent("HRA Map"),
                        _Layer4_HRA);
                    materialEditor.ShaderProperty(_Layer4_HeightContrast,
                        new GUIContent("Height Contrast"));
                    matEditor.TextureScaleOffsetProperty(_Layer4_BaseMap);
                    EditorGUI.indentLevel--;
                }
                EditorGUILayout.EndFoldoutHeaderGroup();
            }
            
        }
    }
}

