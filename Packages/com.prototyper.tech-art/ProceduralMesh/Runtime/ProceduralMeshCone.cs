namespace SS
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

    /// <summary>
    /// by Farl
    /// </summary>
    [ExecuteAlways]
    public class ProceduralMeshCone : ProceduralMesh
    {
        [SerializeField]
        private float topRadius = 1;
        [SerializeField]
        private float height = 1;
        [SerializeField]
        private float bottomRadius = 1;
        [SerializeField]
        private int slice = 12;
        [SerializeField]
        private int segment = 4;
        [SerializeField]
        private Gradient gradient;

		private List<int> indicesB = new List<int>();
		private List<int> indicesF = new List<int>();

		protected override void OnCalculateVertices()
		{
			// Fix values
			segment = Mathf.Max(1, segment);
			slice = Mathf.Max(3, slice);

			indicesB.Clear();
			indicesF.Clear();

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

			// Double it (Back and front face)
			vertices.AddRange(vertices);
			uvs.AddRange(uvs);
			colors.AddRange(colors);
		}

		protected override void OnSetupMesh(Mesh mesh)
		{
			mesh.subMeshCount = 2;
			mesh.vertices = vertices.ToArray();
			mesh.SetTriangles(indicesB.ToArray(), 0);
			mesh.SetTriangles(indicesF.ToArray(), 1);
			mesh.uv = uvs.ToArray();
			if (gradient != null)
				mesh.colors = colors.ToArray();

			mesh.RecalculateNormals();
		}
    }

}