using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System.Linq;

public class ReferenceTool : EditorWindow {

	static ReferenceTool window;

	Vector2 scrollVec;
	string searchPattern = "*.*";
	string filterGUID;

	public class ReferenceData
	{
		public List<string> refs = new List<string>();
	}

	private Dictionary<string, ReferenceData> refMap = new Dictionary<string, ReferenceData>();

	[MenuItem("Tools/Reference Tool")]
	static void OpenWindow()
	{
		window = EditorWindow.GetWindow<ReferenceTool> ();
	}

	void OnGUI()
	{
		searchPattern = EditorGUILayout.TextField (searchPattern);
		if (GUILayout.Button ("Search")) {
			refMap.Clear ();

			string[] filePaths = Directory.GetFiles ((Application.dataPath), searchPattern, SearchOption.AllDirectories);
			IEnumerable<string> files = filePaths.Where(s => s.EndsWith(".unity", System.StringComparison.OrdinalIgnoreCase) ||
				s.EndsWith(".prefab", System.StringComparison.OrdinalIgnoreCase) ||
				s.EndsWith(".mat", System.StringComparison.OrdinalIgnoreCase));
			Debug.Log (files.Count());

			int fileIndex = 0;
			foreach (string filePath in files) {
				
				if (EditorUtility.DisplayCancelableProgressBar ("Searching", filePath, (float)fileIndex / files.Count())) {
					continue;
				}

				fileIndex++;

				StreamReader sr = File.OpenText(filePath);
				if (sr != null) {
					string currLine = null;
					do {
						currLine = sr.ReadLine();
						if (!string.IsNullOrEmpty(currLine))
						{
							int index = currLine.IndexOf("guid: ");
							if (index >= 0)
							{
								string guid = currLine.Substring(index + 6, 32);
								if (!refMap.ContainsKey(guid))
								{
									refMap.Add(guid, new ReferenceData());
								}
								refMap[guid].refs.Add(filePath);
							}
						}
					} while (currLine != null);
					sr.Close ();
				}
			}
			EditorUtility.ClearProgressBar ();
		}
		filterGUID = EditorGUILayout.TextField(filterGUID);

		if (!string.IsNullOrEmpty(filterGUID))
		{
			if (refMap.ContainsKey(filterGUID))
			{
				scrollVec = EditorGUILayout.BeginScrollView (scrollVec, GUILayout.ExpandWidth(true));
				foreach (string p in refMap[filterGUID].refs)
				{
					string path = p.Replace (Application.dataPath + Path.DirectorySeparatorChar, "");
					path = Path.Combine (@"Assets/", path);
					if (GUILayout.Button("Select " + path))
					{
						Selection.activeObject = AssetDatabase.LoadMainAssetAtPath (path);
					}
				}
				EditorGUILayout.EndScrollView ();
			}
		}

		Rect myRect = GUILayoutUtility.GetRect(0,20,GUILayout.ExpandWidth(true));
		GUI.Box(myRect,"Drag and Drop Prefabs to this Box!");
		if (myRect.Contains(Event.current.mousePosition))
		{
			if (Event.current.type == EventType.DragUpdated)
			{
				DragAndDrop.visualMode = DragAndDropVisualMode.Copy;
				//Debug.Log("Drag Updated!");
				Event.current.Use ();
			}   
			else if (Event.current.type == EventType.DragPerform)
			{
				//Debug.Log("Drag Perform!");
				//Debug.Log(DragAndDrop.objectReferences.Length);
				for(int i = 0; i<DragAndDrop.objectReferences.Length;i++)
				{
				}
				filterGUID = AssetDatabase.AssetPathToGUID (AssetDatabase.GetAssetPath (DragAndDrop.objectReferences [0]));
				Event.current.Use ();
			}
		}
	}
}
