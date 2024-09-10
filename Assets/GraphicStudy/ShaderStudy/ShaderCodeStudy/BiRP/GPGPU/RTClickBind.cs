using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SS
{
	public class RTClickBind : MonoBehaviour
	{
		[SerializeField]
		private List<Transform> transforms = new List<Transform>();
		[SerializeField]
		private float distance = 0.05f;
		[SerializeField]
		private RTClick rtClick;
		[SerializeField]
		private float clickRadius = 0.01f;

		// Update is called once per frame
		void Update()
		{
			if (transforms != null)
			{
				foreach (Transform t in transforms)
				{
					RaycastHit hitInfo;
					if (Physics.Raycast(new Ray(t.position + Vector3.up * distance * 0.5f, Vector3.down), out hitInfo, distance))
					{
						if (rtClick)
							rtClick.SetClickTexCoord(hitInfo.textureCoord, clickRadius);
					}
				}
			}
		}
	}
}