using System;
using System.Collections;
using System.Collections.Generic;
using NUnit.Framework;
using UnityEngine;

namespace Tools.DataToModel
{
    public class WallMeshData
    {
        public bool IsReversalColockWise = false; //是否反转 -顺时针和逆时针的判断、
        public List<Vector3> VerticesList = new List<Vector3>(); //顶点信息

        public WallMeshData(bool isReversalColockWise, List<Vector3> verticesList)
        {
            this.IsReversalColockWise = isReversalColockWise;
            this.VerticesList = verticesList;
        }
    }
    
    public class DataToModel : MonoBehaviour
    {
        [SerializeField] private TextAsset _textAsset;
        [SerializeField] private Material _material;

        private void Awake()
        { 
            CreateRoomWallMesh(_material);
            DontDestroyOnLoad(this);
        }
        
        void OnDrawGizmosSelected()
        {
            Gizmos.color = Color.cyan;
            var wallMeshData = GetWallMeshData();
            var mesh = GetWallMeshInfo(wallMeshData);
            mesh.RecalculateNormals();
            Gizmos.DrawWireMesh(mesh,Vector3.zero,Quaternion.identity);
        }
        
        private List<WallMeshData> GetWallMeshData()
        {
            List<WallMeshData> wallMeshDataList = new List<WallMeshData>();
            var room = RoomData.GetRoomData(_textAsset);
            if (room != null)
            {
                //围墙
                List<Vector3> wallPoint3Ds = new List<Vector3>();
                for (int i = 0; i < room.room.x.Count; i++)
                {
                    var point = new Vector3(room.room.x[i],room.room.y[i],room.room.z[i]);
                    wallPoint3Ds.Add(point);
                }
                wallMeshDataList.Add(new WallMeshData(false,wallPoint3Ds));
                
                //柱子
                List<List<Vector3>> columnPoint3Ds = new List<List<Vector3>>();
                for (int i = 0; i < room.column.Count; i++)
                {
                    var tempPointList = new List<Vector3>();
                    for (int j = 0; j < room.column[i].x.Count; j++)
                    {
                        tempPointList.Add(new Vector3(room.column[i].x[j],room.column[i].y[j],room.column[i].z[j]));
                    }
                    wallMeshDataList.Add(new WallMeshData(true,tempPointList));
                }
            }
            return wallMeshDataList;
        }

        #region 绘制地图
        private void CreateRoomWallMesh( Material material = null,float height = 2.0f)
        {
            var wallMeshData = GetWallMeshData();
            GameObject meshObj = new GameObject("AirWall");
            meshObj.transform.position = Vector3.zero;
            meshObj.transform.SetParent(transform);
            var mesh = GetWallMeshInfo(wallMeshData,height);
            mesh.RecalculateNormals();
            meshObj.AddComponent<MeshFilter>().mesh = mesh;
            meshObj.AddComponent<MeshRenderer>().material = material;
            DontDestroyOnLoad(meshObj);
        }
        
         private Mesh GetWallMeshInfo(List<WallMeshData> wallMeshDatas, float height = 2.0f)
        {
            //组装空气墙mesh数据
            var verticesList = new List<Vector3>();
            var uvList = new List<Vector2>();
            var trianglesList = new List<int>();
            
            var uvDis = 0.0f;
            int pointIndex = 0;
            foreach (var wallMeshData in wallMeshDatas)
            {
                //围栏数据是顺时针还是逆时针
                bool isClockWise = false;
                if (wallMeshData.VerticesList.Count >= 3)
                {
                    var dirOne = wallMeshData.VerticesList[1] - wallMeshData.VerticesList[0];
                    var dirTwo = wallMeshData.VerticesList[2] - wallMeshData.VerticesList[0];
                    isClockWise = Vector3.Cross(dirOne, dirTwo).z < 0;
                }
                isClockWise = wallMeshData.IsReversalColockWise ? !isClockWise : isClockWise;

                for (int i = 0; i < wallMeshData.VerticesList.Count; i++)
                {
                    //顶点数据
                    var pointOne = wallMeshData.VerticesList[i];
                    var pointTwo = wallMeshData.VerticesList[(i + 1) % wallMeshData.VerticesList.Count];
                    var pointThree = pointOne + Vector3.up * height;
                    var pointFour = pointTwo + Vector3.up * height;
                    verticesList.AddRange(new[] { pointOne, pointTwo, pointThree, pointFour });
                    //uv数据
                    uvDis += Vector3.Distance(pointOne, pointTwo);
                    uvList.AddRange(new[]
                    {
                        new Vector2(0, 0),
                        new Vector2(uvDis, 0),
                        new Vector2(0, pointThree.z),
                        new Vector2(uvDis, pointFour.z)
                    });
                    //三角面
                    trianglesList.AddRange(new[]
                    {
                        pointIndex,
                        pointIndex + (isClockWise ? 1 : 2),
                        pointIndex + (isClockWise ? 2 : 1),
                        pointIndex + 1,
                        pointIndex + (isClockWise ? 3 : 2),
                        pointIndex + (isClockWise ? 2 : 3)
                    });
                    pointIndex += 4;
                }
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