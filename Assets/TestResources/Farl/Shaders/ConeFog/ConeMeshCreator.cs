using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ConeMeshCreator : MonoBehaviour {

	public Mesh mesh;
	private MeshFilter meshFilter;

	public float topRadius = 1;
	public float height = 1;
	public float bottomRadius = 1;
	public int slice = 12;
	public int segment = 4;

	public Gradient gradient;

	public List<Vector3> vertices = new List<Vector3> ();
	public List<int> indicesB = new List<int> ();
	public List<int> indicesF = new List<int> ();
	public List<Vector2> uvs = new List<Vector2>();
	public List<Color> colors = new List<Color> ();

	// Use this for initialization
	void OnEnable () {
		CreateMesh ();
	}

	void OnValidate()
	{
		segment = Mathf.Max (1, segment);
		slice = Mathf.Max (3, slice);
		CreateMesh ();
	}

	void CreateMesh()
	{
		if (mesh) {
			Object.DestroyImmediate (mesh);
		}
		if (mesh == null) {
			mesh = new Mesh ();
			mesh.name = name;
			mesh.hideFlags = HideFlags.DontSave;
		}

		if (mesh) {
			vertices.Clear ();
			indicesB.Clear ();
			indicesF.Clear ();
			uvs.Clear ();
			colors.Clear ();

			int verticesCount = slice * (segment + 1);

			for (int j = 0; j <= segment; j++) {

				for (int i = 0; i < slice; i++) {
					float h = (float)j / segment;

					Vector3 pos0 = new Vector3 (Mathf.Lerp(topRadius, bottomRadius, h), -height * h, 0);
					pos0 = Quaternion.Euler (new Vector3 (0, i * 360.0f / slice, 0)) * pos0;
					vertices.Add (pos0); // Front
					uvs.Add (new Vector2((float)i / (slice - 1), h));
					if (gradient != null)
						colors.Add (gradient.Evaluate (h));

					if (j < segment) {
						// Back Face
						indicesB.Add (((i + 0) % slice) + (j + 0) * slice);
						indicesB.Add (((i + 1) % slice) + (j + 0) * slice);
						indicesB.Add (((i + 1) % slice) + (j + 1) * slice);

						indicesB.Add (((i + 0) % slice) + (j + 0) * slice);
						indicesB.Add (((i + 1) % slice) + (j + 1) * slice);
						indicesB.Add (((i + 0) % slice) + (j + 1) * slice);

						// Front Face
						indicesF.Add (verticesCount + ((i + 0) % slice) + (j + 0) * slice);
						indicesF.Add (verticesCount + ((i + 1) % slice) + (j + 1) * slice);
						indicesF.Add (verticesCount + ((i + 1) % slice) + (j + 0) * slice);

						indicesF.Add (verticesCount + ((i + 0) % slice) + (j + 0) * slice);
						indicesF.Add (verticesCount + ((i + 0) % slice) + (j + 1) * slice);
						indicesF.Add (verticesCount + ((i + 1) % slice) + (j + 1) * slice);
					}
				}
			}

			vertices.AddRange (vertices);
			uvs.AddRange (uvs);
			colors.AddRange (colors);

			mesh.subMeshCount = 2;
			mesh.vertices = vertices.ToArray ();
			mesh.SetTriangles (indicesB.ToArray (), 0);
			mesh.SetTriangles (indicesF.ToArray (), 1);
			mesh.uv = uvs.ToArray ();
			if (gradient != null)
				mesh.colors = colors.ToArray ();

			mesh.RecalculateNormals ();

			meshFilter = GetComponent<MeshFilter> ();
			if (!meshFilter)
				meshFilter = gameObject.AddComponent<MeshFilter> ();

			if (!GetComponent<MeshRenderer> ())
				gameObject.AddComponent<MeshRenderer> ();
			
			if (meshFilter && meshFilter.sharedMesh != mesh) {
				meshFilter.sharedMesh = mesh;
			}
		}
	}
}
