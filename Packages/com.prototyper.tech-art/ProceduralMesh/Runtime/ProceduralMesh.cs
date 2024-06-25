namespace SS
{
	using System.Collections;
	using System.Collections.Generic;
	using UnityEngine;
#if UNITY_EDITOR
	using UnityEditor;
#endif

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

		public void ForceUpdate()
		{
			Update();
		}

		public void InjectCollider(MeshCollider collider)
		{
			meshCollider = collider;
		}

		[InspectorButton("Save Mesh", "SaveMesh")]
		[SerializeField]
		private bool alwaysCreateNewMesh = false;

		[SerializeField] private MeshCollider meshCollider;

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
			if (mesh == null)
				return;
			if (mesh.hideFlags != HideFlags.None)
			{
				Object.DestroyImmediate(mesh);
			}
			else
			{
				mesh = null;
			}
		}

		protected virtual void OnValidate()
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
			//Debug.Log(vertices.Count);

			vertices.Clear();
			indices.Clear();
			uvs.Clear();
			colors.Clear();

			CheckComponent();
			OnCalculateVertices();

			// Destroy old mesh
			//Debug.Log(vertices.Count);
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

				// Assing new mesh
				if (meshFilter && meshFilter.sharedMesh != mesh)
				{
					meshFilter.sharedMesh = mesh;
				}

				if (meshCollider && meshCollider.sharedMesh != mesh)
				{
					meshCollider.sharedMesh = mesh;
				}
			}
			isDirty = false;
		}

		protected virtual void CheckComponent()
		{
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
		}

#if UNITY_EDITOR
		[ContextMenu("Save Mesh")]
		public virtual void SaveMesh()
		{
			if (mesh)
			{
				var path = UnityEditor.EditorUtility.SaveFilePanelInProject("Save Mesh", mesh.name, "asset", "Save Mesh");
				if (!string.IsNullOrEmpty(path))
				{
					enabled = false;
					Mesh newMesh = new Mesh();
					newMesh.name = name;
					OnSetupMesh(newMesh);
					UnityEditor.AssetDatabase.CreateAsset(newMesh, path);
					UnityEditor.AssetDatabase.SaveAssets();
					AssetDatabase.Refresh();
					if (meshFilter)
						meshFilter.sharedMesh = newMesh;
				}
			}
		}
#endif
	}

}