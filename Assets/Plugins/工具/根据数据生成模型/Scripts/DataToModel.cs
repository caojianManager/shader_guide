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
        
        void OnDrawGizmosSelected()
        {
            var roomData = GetRoomData();
            var airMeshInfo = GetAirWallMeshInfo(roomData);
            airMeshInfo.RecalculateNormals();
            Gizmos.DrawMesh(airMeshInfo,Vector3.zero,Quaternion.identity);
        }

        #region CreateRoomMesh
        
        public void CreateRoom()
        {
            var roomData = GetRoomData();
            CreateAirWallMesh(roomData, _material);
        }
        
        private List<Vector3> GetRoomData()
        {
            //组装围栏数据
            var room = Data.GetTextAssetContent<Room>(_textAsset);
            List<Vector3> point3Ds = new List<Vector3>();
            for (int i = 0; i < room.room.x.Count; i++)
            {
                var point = new Vector3(room.room.x[i],room.room.y[i],room.room.z[i]);
                point3Ds.Add(point);
            }
            return point3Ds;
        }

        private void CreateAirWallMesh(List<Vector3> vertices, Material material = null,float height = 2.0f)
        {
            GameObject meshObj = new GameObject("AirWall");
            meshObj.transform.position = Vector3.zero;
            meshObj.transform.SetParent(null);
            var mesh = GetAirWallMeshInfo(vertices,height);
            mesh.RecalculateNormals();
            meshObj.AddComponent<MeshFilter>().mesh = mesh;
            meshObj.AddComponent<MeshRenderer>().material = material;
            DontDestroyOnLoad(meshObj);
            return;
        } 
        
        private Mesh GetAirWallMeshInfo(List<Vector3> vertices, float height = 2.0f)
        {
            //围栏数据是顺时针还是逆时针
            bool isClockWise = false;
            if (vertices.Count >= 3)
            {
                var dirOne = vertices[1] - vertices[0];
                var dirTwo = vertices[2] - vertices[0];
                isClockWise = Vector3.Cross(dirOne, dirTwo).z < 0;
            }  
            //组装空气墙mesh数据
            var verticesList = new List<Vector3>();
            var uvList = new List<Vector2>();
            var trianglesList = new List<int>();
            var uvDis = 0.0f;
            for (int i = 0; i < vertices.Count; i++)
            {
                //顶点数据
                var pointOne = vertices[i];
                var pointTwo = vertices[(i + 1) % vertices.Count];
                var pointThree = pointOne + Vector3.up * height;
                var pointFour = pointTwo + Vector3.up * height;
                verticesList.AddRange(new []{pointOne,pointTwo,pointThree,pointFour});
                
                //uv数据
                uvDis += Vector3.Distance(pointOne, pointTwo);
                uvList.AddRange(new []
                {
                    new Vector2(0,0),
                    new Vector2(uvDis,0),
                    new Vector2(0,pointThree.z),
                    new Vector2(uvDis,pointFour.z)
                });
                
                //三角面
                var pointIndex = i * 4;
                trianglesList.AddRange(new []
                {
                    pointIndex,
                    pointIndex + (isClockWise ? 1 :2),
                    pointIndex + (isClockWise ? 2 :1),
                    pointIndex + 1,
                    pointIndex + (isClockWise ? 3:2),
                    pointIndex + (isClockWise ? 2:3)
                });
            }

            Mesh meshInfo = new Mesh();
            meshInfo.vertices = verticesList.ToArray();
            meshInfo.uv = uvList.ToArray();
            meshInfo.triangles = trianglesList.ToArray();
            return meshInfo;
        }

        #endregion
        
    }

}