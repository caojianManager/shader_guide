using System;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

namespace URPShaderEditor
{
    public class CommonEditorGUI
    {
        private static CommonEditorGUI _instance;

        public static CommonEditorGUI Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = new CommonEditorGUI();
                }

                return _instance;
            }
        }
        
        
        public void DrawToggleProperty(MaterialProperty p, GUIContent c)
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
        
        public void TexturePropertyWithColor(
            MaterialEditor matEditor,
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
        
        public static void SetSrcDestProperties(Material t, BlendMode src, BlendMode dst)
        {
            t.SetFloat("_SrcBlend", (float)src);
            t.SetFloat("_DstBlend", (float)dst);
        }
        
        public static void SetupDepthWriting(Material t, bool depthWrite)
        {
            t.SetFloat("_ZWrite", depthWrite ? 1.0f : 0.0f);
            t.SetShaderPassEnabled("DepthOnly", depthWrite);
        }
        
        public static void DrawEnumProperty(Enum e, MaterialProperty p, GUIContent c)
        {
            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = p.hasMixedValue;
            var v = EditorGUILayout.EnumPopup(c, e);
            if (EditorGUI.EndChangeCheck())
            {
                p.floatValue = Convert.ToInt32(v);
            }
            EditorGUI.showMixedValue = false;
        }
        
        
    }
}

