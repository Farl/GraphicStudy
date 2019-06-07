using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RTClick : MonoBehaviour {

	public Shader kernel;
	public Material material;
	public Material material2;
	public Material kernelMaterial;

	public float waveDensity = 0.01f;
	public float waveDampingForce = 50.0f;
	[Range(0.0f, 1.0f)]
	public float waveSpeed = 0.99f;
	[Range(0.0f, 1.0f)]
	public float waveDamping = 0.99f;
	private RenderTexture positionTexture1;
	private RenderTexture positionTexture2;
	private RenderTexture velocityTexture1;
	private RenderTexture velocityTexture2;

	RenderTexture CreateTexture()
	{
		RenderTexture rt = new RenderTexture (256, 256, 0, RenderTextureFormat.ARGBFloat);
		rt.hideFlags = HideFlags.DontSave;
		rt.filterMode = FilterMode.Bilinear;
		rt.wrapMode = TextureWrapMode.Repeat;
		return rt;
	}

	void Init()
	{

		if (positionTexture1 == null) {
			positionTexture1 = CreateTexture();
			positionTexture2 = CreateTexture();
		}

		if (velocityTexture1 == null) {
			velocityTexture1 = CreateTexture();
			velocityTexture2 = CreateTexture();
		}

		if (material && positionTexture1) {
			material.mainTexture = positionTexture1;
		}
		if (material2 && velocityTexture1) {
			material2.mainTexture = velocityTexture1;
		}

		if (kernelMaterial == null && kernel != null) {
			kernelMaterial = new Material (kernel);
			kernelMaterial.SetTexture ("_PositionBuffer", positionTexture1);
			kernelMaterial.SetTexture ("_VelocityBuffer", velocityTexture1);
		}
	}
	void OnEnable () {
		Init ();
	}

	void OnDisable()
	{
		Object.DestroyImmediate (kernelMaterial);
		Object.DestroyImmediate (positionTexture1);
		Object.DestroyImmediate (velocityTexture1);
		Object.DestroyImmediate (positionTexture2);
		Object.DestroyImmediate (velocityTexture2);
	}

	void UpdateInput()
	{
		bool click = false;
		if (kernelMaterial) {
			if (Input.GetMouseButton (0)) {
				click = true;
			}
		}

		if (kernelMaterial)
			kernelMaterial.SetVector ("_Click", new Vector4 ((float)Input.mousePosition.x / Screen.width, (float)Input.mousePosition.y / Screen.height, Input.mousePosition.z,
			click? 1: 0));
	}
	
	// Update is called once per frame
	void Update () {
		Init ();

		UpdateInput ();

		if (kernelMaterial) {
			// Swap buffer
			var tempVelocityTex = velocityTexture1;
			var tempPositionTex = positionTexture1;

			velocityTexture1 = velocityTexture2;
			velocityTexture2 = tempVelocityTex;

			positionTexture1 = positionTexture2;
			positionTexture2 = tempPositionTex;

			if (positionTexture1 && positionTexture2 && velocityTexture1 && velocityTexture2) {
				kernelMaterial.SetVector ("_WaveParam", new Vector4 (waveDensity, waveDampingForce, waveSpeed, waveDamping));

				kernelMaterial.SetTexture ("_PositionBuffer", positionTexture1);
				kernelMaterial.SetTexture ("_VelocityBuffer", velocityTexture1);
				Graphics.Blit (null, positionTexture2, kernelMaterial, 0);
				kernelMaterial.SetTexture ("_PositionBuffer", positionTexture2);
				kernelMaterial.SetTexture ("_VelocityBuffer", velocityTexture1);
				Graphics.Blit (null, velocityTexture2, kernelMaterial, 1);
			}
		}
	}
}
