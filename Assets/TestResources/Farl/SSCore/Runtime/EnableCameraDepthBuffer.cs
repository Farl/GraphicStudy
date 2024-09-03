using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SS
{
	[Obsolete("Old trick")]
	[ExecuteAlways]
	public class EnableCameraDepthBuffer : MonoBehaviour
	{
		void Start()
		{
			Camera cam = GetComponent<Camera>();
			if (cam)
			{
				cam.depthTextureMode = DepthTextureMode.DepthNormals;
			}
		}
	}

}