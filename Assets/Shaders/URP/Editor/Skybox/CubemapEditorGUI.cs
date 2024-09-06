using UnityEditor.Rendering;
using UnityEngine.Rendering;
using UnityEditor;
using UnityEngine;

namespace URPShaderEditor.Skybox
{
    public class CubemapEditorGUI : ShaderGUI
    {
        
        private MaterialEditor matEditor;
        private Material mat;
        
        bool showCubeMapOptions = false; 
        bool showRotationOptions = false;
        bool showFogOptions = false;
        
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            this.matEditor = materialEditor;
            mat = matEditor.target as Material;

            MaterialProperty _Cubemap = FindProperty("_Cubemap", properties);
            MaterialProperty _CubemapExposure = FindProperty("_CubemapExposure", properties);
            MaterialProperty _CubemapTintColor = FindProperty("_CubemapTintColor", properties);
            MaterialProperty _CubemapPosition = FindProperty("_CubemapPosition", properties);
            //Rotation
            MaterialProperty _RotationEnable = FindProperty("_RotationEnable", properties);
            MaterialProperty _Rotation = FindProperty("_Rotation", properties);
            MaterialProperty _RotationSpeed = FindProperty("_RotationSpeed", properties);
            //FOG
            MaterialProperty _FogEnable = FindProperty("_FogEnable", properties);
            MaterialProperty _FogIntensity = FindProperty("_FogIntensity", properties);
            MaterialProperty _FogHeight = FindProperty("_FogHeight", properties);
            MaterialProperty _FogSmoothness = FindProperty("_FogSmoothness", properties);
            MaterialProperty _FogFill = FindProperty("_FogFill", properties);
            MaterialProperty _FogPosition = FindProperty("_FogPosition", properties);
            
            DrawCubemapOptions();
            DrawRotationOptions();
            DrawFogOptions();
            
            void DrawCubemapOptions()
            {
                showCubeMapOptions = EditorGUILayout.BeginFoldoutHeaderGroup(showCubeMapOptions, "Cube Map");
                if (showCubeMapOptions)
                {
                    //Cubemap
                    matEditor.TexturePropertySingleLine(new GUIContent("Cube Map"), _Cubemap);
                    matEditor.ShaderProperty(_CubemapExposure, new GUIContent("Exposure"));
                    matEditor.ShaderProperty(_CubemapTintColor, new GUIContent("Tint Color"));
                    matEditor.ShaderProperty(_CubemapPosition, new GUIContent("Position"));
                }
                EditorGUILayout.EndFoldoutHeaderGroup();
            }
            
            void DrawRotationOptions()
            {
                showRotationOptions = EditorGUILayout.BeginFoldoutHeaderGroup(showRotationOptions, "Rotation");
                if (showRotationOptions)
                {
                    //Rotation
                    matEditor.ShaderProperty(_RotationEnable, new GUIContent("Enable"));
                    matEditor.ShaderProperty(_Rotation, new GUIContent("Rotation"));
                    matEditor.ShaderProperty(_RotationSpeed, new GUIContent("Speed"));
                }
                EditorGUILayout.EndFoldoutHeaderGroup();
            }

            void DrawFogOptions()
            {
                showFogOptions = EditorGUILayout.BeginFoldoutHeaderGroup(showFogOptions, "Fog");
                if (showFogOptions)
                {
                    //Fog
                    matEditor.ShaderProperty(_FogEnable,new GUIContent("Enable"));
                    matEditor.ShaderProperty(_FogIntensity, new GUIContent("Intensity"));
                    matEditor.ShaderProperty(_FogHeight, new GUIContent("Height"));
                    matEditor.ShaderProperty(_FogSmoothness, new GUIContent("Smoothness"));
                    matEditor.ShaderProperty(_FogFill, new GUIContent("Fill"));
                    matEditor.ShaderProperty(_FogPosition, new GUIContent("Position"));
                }
                EditorGUILayout.EndFoldoutHeaderGroup();
            }
        }
    }
}