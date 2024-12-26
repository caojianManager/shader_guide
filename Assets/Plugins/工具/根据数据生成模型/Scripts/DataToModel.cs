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
          
        }

        public void CreateRoom()
        {
            var room = Data.GetTextAssetContent<Room>(_textAsset);
            List<Vector3> point3Ds = new List<Vector3>();
            for (int i = 0; i < room.room.x.Count; i++)
            {
                var point = new Vector3(room.room.x[i],room.room.y[i],room.room.z[i]);
                point3Ds.Add(point);
            }
        }

        void OnDrawGizmosSelected()
        {
            Gizmos.color = Color.red;
            var room = Data.GetTextAssetContent<Room>(_textAsset);
            for (int i = 0; i < room.room.x.Count; i++)
            {
                var startPoint = new Vector3(room.room.x[i],room.room.y[i],room.room.z[i]);
                var endPoint = new Vector3(room.room.x[0],room.room.y[0],room.room.z[0]);
                if (i+1 < room.room.x.Count)
                {
                    endPoint = new Vector3(room.room.x[i+1],room.room.y[i+1],room.room.z[i+1]);
                }
                Gizmos.DrawLine(startPoint,endPoint);
            }
        }

        #region Private Method

        private void CreateMeshWithData(string name,Vector3[] vertices,Material material = null)
        {
            GameObject meshObj = new GameObject(name);
            meshObj.transform.position = Vector3.zero;
            meshObj.transform.SetParent(null);
            Mesh mesh = new Mesh();
            mesh.vertices = vertices;
            
            meshObj.AddComponent<MeshFilter>().mesh = mesh;
            meshObj.AddComponent<MeshRenderer>().material = material;
        }

        #endregion
        
    }

}