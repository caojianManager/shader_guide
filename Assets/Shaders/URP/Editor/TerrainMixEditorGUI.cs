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
        bool showAdvancesOptions = true;


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
            MaterialProperty _Layer1_NormalScale = FindProperty("_Layer1_NormalScale", properties);
            MaterialProperty _Layer1_MRAH = FindProperty("_Layer1_MRAH", properties);
            MaterialProperty _Layer1_HeightContrast = FindProperty("_Layer1_HeightContrast", properties);
            MaterialProperty _Layer1_Metalness = FindProperty("_Layer1_Metalness", properties);
            MaterialProperty _Layer1_Roughness = FindProperty("_Layer1_Roughness", properties);
            //Layer Two
            MaterialProperty _Layer2_BaseMap = FindProperty("_Layer2_BaseMap", properties);
            MaterialProperty _Layer2_BaseColor = FindProperty("_Layer2_BaseColor", properties);
            MaterialProperty _Layer2_NormalMap = FindProperty("_Layer2_NormalMap", properties);
            MaterialProperty _Layer2_NormalScale = FindProperty("_Layer2_NormalScale", properties);
            MaterialProperty _Layer2_MRAH = FindProperty("_Layer2_MRAH", properties);
            MaterialProperty _Layer2_HeightContrast = FindProperty("_Layer2_HeightContrast", properties);
            MaterialProperty _Layer2_Enable = FindProperty("_Layer2_Enable", properties);
            MaterialProperty _Layer2_Metalness = FindProperty("_Layer2_Metalness", properties);
            MaterialProperty _Layer2_Roughness = FindProperty("_Layer2_Roughness", properties);
            //Layer Three
            MaterialProperty _Layer3_BaseMap = FindProperty("_Layer3_BaseMap", properties);
            MaterialProperty _Layer3_BaseColor = FindProperty("_Layer3_BaseColor", properties);
            MaterialProperty _Layer3_NormalMap = FindProperty("_Layer3_NormalMap", properties);
            MaterialProperty _Layer3_NormalScale = FindProperty("_Layer3_NormalScale", properties);
            MaterialProperty _Layer3_MRAH = FindProperty("_Layer3_MRAH", properties);
            MaterialProperty _Layer3_HeightContrast = FindProperty("_Layer3_HeightContrast", properties);
            MaterialProperty _Layer3_Enable = FindProperty("_Layer3_Enable", properties);
            MaterialProperty _Layer3_Metalness = FindProperty("_Layer3_Metalness", properties);
            MaterialProperty _Layer3_Roughness = FindProperty("_Layer3_Roughness", properties);
            //Layer Four
            MaterialProperty _Layer4_BaseMap = FindProperty("_Layer4_BaseMap", properties);
            MaterialProperty _Layer4_BaseColor = FindProperty("_Layer4_BaseColor", properties);
            MaterialProperty _Layer4_NormalMap = FindProperty("_Layer4_NormalMap", properties);
            MaterialProperty _Layer4_NormalScale = FindProperty("_Layer4_NormalScale", properties);
            MaterialProperty _Layer4_MRAH = FindProperty("_Layer4_MRAH", properties);
            MaterialProperty _Layer4_HeightContrast = FindProperty("_Layer4_HeightContrast", properties);
            MaterialProperty _Layer4_Enable = FindProperty("_Layer4_Enable", properties);
            MaterialProperty _Layer4_Metalness = FindProperty("_Layer4_Metalness", properties);
            MaterialProperty _Layer4_Roughness = FindProperty("_Layer4_Roughness", properties);
            
            MaterialProperty _ReceiveFogEnabled = FindProperty("_ReceiveFogEnabled", properties);
            MaterialProperty _ReceiveShadowsEnabled = FindProperty("_ReceiveShadowsEnabled", properties);
            
            DrawAdvancesOptions();
            DrawLayerOneOptions();
            DrawLayerTwoOptions();
            DrawLayerThreeOptions();
            DrawLayerFourOptions();

            void DrawAdvancesOptions()
            {
                showAdvancesOptions = EditorGUILayout.BeginFoldoutHeaderGroup(showAdvancesOptions, "Advances Options");
                if (showAdvancesOptions)
                {
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(_BlendContrast, new GUIContent("Blend Contrast"));
                    materialEditor.TexturePropertySingleLine(
                        new GUIContent("Blend Map"),
                        _BlendMap);
                    materialEditor.ShaderProperty(_ReceiveFogEnabled,new GUIContent("Receive Fog"));
                    materialEditor.ShaderProperty(_ReceiveShadowsEnabled,new GUIContent("Receive Shadow"));
                    EditorGUI.indentLevel--;
                }
                EditorGUILayout.EndFoldoutHeaderGroup();
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
                    CommonEditorGUI.DrawConditionalTextureProperty(materialEditor,new GUIContent("Normal Map"),_Layer1_NormalMap,_Layer1_NormalScale);
                    materialEditor.TexturePropertySingleLine(
                        new GUIContent("MRAH Map"),
                        _Layer1_MRAH);
                    EditorGUI.indentLevel += 2;
                    materialEditor.ShaderProperty(_Layer1_Metalness,new GUIContent("Metalness"));
                    materialEditor.ShaderProperty(_Layer1_Roughness,new GUIContent("Roughness"));
                    materialEditor.ShaderProperty(_Layer1_HeightContrast,
                        new GUIContent("Height Contrast"));
                    EditorGUI.indentLevel -= 2;
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
                    materialEditor.ShaderProperty(_Layer2_Enable, new GUIContent("Enable"));
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
                    CommonEditorGUI.DrawConditionalTextureProperty(materialEditor,new GUIContent("Normal Map"),_Layer2_NormalMap,_Layer2_NormalScale);
                    materialEditor.TexturePropertySingleLine(
                        new GUIContent("MRAH Map"),
                        _Layer2_MRAH);
                    EditorGUI.indentLevel += 2;
                    materialEditor.ShaderProperty(_Layer2_Metalness,new GUIContent("Metalness"));
                    materialEditor.ShaderProperty(_Layer2_Roughness,new GUIContent("Roughness"));
                    materialEditor.ShaderProperty(_Layer2_HeightContrast,
                        new GUIContent("Height Contrast"));
                    EditorGUI.indentLevel -= 2;
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
                    materialEditor.ShaderProperty(_Layer3_Enable, new GUIContent("Enable"));
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
                    CommonEditorGUI.DrawConditionalTextureProperty(materialEditor,new GUIContent("Normal Map"),_Layer3_NormalMap,_Layer3_NormalScale);
                    materialEditor.TexturePropertySingleLine(
                        new GUIContent("MRAH Map"),
                        _Layer3_MRAH);
                    EditorGUI.indentLevel += 2;
                    materialEditor.ShaderProperty(_Layer3_Metalness,new GUIContent("Metalness"));
                    materialEditor.ShaderProperty(_Layer3_Roughness,new GUIContent("Roughness"));
                    materialEditor.ShaderProperty(_Layer3_HeightContrast, new GUIContent("Height Contrast"));
                    EditorGUI.indentLevel -= 2;
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
                    materialEditor.ShaderProperty(_Layer4_Enable, new GUIContent("Enable"));
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
                    CommonEditorGUI.DrawConditionalTextureProperty(materialEditor,new GUIContent("Normal Map"),_Layer4_NormalMap,_Layer4_NormalScale);
                    materialEditor.TexturePropertySingleLine(
                        new GUIContent("MRAH Map"),
                        _Layer4_MRAH);
                    EditorGUI.indentLevel += 2;
                    materialEditor.ShaderProperty(_Layer4_Metalness,new GUIContent("Metalness"));
                    materialEditor.ShaderProperty(_Layer4_Roughness,new GUIContent("Roughness"));
                    materialEditor.ShaderProperty(_Layer4_HeightContrast, new GUIContent("Height Contrast"));
                    EditorGUI.indentLevel -= 2;
                    matEditor.TextureScaleOffsetProperty(_Layer4_BaseMap);
                    EditorGUI.indentLevel--;
                }
                EditorGUILayout.EndFoldoutHeaderGroup();
            }
            
        }
    }
}

