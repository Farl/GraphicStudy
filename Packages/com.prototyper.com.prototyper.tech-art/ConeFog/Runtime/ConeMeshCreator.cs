using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SS
{
	[ExecuteInEditMode]
	public class ConeMeshCreator : MonoBehaviour
	{
		[SerializeField] public float topRadius = 1;
		[SerializeField] public float height = 1;
		[SerializeField] public float bottomRadius = 1;
		[SerializeField] public int slice = 12;
		[SerializeField] public int segment = 4;
		[SerializeField] public Gradient gradient;
		[SerializeField] protected bool separateMaterial = false;

		protected Mesh mesh;
		protected MeshFilter meshFilter;
		protected List<Vector3> vertices = new List<Vector3>();
		protected List<int> indicesB = new List<int>();
		protected List<int> indicesF = new List<int>();
		protected List<Vector2> uvs = new List<Vector2>();
		protected List<Color> colors = new List<Color>();

		// Use this for initialization
		void OnEnable()
		{
			CreateMesh();
		}

		void OnValidate()
		{
			segment = Mathf.Max(1, segment);
			slice = Mathf.Max(3, slice);
			CreateMesh();
		}

		void CreateMesh()
		{
			if (mesh)
			{
				Object.DestroyImmediate(mesh);
			}
			if (mesh == null)
			{
				mesh = new Mesh();
				mesh.name = name;
				mesh.hideFlags = HideFlags.DontSave;
			}

			if (mesh)
			{
				vertices.Clear();
				indicesB.Clear();
				indicesF.Clear();
				uvs.Clear();
				colors.Clear();

				int verticesCount = slice * (segment + 1);

				for (int j = 0; j <= segment; j++)
				{

					for (int i = 0; i < slice; i++)
					{
						float h = (float)j / segment;

						Vector3 pos0 = new Vector3(Mathf.Lerp(topRadius, bottomRadius, h), -height * h, 0);
						pos0 = Quaternion.Euler(new Vector3(0, i * 360.0f / slice, 0)) * pos0;
						vertices.Add(pos0); // Front
						uvs.Add(new Vector2((float)i / (slice - 1), h));
						if (gradient != null)
							colors.Add(gradient.Evaluate(h));

						if (j < segment)
						{
							// Back Face
							indicesB.Add(((i + 0) % slice) + (j + 0) * slice);
							indicesB.Add(((i + 1) % slice) + (j + 0) * slice);
							indicesB.Add(((i + 1) % slice) + (j + 1) * slice);

							indicesB.Add(((i + 0) % slice) + (j + 0) * slice);
							indicesB.Add(((i + 1) % slice) + (j + 1) * slice);
							indicesB.Add(((i + 0) % slice) + (j + 1) * slice);

							// Front Face
							indicesF.Add(verticesCount + ((i + 0) % slice) + (j + 0) * slice);
							indicesF.Add(verticesCount + ((i + 1) % slice) + (j + 1) * slice);
							indicesF.Add(verticesCount + ((i + 1) % slice) + (j + 0) * slice);

							indicesF.Add(verticesCount + ((i + 0) % slice) + (j + 0) * slice);
							indicesF.Add(verticesCount + ((i + 0) % slice) + (j + 1) * slice);
							indicesF.Add(verticesCount + ((i + 1) % slice) + (j + 1) * slice);
						}
					}
				}

				vertices.AddRange(vertices);
				uvs.AddRange(uvs);
				colors.AddRange(colors);

				mesh.vertices = vertices.ToArray();
				if (separateMaterial)
				{
					mesh.subMeshCount = 2;
					mesh.SetTriangles(indicesB.ToArray(), 0);
					mesh.SetTriangles(indicesF.ToArray(), 1);
				}
				else
				{
					mesh.subMeshCount = 1;
					var indices = new List<int>();
					indices.AddRange(indicesB);
					indices.AddRange(indicesF);
					mesh.SetTriangles(indices.ToArray(), 0);
				}
				mesh.uv = uvs.ToArray();
				if (gradient != null)
					mesh.colors = colors.ToArray();

				mesh.RecalculateNormals();

				meshFilter = GetComponent<MeshFilter>();
				if (!meshFilter)
					meshFilter = gameObject.AddComponent<MeshFilter>();

				if (!GetComponent<MeshRenderer>())
					gameObject.AddComponent<MeshRenderer>();

				if (meshFilter && meshFilter.sharedMesh != mesh)
				{
					meshFilter.sharedMesh = mesh;
				}
			}
		}
	}
}