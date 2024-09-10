using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PostProcessMultiPass : MonoBehaviour {

	public Material[] materials;
	private void OnValidate()
	{
		if (materials == null) {
			enabled = false;
			return;
		}
		if (materials.Length > 0) {
			foreach (Material m in materials) {
				if (m == null) {
					enabled = false;
					return;
				}
			}
		} else {
			enabled = false;
			return;
		}
		enabled = true;
	}

	void OnRenderImage( RenderTexture src, RenderTexture dest )
	{
		List<RenderTexture> rts = new List<RenderTexture> ();

		RenderTexture currSrc = src;

		for (int i = 0; i < materials.Length; i++) {
			if (i < materials.Length - 1) {
				rts.Add (RenderTexture.GetTemporary (src.descriptor));

				Graphics.Blit (currSrc, rts [i], materials [i]);
				currSrc = rts [i];
			} else {
				Graphics.Blit (currSrc, dest, materials [i]);
			}
		}

		foreach (RenderTexture rt in rts) {
			RenderTexture.ReleaseTemporary (rt);
		}
	}
}
