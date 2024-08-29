using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace URPShader
{
    public class PBRLitEditorGUI : ShaderGUI
    {
        bool showSurfaceOptions = true;
        bool showDetailsOptions = true;
        bool showAdvancedOptions = true;

        private MaterialEditor matEditor;
        private Material mat;
        
        
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            this.matEditor = materialEditor;
            mat = matEditor.target as Material;
            
            //Material Property
            MaterialProperty _MRAMap = FindProperty("_MRAMap", properties);
            MaterialProperty _HasMRAMap = FindProperty("_HasMRAMap", properties);
            MaterialProperty _BaseMap = FindProperty("_BaseMap", properties);
            MaterialProperty _BaseColor = FindProperty("_BaseColor", properties);
            MaterialProperty _NormalMap = FindProperty("_NormalMap", properties);
            MaterialProperty _EnableDetailMap = FindProperty("_EnableDetailMap", properties);
            MaterialProperty _DetailMap = FindProperty("_DetailMap", properties);
            MaterialProperty _DetailNormalMap = FindProperty("_DetailNormalMap", properties);
            MaterialProperty _DetailMapColor = FindProperty("_DetailMapColor", properties);
            MaterialProperty _DetailScale = FindProperty("_DetailScale", properties);
            MaterialProperty _ReceiveFogEnabled = FindProperty("_ReceiveFogEnabled", properties);
            
            DrawMraOptions();
            DrawSurfaceOptions();
            DrawDetailsOptions();
            DrawAdvancedOptions();

            void DrawMraOptions()
            {
                EditorGUI.BeginChangeCheck();
                materialEditor.TexturePropertySingleLine(
                    new GUIContent("MRA Map"),
                    _MRAMap);
                if(EditorGUI.EndChangeCheck())
                {
                    _HasMRAMap.floatValue = (_MRAMap.textureValue == null ? 0: 1);
                }
            }
            
            void DrawSurfaceOptions()
            {
                showSurfaceOptions = EditorGUILayout.BeginFoldoutHeaderGroup(showSurfaceOptions, "Surface Options");
                if (showSurfaceOptions)
                {
                    EditorGUI.indentLevel++;
                    TexturePropertyWithColor(
                        new GUIContent(
                            "Base Color",
                            "A property that defines its overall color. It serves as a starting point for calculating the final color of the surface after taking into account lighting, shadows, reflections, and other effects."
                        ),
                        _BaseMap,
                        _BaseColor,
                        true,
                        false
                    );
                    materialEditor.TexturePropertySingleLine(
                        new GUIContent("Normal Map"),
                        _NormalMap);
                }

                matEditor.TextureScaleOffsetProperty(_BaseMap);
                EditorGUILayout.EndFoldoutHeaderGroup();
            }
            
            void DrawAdvancedOptions()
            {
                showAdvancedOptions = EditorGUILayout.BeginFoldoutHeaderGroup(showAdvancedOptions, "Advanced Options");
                if (showAdvancedOptions)
                {
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(_ReceiveFogEnabled, new GUIContent("Receive Fog"));
                    EditorGUI.indentLevel--;
                    EditorGUILayout.Space();
                }
                EditorGUILayout.EndFoldoutHeaderGroup();
            }
            
            void TexturePropertyWithColor(
                GUIContent label,
                MaterialProperty textureProp,
                MaterialProperty colorProperty,
                bool showAlpha = true,
                bool showHdr = true
            )
            {
                Rect controlRectForSingleLine = EditorGUILayout.GetControlRect(true, MaterialEditor.GetDefaultPropertyHeight(colorProperty));

                matEditor.TexturePropertyMiniThumbnail(controlRectForSingleLine, textureProp, label.text, label.tooltip);

                int indentLevel = EditorGUI.indentLevel;
                EditorGUI.indentLevel = 0;
                EditorGUI.BeginChangeCheck();
                EditorGUI.showMixedValue = colorProperty.hasMixedValue;
                Color colorValue = EditorGUI.ColorField(
                    MaterialEditor.GetRectAfterLabelWidth(controlRectForSingleLine),
                    GUIContent.none,
                    colorProperty.colorValue,
                    showEyedropper: true,
                    showAlpha,
                    showHdr
                );
                EditorGUI.showMixedValue = false;
                if (EditorGUI.EndChangeCheck())
                {
                    colorProperty.colorValue = colorValue;
                }

                EditorGUI.indentLevel = indentLevel;
            }

            void DrawDetailsOptions()
            {
                showDetailsOptions = EditorGUILayout.BeginFoldoutHeaderGroup(showDetailsOptions, "Detail Options");
                if (showDetailsOptions)
                {
                    DrawToggleProperty(_EnableDetailMap, new GUIContent("Enabled"));
                    TexturePropertyWithColor(
                        new GUIContent(
                            "Base Color",
                            "A property that defines its overall color. It serves as a starting point for calculating the final color of the surface after taking into account lighting, shadows, reflections, and other effects."
                        ),
                        _DetailMap,
                        _DetailMapColor,
                        true,
                        false
                    );
                    
                    materialEditor.TexturePropertySingleLine(
                        new GUIContent("Normal Map"),
                        _DetailNormalMap);
                    materialEditor.ShaderProperty(_DetailScale,
                        new GUIContent("Detail Scale"));
                }
                matEditor.TextureScaleOffsetProperty(_DetailMap);
                EditorGUILayout.EndFoldoutHeaderGroup();
            }
            
            void DrawToggleProperty(MaterialProperty p, GUIContent c)
            {
                EditorGUI.BeginChangeCheck();
                EditorGUI.showMixedValue = p.hasMixedValue;
                bool v = EditorGUILayout.Toggle(c, p.floatValue == 1.0f);
                if (EditorGUI.EndChangeCheck())
                {
                    p.floatValue = v ? 1.0f : 0.0f;
                }
                EditorGUI.showMixedValue = false;
            }
        }

        
    }
    
}

