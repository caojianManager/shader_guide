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
            MaterialProperty _ObjectPivotOffset = FindProperty("_ObjectPivotOffset", properties);
            MaterialProperty _ObjectPivotHeight = FindProperty("_ObjectPivotHeight", properties);
            MaterialProperty _DirtMap = FindProperty("_DirtMap", properties);

            MaterialProperty _LightEdgeMin = FindProperty("_LightEdgeMin", properties);
            MaterialProperty _LightEdgeMax = FindProperty("_LightEdgeMax", properties);
            MaterialProperty _ReceiveFogEnabled = FindProperty("_ReceiveFogEnabled", properties);
            MaterialProperty _ReceiveShadowsEnabled = FindProperty("_ReceiveShadowsEnabled", properties);
            MaterialProperty _Culling = FindProperty("_Culling", properties);
            MaterialProperty _ZTest = FindProperty("_ZTest", properties);
           
            //Surface
            MaterialProperty _Surface = FindProperty("_Surface", properties);
            MaterialProperty _Blend = FindProperty("_Blend", properties);
            MaterialProperty _AlphaClip = FindProperty("_AlphaClip", properties);
            MaterialProperty _AlphaClipEnabled = FindProperty("_AlphaClipEnabled", properties);
            MaterialProperty _SortPriority = FindProperty("_SortPriority", properties);
            
            DrawSurfaceOptions();
            DrawSurfaceInput();
            DrawAdvancedOptions();
            

            bool IsTransparent() => _Surface.floatValue > 0.0f ? true : false;
            bool AlphaClipEnabled() => _AlphaClipEnabled.floatValue > 0.0f ? true : false;

            void DrawSurfaceOptions()
            {
                 showSurfaceOptions = EditorGUILayout.BeginFoldoutHeaderGroup(showSurfaceOptions, "Surface Options");
                if (showSurfaceOptions)
                {
                    EditorGUI.indentLevel++;
                    materialEditor.IntPopupShaderProperty(_Surface, "Surface", _SurfaceOptions, _SurfaceValues);

                    mat.DisableKeyword("_ALPHAPREMULTIPLY_ON");

                    bool depthWrite = true;
                    if (IsTransparent())
                    {
                        mat.EnableKeyword("_SURFACE_TYPE_TRANSPARENT");
                        mat.SetOverrideTag("RenderType", "Transparent");
                        depthWrite = false;

                        CommonEditorGUI.DrawEnumProperty(GetAlphaBlendMode(_Blend), _Blend, new GUIContent("Blend"));

                        switch (GetAlphaBlendMode(_Blend))
                        {
                            case AlphaOptions.Alpha:
                                CommonEditorGUI.SetSrcDestProperties(mat, BlendMode.SrcAlpha, BlendMode.OneMinusSrcAlpha);
                                break;
                            case AlphaOptions.Premultiply:
                                CommonEditorGUI.SetSrcDestProperties(mat, BlendMode.One, BlendMode.OneMinusSrcAlpha);
                                mat.EnableKeyword("_ALPHAPREMULTIPLY_ON");
                                break;
                            case AlphaOptions.Additive:
                                CommonEditorGUI.SetSrcDestProperties(mat, BlendMode.One, BlendMode.One);
                                break;
                            case AlphaOptions.Multiply:
                                CommonEditorGUI.SetSrcDestProperties(mat, BlendMode.DstColor, BlendMode.Zero);
                                break;
                        }
                    }
                    else
                    {
                        mat.DisableKeyword("_SURFACE_TYPE_TRANSPARENT");
                        mat.SetOverrideTag("RenderType", "Opaque");
                        CommonEditorGUI.SetSrcDestProperties(mat, BlendMode.One, BlendMode.Zero);
                    }

                    matEditor.IntPopupShaderProperty(_Culling, "Render Face", _CullOptions, _CullValues);

                    matEditor.ShaderProperty(_AlphaClipEnabled, new GUIContent("Alpha Clip"));
                    if (AlphaClipEnabled())
                    {
                        EditorGUI.indentLevel++;
                        matEditor.ShaderProperty(_AlphaClip, new GUIContent("Threshold"));
                        EditorGUI.indentLevel--;
                    }

                    if (AlphaClipEnabled())
                    {
                        mat.EnableKeyword("_ALPHATEST_ON");
                    }
                    else
                    {
                        mat.DisableKeyword("_ALPHATEST_ON");
                    }

                    if (IsTransparent())
                    {
                        mat.renderQueue = (int)RenderQueue.Transparent + _SortPriority.intValue;
                    }
                    else
                    {
                        if (AlphaClipEnabled())
                        {
                            mat.renderQueue = (int)RenderQueue.AlphaTest + _SortPriority.intValue;
                        }
                        else
                        {
                            mat.renderQueue = (int)RenderQueue.Geometry + _SortPriority.intValue;
                        }
                    }

                    CommonEditorGUI.SetupDepthWriting(mat, depthWrite);

                    DrawToggleProperty(
                        _ReceiveShadowsEnabled,
                        new GUIContent(
                            "Receive Shadows",
                            "A setting that determines whether or not an object will receive shadows from other objects in the scene. When enabled, the object will appear to receive shadows, adding depth and realism to the scene."
                        )
                    );
                    EditorGUI.indentLevel--;
                    EditorGUILayout.Space();
                }

                EditorGUILayout.EndFoldoutHeaderGroup();
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
                    materialEditor.ShaderProperty(_ObjectPivotOffset, new GUIContent("PivotOffset"));
                    materialEditor.ShaderProperty(_ObjectPivotHeight, new GUIContent("PivotHeight"));
                    materialEditor.TexturePropertySingleLine(new GUIContent("Dirt Map"), _DirtMap);
                    materialEditor.ShaderProperty(_LightEdgeMin,new GUIContent("Edge Min"));
                    materialEditor.ShaderProperty(_LightEdgeMax,new GUIContent("Edge Max"));
                }
                EditorGUILayout.EndFoldoutHeaderGroup();
            }

            void DrawAdvancedOptions()
            {
                showAdvancedOptions = EditorGUILayout.BeginFoldoutHeaderGroup(showAdvancedOptions, "Advanced Options");
                if (showAdvancedOptions)
                {
                    materialEditor.ShaderProperty(_ReceiveFogEnabled, new GUIContent("Receive Fog"));
                    materialEditor.ShaderProperty(_ReceiveShadowsEnabled, new GUIContent("Receive Shadow"));
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

