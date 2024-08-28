using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;
namespace SS
{
    public class ScreenCaptureTool : EditorWindow
    {
        [MenuItem("Tools/SS/Screen Capture")]
        private static void Open()
        {
            var w = EditorWindow.GetWindow<ScreenCaptureTool>();
        }

        private void OnGUI()
        {
            if (GUILayout.Button("ScreenCapture"))
            {
                var fileName = DateTime.Now.ToString("yyyy-MM-dd_hh-mm-ss");
                ScreenCapture.CaptureScreenshot("Capture/" + fileName + ".png");
            }
            if (GUILayout.Button("Open persistent data path"))
            {
                EditorUtility.RevealInFinder(Application.persistentDataPath);
            }
            if (GUILayout.Button("Open data path"))
            {
                EditorUtility.RevealInFinder(Application.dataPath);
            }
        }
    }
}
