using System;
using UnityEngine;

namespace SS
{
	[Obsolete("For built-in rendering pipeline")]
	[ExecuteAlways]
	public class EnableCameraDepthBuffer : MonoBehaviour
	{
		[SerializeField] public DepthTextureMode mode = DepthTextureMode.Depth;
		void Start()
		{
			Camera cam = GetComponent<Camera>();
			if (cam)
			{
				cam.depthTextureMode = mode;
			}
		}
	}

}