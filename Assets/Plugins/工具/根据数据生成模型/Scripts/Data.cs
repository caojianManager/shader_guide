using System;
using System.Collections.Generic;
using System.IO;
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
            return JsonUtility.FromJson<Room>(ReadRoomData());
#endif
        }
        
        private static string ReadRoomData(string direct = "data/calf/",string key = "Boundary")
        {
            string rootPath = Path.GetFullPath(Application.persistentDataPath + "/../../../../../../../");
            string resourcesDirect = Path.Combine(rootPath, direct);
            string content = "";
            if (Directory.Exists(resourcesDirect))
            {
                DirectoryInfo directory = new DirectoryInfo(resourcesDirect);
                foreach (FileInfo file in directory.GetFiles())
                {
                    if (file.Name.Contains(key))
                    {
                        FileStream fileStream = new FileStream(file.FullName, FileMode.Open, FileAccess.Read);
                        StreamReader streamReader = new StreamReader(fileStream);
                        content = streamReader.ReadToEnd();
                        streamReader.Close();
                        break;
                    }
                }
            }
            return content;
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

