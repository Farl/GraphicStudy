using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GPUParticle : MonoBehaviour {
	public Mesh mesh;
	public Vector3[] vertices;
	public int[] triangles;
	public Vector2[] uv1;
	public Vector2[] uv2;

	public RenderTexture positionBuffer1;
	public RenderTexture positionBuffer2;
	public RenderTexture velocityBuffer1;
	public RenderTexture velocityBuffer2;
	public Material kernelMaterial;
	public Shader kernelShader;

	public Material particleMaterial;

	public int count = 4;

	public MeshRenderer[] debugRenderers;

	private bool isDirty = false;

	public void OnValidate()
	{
		isDirty = true;
	}

	RenderTexture CreateBuffer(string id = "")
	{
		RenderTexture rt = new RenderTexture (count, count, 0);
		rt.hideFlags = HideFlags.DontSave;
		rt.name = id;
		rt.filterMode = FilterMode.Point;
		return rt;
	}

	void ClearBuffer (RenderTexture rt)
	{
		if (rt) {
			if (!Application.isPlaying) {
				Object.DestroyImmediate (rt);
			} else {
				Object.Destroy (rt);
			}
		}
	}

	void Init()
	{
		if (kernelMaterial == null && kernelShader) {
			kernelMaterial = new Material (kernelShader);
			kernelMaterial.name = "Kernel Material";
			kernelMaterial.hideFlags = HideFlags.DontSave;
		}
		if (positionBuffer1 == null) {
			positionBuffer1 = CreateBuffer ("Pos1");
		}
		if (positionBuffer2 == null) {
			positionBuffer2 = CreateBuffer ("Pos2");
		}
		if (velocityBuffer1 == null) {
			velocityBuffer1 = CreateBuffer ("Vel1");
		}
		if (velocityBuffer2 == null) {
			velocityBuffer2 = CreateBuffer ("Vel2");
		}

		if (mesh == null) {
			mesh = new Mesh ();
			vertices = new Vector3[count * count * 4];
			uv1 = new Vector2[count * count * 4];
			uv2 = new Vector2[count * count * 4];
			triangles = new int[count * count * 6];
			mesh.hideFlags = HideFlags.DontSave;
			mesh.name = "GPUParticle";
			for (int i = 0; i < count; i++) {
				for (int j = 0; j < count; j++) {
					vertices [0 + j * 4 + i * count * 4] = new Vector3 (0.1f, -0.1f, 0);
					vertices [1 + j * 4 + i * count * 4] = new Vector3 (0.1f, 0.1f, 0);
					vertices [2 + j * 4 + i * count * 4] = new Vector3 (-0.1f, 0.1f, 0);
					vertices [3 + j * 4 + i * count * 4] = new Vector3 (-0.1f, -0.1f, 0);

					uv1 [0 + j * 4 + i * count * 4] = new Vector2 (0, 0);
					uv1 [1 + j * 4 + i * count * 4] = new Vector2 (0, 1);
					uv1 [2 + j * 4 + i * count * 4] = new Vector2 (1, 1);
					uv1 [3 + j * 4 + i * count * 4] = new Vector2 (1, 0);
					uv2 [0 + j * 4 + i * count * 4] = new Vector2 (i, j);
					uv2 [1 + j * 4 + i * count * 4] = new Vector2 (i, j);
					uv2 [2 + j * 4 + i * count * 4] = new Vector2 (i, j);
					uv2 [3 + j * 4 + i * count * 4] = new Vector2 (i, j);

					triangles [0 + j * 6 + i * count * 6] = 0 + j * 4 + i * count * 4;
					triangles [1 + j * 6 + i * count * 6] = 1 + j * 4 + i * count * 4;
					triangles [2 + j * 6 + i * count * 6] = 2 + j * 4 + i * count * 4;
					triangles [3 + j * 6 + i * count * 6] = 0 + j * 4 + i * count * 4;
					triangles [4 + j * 6 + i * count * 6] = 2 + j * 4 + i * count * 4;
					triangles [5 + j * 6 + i * count * 6] = 3 + j * 4 + i * count * 4;
				}
			}
			mesh.vertices = vertices;
			mesh.triangles = triangles;
			mesh.uv = uv1;
			mesh.uv2 = uv2;

			MeshFilter mf = GetComponent<MeshFilter> ();
			if (mf == null) {
				mf = gameObject.AddComponent<MeshFilter> ();
			}
			mf.sharedMesh = mesh;

			MeshRenderer mr = GetComponent<MeshRenderer> ();
			if (mr == null) {
				mr = gameObject.AddComponent<MeshRenderer> ();
				mr.sharedMaterial = particleMaterial;
			}
		}

		if (debugRenderers != null) {
			if (debugRenderers.Length > 0 && debugRenderers [0]) {
				debugRenderers [0].material.mainTexture = positionBuffer1;
			}
			if (debugRenderers.Length > 1 && debugRenderers [1]) {
				debugRenderers [1].material.mainTexture = velocityBuffer1;
			}
		}
	}

	void Clear()
	{
		if (kernelMaterial) {
			if (!Application.isPlaying) {
				Object.DestroyImmediate (kernelMaterial);
			} else {
				Object.Destroy (kernelMaterial);
			}
		}
		ClearBuffer (positionBuffer1);
		ClearBuffer (positionBuffer2);
		ClearBuffer (velocityBuffer1);
		ClearBuffer (velocityBuffer2);

		if (mesh) {
			if (!Application.isPlaying) {
				Object.DestroyImmediate (mesh);
			} else {
				Object.Destroy (mesh);
			}
		}
	}

	void OnEnable()
	{
		Init ();
	}

	void OnDisable()
	{
		Clear ();
	}

	void UpdateInput()
	{
		RaycastHit hitInfo;
		Ray ray = Camera.main.ScreenPointToRay (Input.mousePosition);
		if (Physics.Raycast (ray, out hitInfo, 100)) {
			if (kernelMaterial) {
				kernelMaterial.SetVector ("_Click", new Vector4 ((float)hitInfo.textureCoord.x, (float)hitInfo.textureCoord.y, 0, Input.GetMouseButton(0)?1:0));
				return;
			}
		}

		if (kernelMaterial) {
			kernelMaterial.SetVector ("_Click", new Vector4 (0, 0, 0, 0));
		}
	}

	void Update()
	{
		UpdateInput ();

		if (kernelMaterial == null) {
			isDirty = true;
		}
		if (isDirty) {
			Clear ();
			isDirty = false;
			Init ();
		}

		// Swap
		var tempPositionBuffer = positionBuffer1;
		positionBuffer1 = positionBuffer2;
		positionBuffer2 = tempPositionBuffer;

		var tempVelocityBuffer = velocityBuffer1;
		velocityBuffer1 = velocityBuffer2;
		velocityBuffer2 = tempVelocityBuffer;

		// Blit
		if (positionBuffer1 && positionBuffer2 && kernelMaterial) {
			kernelMaterial.SetTexture ("_PositionBuffer", positionBuffer1);
			kernelMaterial.SetTexture ("_VelocityBuffer", velocityBuffer1);
			Graphics.Blit (null, positionBuffer2, kernelMaterial, 0);
		}
		if (velocityBuffer1 && velocityBuffer2 && kernelMaterial) {
			kernelMaterial.SetTexture ("_PositionBuffer", positionBuffer2);
			kernelMaterial.SetTexture ("_VelocityBuffer", velocityBuffer1);
			Graphics.Blit (null, velocityBuffer2, kernelMaterial, 1);
		}

		if (particleMaterial) {
			particleMaterial.SetTexture ("_PositionBuffer", positionBuffer2);
		}
	}
}
