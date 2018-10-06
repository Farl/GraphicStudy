using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
#if (UNITY_EDITOR)
using UnityEditor;
#endif

public class CameraCapture : MonoBehaviour {
	
	public void Capture(int resWidth = 1920, int resHeight = 1080)
	{
		Camera camera = GetComponent<Camera> ();

		RenderTexture rt = new RenderTexture(resWidth, resHeight, 32);
		camera.targetTexture = rt;
		Texture2D screenShot = new Texture2D(resWidth, resHeight, TextureFormat.RGBA32, true, true);
		camera.Render();
		RenderTexture.active = rt;
		screenShot.ReadPixels(new Rect(0, 0, resWidth, resHeight), 0, 0);
		camera.targetTexture = null;
		RenderTexture.active = null; // JC: added to avoid errors
		if (Application.isPlaying) {
			Destroy (rt);
		} else {
			DestroyImmediate (rt);
		}
		byte[] bytes = screenShot.EncodeToPNG();
		string filename = ScreenShotName(resWidth, resHeight);

		Directory.CreateDirectory (Directory.GetParent (filename).ToString ());

		System.IO.File.WriteAllBytes(filename, bytes);
		Debug.Log(string.Format("Took screenshot to: {0}", filename));

		#if UNITY_EDITOR
		AssetDatabase.Refresh();
		#endif
	}

	public static string ScreenShotName(int width, int height) {
		return string.Format("{0}/Screenshots/screen_{1}x{2}_{3}.png", 
			Application.dataPath, 
			width, height, 
			System.DateTime.Now.ToString("yyyy-MM-dd_HH-mm-ss"));
	}
}
