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

	public List<Vector3> vertices = new List<Vector3> ();
	public List<int> indices = new List<int> ();

	// Use this for initialization
	void Start () {
		CreateMesh ();
	}

	void OnValidate()
	{
		CreateMesh ();
	}

	void CreateMesh()
	{
		if (mesh == null) {
			mesh = new Mesh ();
		}
		if (mesh) {
			vertices.Clear ();
			indices.Clear ();
			for (int j = 0; j < segment; j++) {

				for (int i = 0; i < slice; i++) {
					Vector3 pos0 = new Vector3 (Mathf.Lerp(topRadius, bottomRadius, j * height / segment), (j+0) * height / segment, 0);
					pos0 = Quaternion.Euler (new Vector3 (0, (i+0) * 360.0f / slice, 0)) * pos0;
					vertices.Add (pos0);
					indices.Add (indices.Count);
					Vector3 pos1 = new Vector3 (Mathf.Lerp(topRadius, bottomRadius, j * height / segment), (j+0) * height / segment, 0);
					pos1 = Quaternion.Euler (new Vector3 (0, ((i+1) % slice) * 360.0f / slice, 0)) * pos1;
					vertices.Add (pos1);
					indices.Add (indices.Count);
					Vector3 pos2 = new Vector3 (Mathf.Lerp(topRadius, bottomRadius, ((j+1) % segment) * height / segment), ((j+1) % segment) * height / segment, 0);
					pos2 = Quaternion.Euler (new Vector3 (0, ((i+1) % slice) * 360.0f / slice, 0)) * pos2;
					vertices.Add (pos2);
					indices.Add (indices.Count);
					Vector3 pos3 = new Vector3 (Mathf.Lerp(topRadius, bottomRadius, ((j+1) % segment) * height / segment), ((j+1) % segment) * height / segment, 0);
					pos3 = Quaternion.Euler (new Vector3 (0, (i+0) * 360.0f / slice, 0)) * pos3;
					vertices.Add (pos3);
					indices.Add (indices.Count);
				}

			}
			mesh.SetVertices (vertices);
			mesh.SetIndices (indices.ToArray(), MeshTopology.Quads, submesh:0);

			mesh.RecalculateNormals ();
			mesh.UploadMeshData (false);

			meshFilter = GetComponent<MeshFilter> ();
			if (meshFilter && meshFilter.sharedMesh != mesh) {
				meshFilter.sharedMesh = mesh;
			}
		}
	}
}
