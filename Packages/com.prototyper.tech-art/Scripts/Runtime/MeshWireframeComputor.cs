using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

// Reference: https://github.com/MinaPecheux/unity-tutorials
// main/Assets/00-Shaders/CrossPlatformWireframe/Scripts/MeshWireframeComputor.cs
// Support two channel to fill the 3-collorable graph holes
public class MeshWireframeComputor : MonoBehaviour
{
    public enum Channel
    {
        None = -1,
        UV1 = 0,
        UV2 = 1,
        UV3 = 2,
        UV4 = 3,
    }
    public enum RedundancySolution
    {
        None,
        PickAgain,
        PickLast
    }

    private static Color[] _Coordinate = new Color[] {
        new Color(1, 0, 0, 0),
        new Color(0, 1, 0, 0),
        new Color(0, 0, 1, 0),
        new Color(0, 0, 0, 1),
    };

    [SerializeField] private RedundancySolution redundancySolution = RedundancySolution.None;

    [SerializeField] private Channel channel2 = Channel.UV3;
    [SerializeField] private RedundancySolution redundancySolution2 = RedundancySolution.PickAgain;

    // Calculate the wireframe of a mesh and write it into vertex colors
    [ContextMenu("Update Mesh")]
    public void UpdateMesh()
    {
        if (!gameObject.activeSelf)
            return;

        // Mesh renderer
        if (meshRenderer == null)
            meshRenderer = GetComponent<MeshRenderer>();
        if (skinnedMeshRenderer == null)
            skinnedMeshRenderer = GetComponent<SkinnedMeshRenderer>();
        
        if (meshRenderer == null && skinnedMeshRenderer == null)
            return;

        Mesh mesh = meshRenderer != null? GetComponent<MeshFilter>().sharedMesh: skinnedMeshRenderer? skinnedMeshRenderer.sharedMesh: null;
        if (mesh == null)
            return;

        // Compute and store vertex colors for the
        // wireframe shader
        SortedColoring(mesh, out Color[] colors, out Vector4[] uvs);

        void SetupMesh(Mesh mesh, Channel channel, Vector4[] uvs)
        {
            if (uvs == null)
                return;
            switch (channel)
            {
                case Channel.UV1:
                    mesh.SetUVs(0, uvs);
                    break;
                case Channel.UV2:
                    mesh.SetUVs(1, uvs);
                    break;
                case Channel.UV3:
                    mesh.SetUVs(2, uvs);
                    break;
                case Channel.UV4:
                    mesh.SetUVs(3, uvs);
                    break;
            }
        }

        if (colors != null && mesh != null)
        {
            mesh.SetColors(colors);
            if (channel2 != Channel.None)
                SetupMesh(mesh, channel2, uvs);
        }
    }

    private MeshRenderer meshRenderer;
    private SkinnedMeshRenderer skinnedMeshRenderer;

    // https://tech.metail.com/colouring-graphs-for-a-wireframe-shader/
    private void SortedColoring(Mesh mesh, out Color[] colors, out Vector4[] uvs)
    {
        int vertexCount = mesh.vertexCount;
        int[] labels = new int[vertexCount];
        colors = new Color[vertexCount];
        int[] labels2 = new int[vertexCount];
        uvs = new Vector4[vertexCount];

        // Each int[] represents a triangle, with the indices of its vertices
        List<int[]> triangles = GetSortedTriangles(mesh.triangles);

        void CheckAlreadyUsed(int vIdx, int[] labels, HashSet<int> availableLabels, RedundancySolution redundancySolution)
        {
            if (labels[vIdx] > 0)
            {
                if (availableLabels.Contains(labels[vIdx]))
                {
                    availableLabels.Remove(labels[vIdx]);
                }
                else
                {
                    // Color already used by another vertex
                    switch (redundancySolution)
                    {
                        default:
                        case RedundancySolution.None:
                            // Do nothing
                            break;
                        case RedundancySolution.PickLast:
                            labels[vIdx] = -1;
                            break;
                        case RedundancySolution.PickAgain:
                            // Pick again
                            labels[vIdx] = 0;
                            break;

                    }
                }
            }
        }

        void AssignAvailable(int vIdx, int[] labels, HashSet<int> availableLabels)
        {
            if (labels[vIdx] <= 0)
            {
                if (availableLabels.Count == 0)
                {
                    Debug.LogError("No more available labels!");
                    labels[vIdx] = 0;
                }
                else
                {
                    if (labels[vIdx] == 0)
                        labels[vIdx] = availableLabels.First();
                    else
                        labels[vIdx] = availableLabels.Last();
                    availableLabels.Remove(labels[vIdx]);
                }
            }
        }

        HashSet<int> availableLabels;
        HashSet<int> availableLabels2;
        foreach (int[] triangle in triangles)
        {
            availableLabels = new HashSet<int>() { 1, 2, 3, 4 };
            availableLabels2 = new HashSet<int>() { 1, 2, 3, 4 };

            foreach (int vIdx in triangle)
            {
                CheckAlreadyUsed(vIdx, labels, availableLabels, redundancySolution);
                CheckAlreadyUsed(vIdx, labels2, availableLabels2, redundancySolution2);
            }
            foreach (int vIdx in triangle)
            {
                AssignAvailable(vIdx, labels, availableLabels);
                AssignAvailable(vIdx, labels2, availableLabels2);
            }
        }

        for (int vIdx = 0; vIdx < vertexCount; vIdx++)
        {
            colors[vIdx] = labels[vIdx] > 0 ? _Coordinate[labels[vIdx] - 1] : _Coordinate[3];
            uvs[vIdx] = labels2[vIdx] > 0 ? _Coordinate[labels2[vIdx] - 1] : _Coordinate[3];
        }
    }

    // Get the sorted triangles of a mesh by sorting the vertices of each triangle
    private List<int[]> GetSortedTriangles(int[] triangles)
    {
        List<int[]> result = new List<int[]>();
        for (int i = 0; i < triangles.Length; i += 3)
        {
            List<int> t = new List<int> { triangles[i], triangles[i + 1], triangles[i + 2] };
            t.Sort();
            result.Add(t.ToArray());
        }

        // Sort the triangles by their vertices
        result.Sort((int[] t1, int[] t2) =>
        {
            int i = 0;
            while (i < t1.Length && i < t2.Length)
            {
                if (t1[i] < t2[i]) return -1;
                if (t1[i] > t2[i]) return 1;
                i += 1;
            }
            if (t1.Length < t2.Length) return -1;
            if (t1.Length > t2.Length) return 1;
            return 0;
        });
        return result;
    }

#if UNITY_EDITOR
    private void OnValidate()
    {
        UpdateMesh();
    }
#endif
}
