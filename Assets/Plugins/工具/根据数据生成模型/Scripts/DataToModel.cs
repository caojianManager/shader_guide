using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Tools.DataToModel
{
    public class DataToModel : MonoBehaviour
    {
        [SerializeField] private TextAsset _textAsset;

        private void Awake()
        {
          var room = Data.GetTextAssetContent<Room>(_textAsset);
          Debug.LogError("cj" + room.room.x.Count);
        }

        // Update is called once per frame
        void Update()
        {

        }
        
    }

}