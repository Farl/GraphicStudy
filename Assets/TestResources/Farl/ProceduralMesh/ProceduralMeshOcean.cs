namespace SS
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

    /// <summary>
    /// by Farl
    /// </summary>
    [ExecuteAlways]
    public class ProceduralMeshOcean : ProceduralMesh
    {
        [SerializeField]
        bool showDebugInfo = false;
        [SerializeField]
        float gridSize = 10;
        [SerializeField]
        int gridSegmentU = 1;
        [SerializeField]
        int gridSegmentV = 1;

        [Space]
        [SerializeField, Range(0f, 2f)]
        float t = 0.5f;
        [SerializeField]
        private float divide = 0.1f;
        [SerializeField]
        private float pow = 1f;
        [SerializeField]
        private float anglePow = 1f;
        [SerializeField]
        Transform waveDummy;

        [Space]
        [SerializeField]
        private Material material;
        [SerializeField]
        private string axisProperty = "_WaveAxis";
        [SerializeField]
        private string uvProperty = "_WaveUV";

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
                    vPos = OnModifyMesh(i, j, vPos);

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

        protected override void OnSetupMesh(Mesh mesh)
        {
            mesh.subMeshCount = 1;
            mesh.vertices = vertices.ToArray();
            mesh.uv = uvs.ToArray();
            mesh.SetTriangles(indices.ToArray(), 0);
            mesh.RecalculateNormals();

            if (material && waveDummy)
            {
                var localAxis = cachedTransform.InverseTransformDirection(waveDummy.right);

                material.SetVector(axisProperty, localAxis);

                var localUVW = cachedTransform.InverseTransformPoint(waveDummy.position) / gridSize;
                var localUV = new Vector2(localUVW.x, localUVW.z) + new Vector2(0.5f, 0.5f);
                material.SetVector(uvProperty, localUV);
            }
        }

        Vector3 Vector3Abs(Vector3 p)
        {
            return new Vector3(Mathf.Abs(p.x), Mathf.Abs(p.y), Mathf.Abs(p.z));
        }

        #region SDF
        float sdBox(Vector3 p, Vector3 b)
        {
            Vector3 d = Vector3Abs(p) - b;
            return Mathf.Min( Mathf.Max(d.x, d.y, d.z), 0.0f ) + Vector3.Max(d, Vector3.zero).magnitude;
        }
        float sdSphere(Vector3 p, float s)
        {
            return (p).magnitude - s;
        }

        #endregion

        protected virtual Vector3 OnModifyMesh(int i, int j, Vector3 vPos)
        {
            if (waveDummy == null)
                return vPos;

            // World position
            var wPos = cachedTransform.TransformPoint(vPos);

            var waveLocalPos = waveDummy.InverseTransformPoint(wPos);
            //var sdf = sdSphere(waveLocalPos, 1f);
            var sdf = sdBox(waveLocalPos, Vector3.one * 0.5f);
            if (sdf > 0)
                return vPos;

            var waveHeight = waveDummy.position.y - cachedTransform.position.y;
            var waveAxis = waveDummy.right;
            var wavePos = waveDummy.position;
            var waveAngle = waveDummy.localEulerAngles.x;

            // Fix angles
            while (waveAngle > 180)
                waveAngle -= 360f;

            // Remove y axis
            wavePos.y = wPos.y;
            waveAxis.y = 0;

            var waveRay = new Ray(wavePos, waveAxis);
            var d = Vector3.Dot(wPos - waveRay.origin, waveRay.direction.normalized);
            var waveDiff = (waveRay.GetPoint(d) - wPos).magnitude;

            var newPos = vPos;

            var diff = t * waveDiff;
            var pureF = Mathf.Exp(-(diff * diff));

            var offset = Quaternion.AngleAxis(waveAngle * Mathf.Pow(pureF, anglePow), waveAxis) *
                Vector3.up * waveHeight * pureF;
            
            var factor = (divide <= 0)? 1: Mathf.Min(1.0f, Mathf.Abs(sdf) / divide);
            factor = Mathf.Pow(factor, pow);
            newPos += offset * factor;

            return newPos;
        }

        protected override void Update()
        {
            isDirty = true;
            base.Update();
        }
    }

}