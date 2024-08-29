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
            MaterialProperty _DetailMap = FindProperty("_DetailMap", properties);
            MaterialProperty _DetailNormalMap = FindProperty("_DetailNormalMap", properties);
            MaterialProperty _DetailMapColor = FindProperty("_DetailMapColor", properties);
            MaterialProperty _DetailScale = FindProperty("_DetailScale", properties);
            
            DrawMraOptions();
            DrawSurfaceOptions();
            DrawDetailsOptions();

            void DrawMraOptions()
            {
                materialEditor.TexturePropertySingleLine(
                    new GUIContent("MRA Map"),
                    _MRAMap);
                _HasMRAMap.floatValue = (_HasMRAMap.textureValue == null ? 0: 1);
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
        }

        
    }
    
}

