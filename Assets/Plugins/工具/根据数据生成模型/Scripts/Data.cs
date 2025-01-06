using System;
using System.Collections.Generic;
using UnityEngine;

namespace Tools.DataToModel
{
    public class RoomData
    {
        public static Room GetRoomData(TextAsset textAsset = null)
        {
#if UNITY_EDITOR
            if (textAsset == null)
            {
                Debug.LogError("[Room Data]: Text Asset is Null");
            }
            return Data.GetTextAssetContent<Room>(textAsset);
#else
 #endif
        }
    }
    
    public class Data
    {
        public static T GetTextAssetContent<T>(TextAsset asset)
        {
            string content ="";
            if (asset != null)
            {
                content = asset.text;
            }
            return JsonUtility.FromJson<T>(content);
        }
    }

    [Serializable]
    public class Point3Ds
    {
        public List<float> x = new List<float>();
        public List<float> y = new List<float>();
        public List<float> z = new List<float>();
    }

    [Serializable]
    public class Room
    {
        public Point3Ds room = new Point3Ds();
        public List<Point3Ds> column = new List<Point3Ds>();
    }
}

