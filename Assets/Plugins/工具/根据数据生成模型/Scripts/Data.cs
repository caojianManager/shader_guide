using System;
using System.Collections.Generic;
using UnityEngine;

namespace Tools.DataToModel
{
    public class Data
    {
        public static T GetTextAssetContent<T>(TextAsset asset)
        {
            string content = asset.text;
            Debug.LogError(content);
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
    }
}

