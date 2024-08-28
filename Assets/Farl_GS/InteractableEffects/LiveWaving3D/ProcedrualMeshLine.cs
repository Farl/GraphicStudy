using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SS;
public class ProcedrualMeshLine : ProceduralMesh
{
    [SerializeField]
    float gridSize = 10;
    [SerializeField]
    int gridSegmentU = 1;
    [SerializeField]
    int gridSegmentV = 1;

    protected override void OnSetupMesh(Mesh mesh)
    {
        mesh.subMeshCount = 1;
        mesh.vertices = vertices.ToArray();
        mesh.uv = uvs.ToArray();
        mesh.SetTriangles(indices.ToArray(), 0);
        mesh.RecalculateNormals();
    }

    protected override void OnCalculateVertices()
    {
        // Fix values
        gridSegmentU = Mathf.Max(1, gridSegmentU);
        gridSegmentV = Mathf.Max(1, gridSegmentV);
        gridSize = Mathf.Max(1e-8f, gridSize);

        int slice = gridSegmentU;
        int segment = gridSegmentV;

        for (int j = 0; j <= segment; j++)
        {
            for (int i = 0; i <= slice; i++)
            {
                var factor = new Vector2((float)i, (float)j);

                var uv = new Vector2(factor.x / slice, factor.y / segment);

                var vPos = new Vector3(
                    factor.x / (slice) - 0.5f,
                    0,
                    factor.y / (segment) - 0.5f
                );
                vPos *= gridSize;

                vertices.Add(vPos);
                uvs.Add(uv);

                if (j < segment && i < slice)
                {
                    var tmp = (slice + 1);
                    indices.Add(((i + 0) % tmp) + (j + 0) * tmp);
                    indices.Add(((i + 1) % tmp) + (j + 1) * tmp);
                    indices.Add(((i + 1) % tmp) + (j + 0) * tmp);

                    indices.Add(((i + 0) % tmp) + (j + 0) * tmp);
                    indices.Add(((i + 0) % tmp) + (j + 1) * tmp);
                    indices.Add(((i + 1) % tmp) + (j + 1) * tmp);
                }
            }
        }
    }
}
