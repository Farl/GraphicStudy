using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RTClickBind : MonoBehaviour {
	public List<Transform> transforms = new List<Transform>();
	public float distance = 0.05f;
	public RTClick rtClick;

	// Update is called once per frame
	void Update () {
		if (transforms != null) {
			foreach (Transform t in transforms) {
				RaycastHit hitInfo;
				if (Physics.Raycast (new Ray (t.position + Vector3.up * distance * 0.5f, Vector3.down), out hitInfo, distance)) {
					if (rtClick)
						rtClick.SetClickTexCoord (hitInfo.textureCoord);
				}
			}
		}
	}
}
