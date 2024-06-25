using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SS;

public class ProceduralMeshLine : ProceduralMesh
{
    #region Enums
    public enum ReferenceVector
    {
        X,
        Y,
        Z,
        NegativeX,
        NegativeY,
        NegativeZ,
    }
    #endregion

    [SerializeField] private bool showDebugInfo = false;
    [SerializeField] Vector3[] positions;
    [SerializeField] Vector3[] nodeNormals;
    [SerializeField] float width = 1f;
    [SerializeField] int segment = 1;
    [SerializeField] int capVertexCount = 1;

    [SerializeField] Color tintColor = Color.white;

    
    [Space, SerializeField] public bool test;
    [SerializeField] public float ropeLength = 2f;
    [SerializeField] int gridSegmentU = 1;
    [SerializeField] int gridSegmentV = 1;
    [SerializeField] ReferenceVector defaultNormalVector = ReferenceVector.Y;

    [SerializeField] bool isClosed = false;
    [SerializeField] bool updateCollision;

    protected override void OnCalculateVertices()
    {
        float ropeThickness = width;
        int slice = isClosed? positions.Length: positions.Length - 1;
        segment = Mathf.Max(1, segment);
        if (test)
        {
            slice = gridSegmentU;
            segment = gridSegmentV;
        }
        capVertexCount = Mathf.Max(0, capVertexCount);

        for (int i = 0; i <= slice; i++)
        {
            for (int j = 0; j <= segment; j++)
            {
                var factor = new Vector2((float)i, (float)j);

                var uv = new Vector2(factor.x / slice, factor.y / segment);

                Vector3 vPos = Vector3.zero;
                if (test)
                {
                    vPos = new Vector3(
                        factor.x / (slice),
                        0,
                        factor.y / (segment) - 0.5f
                    );
                    vPos.x *= ropeLength;
                    vPos.z *= ropeThickness;
                }
                else
                {
                    var idx = i < positions.Length ? i : 0;
                    var normal = defaultNormal;
                    if (nodeNormals != null && idx < nodeNormals.Length)
                    {
                        normal = nodeNormals[idx];
                    }
                    vPos = positions[idx];
                    var prevIdx = (!isClosed)? Mathf.Clamp(idx - 1, 0, positions.Length - 1) : ((idx - 1 + positions.Length) % positions.Length);
                    var nextIdx = (!isClosed)? Mathf.Clamp(idx + 1, 0, positions.Length - 1) : ((idx + 1) % positions.Length);
                    var prevPos = positions[prevIdx];
                    var nextPos = positions[nextIdx];
                    var dir = (((nextPos - vPos) + (vPos - prevPos)) * 0.5f).normalized;
                    var binormal = Vector3.Cross(dir, normal).normalized;
                    vPos += -binormal * (factor.y / segment - 0.5f) * ropeThickness;
                }

                //Debug.Log($"{factor}, {vPos}");
                vertices.Add(vPos);
                uvs.Add(uv);
                colors.Add(tintColor);

                if (j < segment && i < slice)
                {
                    var tmp = (segment + 1);
                    indices.Add(((j + 0) % tmp) + (i + 0) * tmp);
                    indices.Add(((j + 1) % tmp) + (i + 1) * tmp);
                    indices.Add(((j + 1) % tmp) + (i + 0) * tmp);

                    indices.Add(((j + 0) % tmp) + (i + 0) * tmp);
                    indices.Add(((j + 0) % tmp) + (i + 1) * tmp);
                    indices.Add(((j + 1) % tmp) + (i + 1) * tmp);
                }
            }
        }

        if (!isClosed && capVertexCount > 0)
        {
            // Add start and end cap
            var angleSegment = capVertexCount + 1;
            for (int se = 0; se < 2; se++)
            {
                if (positions.Length > 1)
                {
                    var idx = se == 0 ? 0 : positions.Length - 1;
                    var normal = defaultNormal;
                    if (nodeNormals != null && idx < nodeNormals.Length)
                    {
                        normal = nodeNormals[idx];
                    }
                    var dir = se == 0? (positions[0] - positions[1]) : (positions[positions.Length - 1] - positions[positions.Length - 2]);
                    var binormal = Vector3.Cross(dir, normal).normalized;
                    normal = Vector3.Cross(binormal, dir).normalized;
                    var offset = binormal * ropeThickness * 0.5f;
                    var position = se == 0 ? positions[0] : positions[positions.Length - 1];
                    for (int i = 0; i < angleSegment; i++)
                    {
                        Vector2 angle = new Vector2(180f / angleSegment * i, 180f / angleSegment * (i+1));

                        var vPos = position;
                        vertices.Add(vPos);
                        uvs.Add(new Vector2(0, 0.5f));
                        indices.Add(vertices.Count - 1);
                        colors.Add(tintColor);
                        // vPos = offset from positions[0] rotate angle[0] degree
                        vPos = position + Quaternion.AngleAxis(angle.x, normal) * offset;
                        vertices.Add(vPos);
                        uvs.Add(new Vector2(0, 1));
                        indices.Add(vertices.Count - 1);
                        colors.Add(tintColor);
                        // vPos = offset from positions[0] rotate angle[1] degree
                        vPos = position + Quaternion.AngleAxis(angle.y, normal) * offset;
                        vertices.Add(vPos);
                        uvs.Add(new Vector2(0, 1));
                        indices.Add(vertices.Count - 1);
                        colors.Add(tintColor);
                    }
                }
            }
        }
    }

    protected override void OnSetupMesh(Mesh mesh)
    {
        
        mesh.subMeshCount = 1;
        mesh.vertices = vertices.ToArray();
        mesh.uv = uvs.ToArray();
        mesh.colors = colors.ToArray();
        mesh.SetTriangles(indices.ToArray(), 0);
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();

        if (updateCollision)
        {
            var collider = GetComponent<MeshCollider>();
            if (collider != null)
            {
                collider.sharedMesh = mesh;
            }
        }
    }

    protected override void OnValidate()
    {
        if (positions.Length < 2)
        {
            positions = new Vector3[2] { Vector3.zero, Vector3.forward };
        }
        base.OnValidate();
    }

    public void UpdateLineVertices(Vector3[] positions, Vector3[] normals = null)
    {
        this.positions = positions;
        if (normals != null)
        {
            nodeNormals = normals;
        }
        else
        {
            nodeNormals = null;
        }
        isDirty = true;
    }

    private Vector3 defaultNormal
    {
        get
        {
            switch (defaultNormalVector)
            {
                case ReferenceVector.X:
                    return cachedTransform.right;
                default:
                case ReferenceVector.Y:
                    return cachedTransform.up;
                case ReferenceVector.Z:
                    return cachedTransform.forward;
                case ReferenceVector.NegativeX:
                    return -cachedTransform.right;
                case ReferenceVector.NegativeY:
                    return -cachedTransform.up;
                case ReferenceVector.NegativeZ:
                    return -cachedTransform.forward;
            }
        }
    }

    private void OnDrawGizmos()
    {
        if (!showDebugInfo)
            return;
        if (positions != null)
        {
            Gizmos.matrix = cachedTransform.localToWorldMatrix;
            Gizmos.color = Color.white;
            for (int i = 0; i < positions.Length; i++)
            {
                Gizmos.DrawSphere(positions[i], 0.1f);
            }
            // Draw normal
            if (nodeNormals != null)
            {
                Gizmos.color = Color.green;
                for (int i = 0; i < nodeNormals.Length && i < positions.Length; i++)
                {
                    Gizmos.DrawLine(positions[i], positions[i] + nodeNormals[i]);
                }
            }
        }
    }
}
