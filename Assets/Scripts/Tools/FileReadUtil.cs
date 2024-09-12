using System;
using System.IO;
using UnityEngine;
using UnityEngine.Android;
using UnityEngine.Events;

namespace Tools
{
    public class FileReadUtil
    {
        public static bool RequestPermission(string permission,UnityAction<int> endCall)
        {
            if (!Permission.HasUserAuthorizedPermission(permission))
            {
                PermissionCallbacks callBack = new PermissionCallbacks();
                callBack.PermissionGranted += (content) => {
                    endCall?.Invoke(1);
                };
                callBack.PermissionDenied += (content) => {
                    endCall?.Invoke(2);
                };
                callBack.PermissionDeniedAndDontAskAgain += (content) => {
               
                    endCall?.Invoke(3);
                };
                Permission.RequestUserPermission(permission, callBack);
                return true;
            }
            return false;
        }

        public static string ReadFileText(string direct = "pre_resources/",string key = "ESN_")
        {
            string rootPath = Path.GetFullPath(Application.persistentDataPath + "/../../../../");
            string resourcesDirect = Path.Combine(rootPath, direct);
            Debug.LogError("cj1" + resourcesDirect);
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
                        content = streamReader.ReadLine();
                        streamReader.Close();
                        break;
                    }
                }
            }
            return content;
        }

        //在指定目录获取序列码
        public static void GetSNCode(UnityAction<bool,string> callBack)
        {
            if (!RequestPermission(Permission.ExternalStorageRead, (status) =>
                {
                    if (status == 1)
                    {
                        string snCode = ReadFileText();
                        callBack(true, snCode);
                    }
                    else
                    {
                        callBack(false, "");
                    }
                }))
            {
                string snCode = ReadFileText();
                callBack(true, snCode);
            }
        }
        
    }
}