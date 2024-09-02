using UnityEditor.Rendering;
using UnityEngine.Rendering;
using UnityEditor;
using UnityEngine;

namespace URPShaderEditor
{
    public class PBRGlassEditor : ShaderGUI
    {
        public static readonly string[] _CullOptions = new string[] { "Both", "Back", "Front" };
        public static readonly int[] _CullValues = new int[] { 0, 1, 2 };

        public static readonly string[] _SurfaceOptions = new string[] { "Opaque", "Transparent" };
        public static readonly int[] _SurfaceValues = new int[] { 0, 1 };
        
        bool showSurfaceOptions = true;
        bool showDetailsOptions = true;
        bool showAdvancedOptions = true;

        private MaterialEditor matEditor;
        private Material mat;
        
        public enum AlphaOptions
        {
            Alpha,
            Premultiply,
            Additive,
            Multiply
        }

        private AlphaOptions GetAlphaBlendMode(MaterialProperty blend) => (AlphaOptions)blend.floatValue;

        
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            this.matEditor = materialEditor;
            mat = matEditor.target as Material;
            
            //Material Property
            MaterialProperty _MatcapMap = FindProperty("_MatcapMap", properties);
            MaterialProperty _MatcapColor = FindProperty("_MatcapColor", properties);
            MaterialProperty _RefractMap = FindProperty("_RefractMap", properties);
            MaterialProperty _RefractColor = FindProperty("_RefractColor", properties);
            MaterialProperty _RefractIntensity = FindProperty("_RefractIntensity", properties);
            MaterialProperty _ThickMap = FindProperty("_ThickMap", properties);
            MaterialProperty _DirtMap = FindProperty("_DirtMap", properties);
            MaterialProperty _LightEdgeMin = FindProperty("_LightEdgeMin", properties);
            MaterialProperty _LightEdgeMax = FindProperty("_LightEdgeMax", properties);
         
            //Surface
            
            DrawSurfaceOptions();
            DrawSurfaceInput();
            
            void DrawSurfaceOptions()
            {
                mat.EnableKeyword("_SURFACE_TYPE_TRANSPARENT");
                CommonEditorGUI.SetSrcDestProperties(mat, BlendMode.SrcAlpha, BlendMode.OneMinusSrcAlpha);
                mat.renderQueue = (int)RenderQueue.Transparent + 0;
                CommonEditorGUI.SetupDepthWriting(mat, false);
                EditorGUILayout.Space();
            }
            
            void DrawSurfaceInput()
            {
                showSurfaceOptions = EditorGUILayout.BeginFoldoutHeaderGroup(showSurfaceOptions, "Surface Inputs");
                if (showSurfaceOptions)
                {
                    EditorGUI.indentLevel++;
                    TexturePropertyWithColor(
                        new GUIContent(
                            "Matcap",
                            "A property that defines its overall color. It serves as a starting point for calculating the final color of the surface after taking into account lighting, shadows, reflections, and other effects."
                        ),
                        _MatcapMap,
                        _MatcapColor,
                        true,
                        false
                    );
                    TexturePropertyWithColor(
                        new GUIContent(
                            "Refract Map",
                            "A property that defines its overall color. It serves as a starting point for calculating the final color of the surface after taking into account lighting, shadows, reflections, and other effects."
                        ),
                        _RefractMap,
                        _RefractColor,
                        true,
                        false
                        );
                    materialEditor.ShaderProperty(_RefractIntensity,new GUIContent("RefractIntensity"));
                    materialEditor.TexturePropertySingleLine(new GUIContent("Thick Map"), _ThickMap);
                    materialEditor.TexturePropertySingleLine(new GUIContent("Dirt Map"), _DirtMap);
                    materialEditor.ShaderProperty(_LightEdgeMin,new GUIContent("Edge Min"));
                    materialEditor.ShaderProperty(_LightEdgeMax,new GUIContent("Edge Max"));
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

