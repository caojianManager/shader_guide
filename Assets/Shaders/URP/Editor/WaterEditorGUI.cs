using UnityEditor;
using UnityEngine;

namespace URPShaderEditor
{
    public class WaterEditorGUI : ShaderGUI
    {
        private MaterialEditor matEditor;
        private Material mat;

        private bool showBaseOptions = true;
        private bool showNormalOptions = true;
        private bool showReflectionOptions = true;
        private bool shwoCausticsOptions = true;
        private bool showShoreOptions = true;
        private bool showWaveOptions = true;
        private bool showFoamOptions = true;
        
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            this.matEditor = materialEditor;
            mat = matEditor.target as Material;

            //BaseOptions
            MaterialProperty _ShallowColor = FindProperty("_ShallowColor", properties);
            MaterialProperty _DeepColor = FindProperty("_DeepColor", properties);
            MaterialProperty _DeepRange = FindProperty("_DeepRange", properties);
            MaterialProperty _FresnelColor = FindProperty("_FresnelColor", properties);
            MaterialProperty _FresnelPower = FindProperty("_FresnelPower", properties);
            MaterialProperty _UnderWaterDistort = FindProperty("_UnderWaterDistort", properties);
            //NormalOptions
            MaterialProperty _NormalMap = FindProperty("_NormalMap", properties);
            MaterialProperty _NormalSpeed = FindProperty("_NormalSpeed", properties);
            MaterialProperty _NormalScale = FindProperty("_NormalScale", properties);
            //ReflectionOptions
            MaterialProperty _ReflectDistortion = FindProperty("_ReflectDistortion", properties);
            MaterialProperty _ReflectPower = FindProperty("_ReflectPower", properties);
            MaterialProperty _ReflectIntensity = FindProperty("_ReflectIntensity", properties);
            MaterialProperty _GlossPower = FindProperty("_GlossPower", properties);
            //CausticsOptions
            MaterialProperty _CausticsMap = FindProperty("_CausticsMap", properties);
            MaterialProperty _CausticsScale = FindProperty("_CausticsScale", properties);
            MaterialProperty _CausticsIntensity = FindProperty("_CausticsIntensity", properties);
            MaterialProperty _CausticsRange = FindProperty("_CausticsRange", properties);
            MaterialProperty _CausticsSpeed = FindProperty("_CausticsSpeed", properties);
            //Shore
            MaterialProperty _ShoreEnable = FindProperty("_ShoreEnable", properties);
            MaterialProperty _ShoreColor = FindProperty("_ShoreColor", properties);
            MaterialProperty _ShoreRange = FindProperty("_ShoreRange", properties);
            MaterialProperty _ShoreEdgeWidth = FindProperty("_ShoreEdgeWidth", properties);
            MaterialProperty _ShoreEdgeIntensity = FindProperty("_ShoreEdgeIntensity", properties);
            //Wave
            MaterialProperty _WaveAmplitude = FindProperty("_WaveAmplitude", properties);
            MaterialProperty _WaveLength = FindProperty("_WaveLength", properties);
            MaterialProperty _WaveSpeed = FindProperty("_WaveSpeed", properties);
            MaterialProperty _WaveEnable = FindProperty("_WaveEnable", properties);
            //Foam
            MaterialProperty _FoamEnable = FindProperty("_FoamEnable", properties);
            MaterialProperty _FoamMap = FindProperty("_FoamMap", properties);
            MaterialProperty _FoamColor = FindProperty("_FoamColor", properties);
            MaterialProperty _FoamDirection = FindProperty("_FoamDirection", properties);
            MaterialProperty _FoamSpeed = FindProperty("_FoamSpeed", properties);
            MaterialProperty _FoamFastSpeed = FindProperty("_FoamFastSpeed", properties);
            MaterialProperty _FoamContrast = FindProperty("_FoamContrast", properties);
            MaterialProperty _FoamRange = FindProperty("_FoamRange", properties);
            
            DrawBaseOptions();
            DrawNormalOptions();
            DrawReflectionOptions();
            DrawCausticsOptions();
            DrawShoreOptions();
            DrawWaveOptions();
            DrawFoamOptions();

            void DrawBaseOptions()
            {
                showBaseOptions = EditorGUILayout.BeginFoldoutHeaderGroup(showBaseOptions, "Base Options");
                if (showBaseOptions)
                {
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(_ShallowColor,new GUIContent("Shallow Color"));
                    materialEditor.ShaderProperty(_DeepColor,new GUIContent("Deep Color"));
                    materialEditor.ShaderProperty(_DeepRange,new GUIContent("Deep Range"));
                    materialEditor.ShaderProperty(_FresnelColor,new GUIContent("Fresnel Color"));
                    materialEditor.ShaderProperty(_FresnelPower,new GUIContent("Fresnel Power"));
                    materialEditor.ShaderProperty(_UnderWaterDistort,new GUIContent("Under Water Distort"));
               
                }
                EditorGUILayout.EndFoldoutHeaderGroup();
            }

            void DrawNormalOptions()
            {
                showNormalOptions = EditorGUILayout.BeginFoldoutHeaderGroup(showNormalOptions, "Normal Options");
                if (showNormalOptions)
                {
                    materialEditor.TexturePropertySingleLine(new GUIContent("Normal Map"), _NormalMap);
                    _NormalSpeed.vectorValue = CommonEditorGUI.DrawVector2(_NormalSpeed.vectorValue, new GUIContent("Normal Speed"));
                    materialEditor.ShaderProperty(_NormalScale,new GUIContent("Normal Scale"));
                    materialEditor.TextureScaleOffsetProperty(_NormalMap);
                }
                EditorGUILayout.EndFoldoutHeaderGroup();
            }

            void DrawReflectionOptions()
            {
                showReflectionOptions = EditorGUILayout.BeginFoldoutHeaderGroup(showReflectionOptions, "Reflection Options");
                if (showReflectionOptions)
                {
                    materialEditor.ShaderProperty(_ReflectDistortion,new GUIContent("Reflect Distort"));
                    materialEditor.ShaderProperty(_ReflectPower,new GUIContent("Reflect Power"));
                    materialEditor.ShaderProperty(_ReflectIntensity,new GUIContent("Reflect Intensity"));
                    materialEditor.ShaderProperty(_GlossPower,new GUIContent("Gloss Power"));
                }
                EditorGUILayout.EndFoldoutHeaderGroup();
            }

            void DrawCausticsOptions()
            {
                shwoCausticsOptions = EditorGUILayout.BeginFoldoutHeaderGroup(shwoCausticsOptions, "Caustics Options");
                if (shwoCausticsOptions)
                {
                    materialEditor.TexturePropertySingleLine(new GUIContent("Caustics Map"), _CausticsMap);
                    materialEditor.ShaderProperty(_CausticsScale,new GUIContent("Caustics Scale"));
                    materialEditor.ShaderProperty(_CausticsIntensity,new GUIContent("Caustics Intensity"));
                    materialEditor.ShaderProperty(_CausticsRange,new GUIContent("Caustics Range"));
                    _CausticsSpeed.vectorValue = CommonEditorGUI.DrawVector2(_CausticsSpeed.vectorValue, new GUIContent("Caustics Speed"));
                }
                EditorGUILayout.EndFoldoutHeaderGroup();
            }

            void DrawShoreOptions()
            {
                showShoreOptions = EditorGUILayout.BeginFoldoutHeaderGroup(showShoreOptions, "Shore Options");
                if (showShoreOptions)
                {
                    materialEditor.ShaderProperty(_ShoreEnable,new GUIContent("Shore Enable"));
                    materialEditor.ShaderProperty(_ShoreColor,new GUIContent("Shore Color"));
                    materialEditor.ShaderProperty(_ShoreRange,new GUIContent("Shore Range"));
                    materialEditor.ShaderProperty(_ShoreEdgeWidth,new GUIContent("Edge Width"));
                    materialEditor.ShaderProperty(_ShoreEdgeIntensity,new GUIContent("Edge Intensity"));
                }
                EditorGUILayout.EndFoldoutHeaderGroup();
            }

            void DrawWaveOptions()
            {
                showWaveOptions = EditorGUILayout.BeginFoldoutHeaderGroup(showWaveOptions, "Wave Options");
                if (showWaveOptions)
                {
                    materialEditor.ShaderProperty(_WaveEnable,new GUIContent("Enable"));
                    materialEditor.ShaderProperty(_WaveAmplitude,new GUIContent("Wave Amplitude"));
                    materialEditor.ShaderProperty(_WaveLength,new GUIContent("Wave Length"));
                    materialEditor.ShaderProperty(_WaveSpeed,new GUIContent("Wave Speed"));
                }
                EditorGUILayout.EndFoldoutHeaderGroup();
            }

            void DrawFoamOptions()
            {
                showFoamOptions = EditorGUILayout.BeginFoldoutHeaderGroup(showFoamOptions, "Foam Options");
                if (showFoamOptions)
                {
                    materialEditor.ShaderProperty(_FoamEnable,new GUIContent("Foam Enable"));
                    CommonEditorGUI.DrawConditionalTextureProperty(materialEditor,new GUIContent("Foam Map"),_FoamMap,_FoamColor);
                    _FoamDirection.vectorValue =
                        CommonEditorGUI.DrawVector2(_FoamDirection.vectorValue, new GUIContent("Foam Direction"));
                    materialEditor.ShaderProperty(_FoamSpeed,new GUIContent("Foam Speed"));
                    materialEditor.ShaderProperty(_FoamFastSpeed,new GUIContent("Foam Fast Speed"));
                    materialEditor.ShaderProperty(_FoamContrast,new GUIContent("Foam Contrast"));
                    materialEditor.ShaderProperty(_FoamRange,new GUIContent("Foam Range"));
                    EditorGUI.indentLevel--;
                }
                EditorGUILayout.EndFoldoutHeaderGroup();
            }
        }
    }
}