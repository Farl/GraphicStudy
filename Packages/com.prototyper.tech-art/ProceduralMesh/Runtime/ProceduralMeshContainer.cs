namespace SS
{
    using System.Collections.Generic;
    using System.Linq;
    using UnityEngine;

    /// <summary>
    /// by Farl
    /// </summary>
    [ExecuteAlways]
    public class ProceduralMeshContainer : ProceduralMesh
    {
        [SerializeField] private bool showDebugInfo = false;
        [Header("Spec")]
        [SerializeField] private float topRadius = 1;
        [SerializeField] private float bottomRadius = 1;
        [SerializeField] private float height = 1;

        [SerializeField] private float thickness = 0.1f;
        [SerializeField] private float bottomThickness = 0.1f;
        [Header("Geometry")]
        [SerializeField] private int segment = 4;
        [SerializeField] private int startCapSegment = 1;
        [SerializeField] private int endCapSegment = 1;
        [SerializeField] private int thicknessSegment = 1;
        [SerializeField] private int slice = 12;
        [Header("Other")]
        [SerializeField] private bool useGradient = false;
        [SerializeField] private Gradient gradient;
        private bool startCap => startCapSegment > 0;
        private bool endCap => startCapSegment > 0;
        private List<Vector3> normals = new List<Vector3>();
        [SerializeField] private Direction direction = Direction.Y;
        [SerializeField] private bool useCalculateNormal = false;

        public enum Direction
        {
            Y = 1,
            MINUS_Y = 0,
        }

        private List<int> indicesB = new List<int>();
        private List<int> indicesF = new List<int>();

        public enum FaceType
        {
            Front,
            Back,
            Both
        }

        [SerializeField] private FaceType faceType = FaceType.Front;

        protected override void OnCalculateVertices()
        {
            // Fix values
            segment = Mathf.Max(1, segment);
            slice = Mathf.Max(3, slice);
            startCapSegment = Mathf.Max(0, startCapSegment);
            endCapSegment = Mathf.Max(0, endCapSegment);

            normals.Clear();
            indicesB.Clear();
            indicesF.Clear();

            float radius1 = topRadius, radius2 = bottomRadius;
            if (direction == Direction.Y)
            {
                radius1 = bottomRadius;
                radius2 = topRadius;
            }

            float dirSign = direction == Direction.MINUS_Y ? -1 : 1;
            Vector3 pos0 = Vector3.zero;
            Vector3 pos = Vector3.zero;
            Vector3 normal0 = Vector3.forward;
            Vector3 normal = Vector3.forward;
            int currPart = 0;
            float h = 0;

            int[] partSegments = new int[] { startCapSegment, segment, thicknessSegment, segment, endCapSegment };
            int[] accumSegments = new int[partSegments.Length];
            for (int i = 0; i < partSegments.Length; i++)
            {
                for (int j = 0; j <= i; j++)
                {
                    accumSegments[i] += partSegments[j];
                }
            }
            var totalSegment = accumSegments[accumSegments.Length - 1];
            int verticesCount = (slice + 1) * (totalSegment + 1);

            if (showDebugInfo)
            {
                for (int p = 0; p < partSegments.Length; p++)
                {
                    Debug.Log($"{p} {partSegments[p]} {accumSegments[p]}");
                }
            }

            for (int j = 0; j <= totalSegment; j++)
            {
                h = 0;
                currPart = 5;
                for (int p = 0; p < accumSegments.Length; p++)
                {
                    if (j < accumSegments[p])
                    {
                        currPart = p;
                        var current_j = (p - 1) >= 0? j - accumSegments[p - 1]: j;
                        //Debug.Log($"{current_j} / {partSegments[p]}");
                        h = partSegments[p] > 0? Mathf.Clamp01((float)current_j / partSegments[p]): 0;
                        break;
                    }
                }

                switch (currPart)
                {
                    case 0:
                        // Start cap
                        pos0 = Vector3.Lerp(
                            new Vector3(0, 0, 0),
                            new Vector3(radius1, 0, 0),
                            h);
                        normal0 = Vector3.up * -dirSign;
                        break;
                    case 1:
                        // Out
                        pos0 = Vector3.Lerp(
                            new Vector3(radius1, 0, 0),
                            new Vector3(radius2, height * dirSign, 0),
                            h);
                        normal0 = new Vector3(height, -dirSign * (radius2 - radius1), 0).normalized;
                        break;
                    case 2:
                        // Thickness
                        pos0 = Vector3.Lerp(
                            new Vector3(radius2, height * dirSign, 0),
                            new Vector3(radius2 - thickness, height * dirSign, 0),
                            h);
                        normal0 = Vector3.up * dirSign;
                        break;
                    case 3:
                        // In
                        pos0 = Vector3.Lerp(
                            new Vector3(radius2 - thickness, height * dirSign, 0),
                            new Vector3(Mathf.Lerp(radius1, radius2, height > 0 ? bottomThickness / height : 0) - thickness, bottomThickness * dirSign, 0),
                            h);
                        normal0 = -new Vector3(height, -dirSign * (radius2 - radius1), 0).normalized;
                        break;
                    case 4:
                        // End cap
                        pos0 = Vector3.Lerp(
                            new Vector3(Mathf.Lerp(radius1, radius2, height > 0 ? bottomThickness / height : 0) - thickness, bottomThickness * dirSign, 0),
                            new Vector3(0, bottomThickness * dirSign, 0),
                            h);
                        normal0 = Vector3.up * dirSign;
                        break;
                    default:
                    case 5:
                        // End cap final
                        pos0 = new Vector3(0, bottomThickness * dirSign, 0);
                        normal0 = Vector3.up * dirSign;
                        break;
                }

                if (showDebugInfo)
                    Debug.Log($"j={j} currPart={currPart} pos={pos0} h={h}");

                for (int i = 0; i <= slice; i++)
                {
                    pos = Quaternion.Euler(new Vector3(0, i * 360.0f / slice, 0)) * pos0;
                    normal = Quaternion.Euler(new Vector3(0, i * 360.0f / slice, 0)) * normal0;

                    vertices.Add(pos);
                    normals.Add(normal);
                    uvs.Add(new Vector2((float)i / slice, h));

                    if (useGradient)
                    {
                        colors.Add(gradient.Evaluate(h));
                    }

                    //(int, int) idx2 = ((i + 1) % slice, j + 1);
                    (int, int) idx2 = (i + 1, j + 1);

                    if (j < totalSegment && i < slice)
                    {
                        var sliceVerticesCount = slice + 1;
                        // Clockwise
                        if (faceType == FaceType.Both || (direction != Direction.Y && faceType == FaceType.Back) || (direction == Direction.Y && faceType == FaceType.Front))
                        {
                            indicesB.Add((i + 0) + (j + 0) * sliceVerticesCount);
                            indicesB.Add((idx2.Item1) + (j + 0) * sliceVerticesCount);
                            indicesB.Add((i + 0) + (idx2.Item2) * sliceVerticesCount);

                            indicesB.Add((idx2.Item1) + (j + 0) * sliceVerticesCount);
                            indicesB.Add((idx2.Item1) + (idx2.Item2) * sliceVerticesCount);
                            indicesB.Add((i + 0) + (idx2.Item2) * sliceVerticesCount);

                            if (showDebugInfo)
                            {
                                // print 6 indices
                                // StringBuilder sb = new StringBuilder();
                                // for (int a = 0; a < 6; a++)
                                // {
                                // 	sb.AppendLine(indicesB[indicesB.Count - 6 + a].ToString());
                                // }
                                // Debug.Log(sb.ToString());
                            }
                        }

                        // Counter Clockwise
                        if (faceType == FaceType.Both || (direction != Direction.Y && faceType == FaceType.Front) || (direction == Direction.Y && faceType == FaceType.Back))
                        {
                            var offset = faceType == FaceType.Both ? verticesCount : 0;
                            indicesF.Add(offset + (i + 0) + (j + 0) * sliceVerticesCount);
                            indicesF.Add(offset + (i + 0) + (idx2.Item2) * sliceVerticesCount);
                            indicesF.Add(offset + (idx2.Item1) + (j + 0) * sliceVerticesCount);

                            indicesF.Add(offset + (idx2.Item1) + (j + 0) * sliceVerticesCount);
                            indicesF.Add(offset + (i + 0) + (idx2.Item2) * sliceVerticesCount);
                            indicesF.Add(offset + (idx2.Item1) + (idx2.Item2) * sliceVerticesCount);

                            if (showDebugInfo)
                            {
                                // print 6 indices
                                // StringBuilder sb = new StringBuilder();
                                // for (int a = 0; a < 6; a++)
                                // {
                                // 	sb.AppendLine(indicesF[indicesF.Count - 6 + a].ToString());
                                // }
                                // Debug.Log(sb.ToString());
                            }
                        }
                    }
                }
            }

            if (faceType == FaceType.Both)
            {
                // Double it (Back and front face)
                vertices.AddRange(vertices);
                normals.AddRange(normals);
                uvs.AddRange(uvs);
                colors.AddRange(colors);
            }
        }

        protected override void OnSetupMesh(Mesh mesh)
        {
            mesh.subMeshCount = (indicesB.Count > 0 ? 1 : 0) + (indicesF.Count > 0 ? 1 : 0);
            mesh.vertices = vertices.ToArray();
            mesh.SetNormals(normals.ToArray());

            int subMeshIndex = 0;
            if (indicesB.Count > 0)
            {
                mesh.SetTriangles(indicesB.ToArray(), subMeshIndex);
                subMeshIndex++;
            }
            if (indicesF.Count > 0)
            {
                mesh.SetTriangles(indicesF.ToArray(), subMeshIndex);
                subMeshIndex++;
            }

            mesh.uv = uvs.ToArray();
            if (useGradient)
            {
                mesh.colors = colors.ToArray();
            }

            if (useCalculateNormal)
                mesh.RecalculateNormals();
        }

        public void InjectCone(float topRadius, float bottomRadius, float height, int slice, int segment, Direction direction = Direction.Y)
        {
            this.topRadius = topRadius;
            this.bottomRadius = bottomRadius;
            this.height = height;
            this.slice = slice;
            this.segment = segment;
            this.direction = direction;
            CreateMesh();
        }
    }

}