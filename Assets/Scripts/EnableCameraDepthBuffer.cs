using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class EnableCameraDepthBuffer : MonoBehaviour {

	// Use this for initialization
	void Start () {
Camera cam = GetComponent<Camera>();
		if (cam)
{
cam.depthTextureMode = DepthTextureMode.DepthNormals;
}
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
