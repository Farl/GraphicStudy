using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using UnityEditor;

[CustomEditor(typeof(CameraCapture))]
public class CameraCaptureEditor : Editor
{
	public override void OnInspectorGUI ()
	{
		if (GUILayout.Button ("Capture")) {
			CameraCapture cc = target as CameraCapture;
			if (cc) {
				cc.Capture ();
			}
		}
		base.OnInspectorGUI ();
	}
}