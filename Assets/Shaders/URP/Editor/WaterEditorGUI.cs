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
            
            DrawBaseOptions();
            DrawNormalOptions();
            DrawReflectionOptions();
            DrawCausticsOptions();

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
                    EditorGUI.indentLevel--;
                }
                EditorGUILayout.EndFoldoutHeaderGroup();
            }
        }
    }
}