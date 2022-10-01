namespace SS
{
	using System.Collections;
	using System.Collections.Generic;
	using UnityEngine;

	/// <summary>
	/// by Farl
	/// </summary>
	[ExecuteAlways]
	public class ProceduralMesh : MonoBehaviour
	{
		public Transform cachedTransform
		{
			get
			{
				if (_cachedTransform == null)
					_cachedTransform = transform;
				return _cachedTransform;
			}
		}

		[SerializeField]
		private bool alwaysCreateNewMesh = false;

		//[SerializeField]
		private Mesh mesh;
		//[SerializeField]
		private MeshFilter meshFilter;
		//[SerializeField]
		private MeshRenderer meshRenderer;

		private Transform _cachedTransform;

		protected List<Vector3> vertices = new List<Vector3>();
		protected List<int> indices = new List<int>();
		protected List<Vector2> uvs = new List<Vector2>();
		protected List<Color> colors = new List<Color>();

		protected bool isDirty = true;

		// Use this for initialization
		protected void OnEnable()
		{
			isDirty = true;
		}

		protected void OnDestroy()
		{
			DestroyMesh();
		}

		protected void DestroyMesh()
		{
			Object.DestroyImmediate(mesh);
		}

		protected void OnValidate()
		{
			isDirty = true;
		}

		protected virtual void Update()
		{
			if (isDirty)
				CreateMesh();
		}

		protected virtual void OnCalculateVertices()
		{
			vertices.Add(new Vector3(0, 0, 0));
			vertices.Add(new Vector3(0, 0, 1));
			vertices.Add(new Vector3(1, 0, 1));

			indices.Add(0);
			indices.Add(1);
			indices.Add(2);
		}

		protected virtual void OnSetupMesh(Mesh mesh)
		{
			mesh.subMeshCount = 1;
			mesh.vertices = vertices.ToArray();
			mesh.SetTriangles(indices.ToArray(), 0);
		}

		protected void CreateMesh()
		{
			var backupVerticesLength = vertices.Count;

			vertices.Clear();
			indices.Clear();
			uvs.Clear();
			colors.Clear();

			OnCalculateVertices();

			// Destroy old mesh
			if (mesh && (alwaysCreateNewMesh || backupVerticesLength != vertices.Count))
			{
				DestroyMesh();
			}

			if (mesh == null)
			{
				mesh = new Mesh();
				mesh.name = name;
				mesh.hideFlags = HideFlags.DontSave;
			}

			if (mesh)
			{
				OnSetupMesh(mesh);

				// Check components
				if (!meshFilter)
				{
					meshFilter = GetComponent<MeshFilter>();
					if (!meshFilter)
						meshFilter = gameObject.AddComponent<MeshFilter>();
				}

				if (!meshRenderer && meshFilter)
				{
					meshRenderer = meshFilter.GetComponent<MeshRenderer>();
					if (!meshRenderer)
						meshRenderer = meshFilter.gameObject.AddComponent<MeshRenderer>();
				}

				// Assing new mesh
				if (meshFilter && meshFilter.sharedMesh != mesh)
				{
					meshFilter.sharedMesh = mesh;
				}
			}
			isDirty = false;
		}
	}

}