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
        
        public static void DrawInstancingFiled(MaterialEditor materialEditor)
        {
            materialEditor.EnableInstancingField();
        }
        
        public static void DrawConditionalTextureProperty(MaterialEditor matEditor,GUIContent content, MaterialProperty a, MaterialProperty b)
        {
            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = a.hasMixedValue || b.hasMixedValue;

            if (a.textureValue == null)
                b = null;

            matEditor.TexturePropertySingleLine(content, a, b);
            if (EditorGUI.EndChangeCheck())
            {
                if (b != null)
                {
                    b.floatValue = Mathf.Max(0, b.floatValue);
                }
            }
            EditorGUI.showMixedValue = false;
        }

        public static Vector4 DrawVector2(Vector4 vector,GUIContent content)
        {
            Vector2 tmpVector2 = new Vector2(x: vector.x, vector.y);
            tmpVector2 = EditorGUILayout.Vector2Field(new GUIContent(content), tmpVector2);
            vector = new Vector4(tmpVector2.x, tmpVector2.y, 0, 0);
            return vector;
        }
        
    }
}

