using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Tools.DataToModel
{
    public class DataToModel : MonoBehaviour
    {
        [SerializeField] private TextAsset _textAsset;
        [SerializeField] private Material _material;

        private void Awake()
        {
          CreateRoom();
        }

        public void CreateRoom()
        {
            var room = Data.GetTextAssetContent<Room>(_textAsset);
            //顶点数组
            Vector3[] _vertices =
            {
                // front
                new Vector3(-5.0f, 10.0f, -5.0f),
                new Vector3(-5.0f, 0.0f, -5.0f),
                new Vector3(5.0f, 0.0f, -5.0f),
                new Vector3(5.0f, 10.0f, -5.0f),


                // left
                new Vector3(-5.0f, 10.0f, -5.0f),
                new Vector3(-5.0f, 0.0f, -5.0f),
                new Vector3(-5.0f, 0.0f, 5.0f),//
                new Vector3(-5.0f, 10.0f, 5.0f),

                // back
                new Vector3(-5.0f, 10.0f, 5.0f),
                new Vector3(-5.0f, 0.0f, 5.0f),
                new Vector3(5.0f, 0.0f, 5.0f),
                new Vector3(5.0f, 10.0f, 5.0f),


                // right
                new Vector3(5.0f, 10.0f, 5.0f),
                new Vector3(5.0f, 0.0f, 5.0f),
                new Vector3(5.0f, 0.0f, -5.0f),
                new Vector3(5.0f, 10.0f, -5.0f),


                // Top
                new Vector3(-5.0f, 10.0f, 5.0f),
                new Vector3(5.0f, 10.0f, 5.0f),
                new Vector3(5.0f, 10.0f, -5.0f),
                new Vector3(-5.0f, 10.0f, -5.0f),

                // Bottom
                new Vector3(-5.0f, 0.0f, 5.0f),
                new Vector3(5.0f, 0.0f, 5.0f),
                new Vector3(5.0f, 0.0f, -5.0f),
                new Vector3(-5.0f, 0.0f, -5.0f),

            };
            
            //索引数组
            int[] _triangles =
            {
                //front
                2,1,0,
                0,3,2,
                //left
                4,5,6,
                4,6,7,
                //back
                9,11,8,
                9,10,11,
                //right
                12,13,14,
                12,14,15,
                ////up
                //16,17,18,
                //16,18,19,
                ////buttom
                //21,23,22,
                //21,20,23,

                //不可跳跃设置索引值（否则会提示一些索引超出边界顶点   15直接20不可，要连续15-16）
                17,19,18,
                17,16,19,
            };
            
            //UV数组
            Vector2[] uvs =
            {
                // Front
                new Vector2(1.0f, 0.0f),
                new Vector2(1.0f, 1.0f),
                new Vector2(1.0f, 0.0f),
                new Vector2(0.0f, 0.0f),


                // Left
                new Vector2(1.0f, 1.0f),
                new Vector2(0.0f, 1.0f),
                new Vector2(0.0f, 0.0f),
                new Vector2(1.0f, 0.0f),


                // Back
                new Vector2(1.0f, 0.0f),
                new Vector2(1.0f, 1.0f),
                new Vector2(1.0f, 0.0f),
                new Vector2(0.0f, 0.0f),


                // Right
                new Vector2(1.0f, 1.0f),
                new Vector2(0.0f, 1.0f),
                new Vector2(0.0f, 0.0f),
                new Vector2(1.0f, 0.0f),

                //// Top
                //new Vector2(0.0f, 0.0f),
                //new Vector2(1.0f, 0.0f),
                //new Vector2(1.0f, 1.0f),
                //new Vector2(0.0f, 1.0f),


                // Bottom
                new Vector2(0.0f, 0.0f),
                new Vector2(1.0f, 0.0f),
                new Vector2(1.0f, 1.0f),
                new Vector2(0.0f, 1.0f),

            };
            CreateMeshWithData("room",_vertices,_triangles,uvs,_material);
        }

        #region Private Method

        private void CreateMeshWithData(string name,Vector3[] vertices,int[] triangles,Vector2[] uv,Material material = null)
        {
            GameObject meshObj = new GameObject(name);
            meshObj.transform.position = Vector3.zero;
            meshObj.transform.SetParent(null);
            Mesh mesh = new Mesh();
            mesh.vertices = vertices;
            mesh.triangles = triangles;
            mesh.uv = uv;
            mesh.RecalculateNormals();
            meshObj.AddComponent<MeshFilter>().mesh = mesh;
            meshObj.AddComponent<MeshRenderer>().material = material;
        }

        #endregion
        
    }

}