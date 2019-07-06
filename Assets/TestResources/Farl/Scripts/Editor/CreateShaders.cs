using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEditor;
using UnityEditor.SceneManagement;
using System.IO;

public class CreateShaders : EditorWindow {
    [MenuItem("Tools/Create Shaders")]
    public static void CreateWindow()
    {
        CreateShaders w = EditorWindow.GetWindow<CreateShaders>();
    }

    private static string shaderName = "Category/ShaderName";
	private static string shortShaderName = "ShaderName";

    private static string shaderRelativeFolder = "";
    private static string materialRelativeFolder = "";
    private static string sceneRelativeFolder = "";

    private static string absShaderPath = "";

    private static string relativeShaderPath = "";
    private static string relativeMaterialPath = "";
    private static string relativeScenePath = "";

    private static Shader shader;
    private static Material material;
    private static Scene scene;

	private static string fullShaderName = string.Empty;
	private static string shaderUserName = "Farl";

	private static bool useShaderOwnFolder = true;

	void OnEnable()
	{
		useShaderOwnFolder = EditorPrefs.GetBool ("CreateShader.useShaderOwnFolder", useShaderOwnFolder);
		shaderUserName = EditorPrefs.GetString ("CreateShader.shaderUserName", shaderUserName);

		UpdateProperty ();
	}

	void CreateFolder(string path)
	{
		path = Directory.GetParent (path).ToString ();

		if (!Directory.Exists(path))
		{
			Directory.CreateDirectory (path);
		}
	}

	void UpdateProperty()
	{
		EditorPrefs.SetBool ("CreateShader.useShaderOwnFolder", useShaderOwnFolder);
		EditorPrefs.SetString ("CreateShader.shaderUserName", shaderUserName);

		shortShaderName = Path.GetFileName (shaderName);
		fullShaderName = string.Format("Custom/{0}/{1}", shaderUserName, shaderName);


		if (useShaderOwnFolder) {
			// Shader Own Folder: Custom/Farl/Shaders/Category/ShaderName/ShaderName.shader
			// = Custom/{User}/Shaders/{ShaderName}
			shaderRelativeFolder = string.Format("TestResources/{0}/Shaders/{1}", shaderUserName, shaderName);
			materialRelativeFolder = shaderRelativeFolder;
			sceneRelativeFolder = shaderRelativeFolder;
		} else {
			// Share Folder: Custom/Farl/Shaders/Category/ShaderName.shader
			string shaderCategory = Directory.GetParent(shaderName).ToString();

			shaderRelativeFolder = string.Format("Custom/{0}/Shaders/{1}", shaderUserName, shaderCategory);
			materialRelativeFolder = string.Format("Custom/{0}/Materials/{1}", shaderUserName, shaderCategory);
			sceneRelativeFolder = string.Format("Custom/{0}/Scenes/{1}", shaderUserName, shaderCategory);
		}

		// Relative full path
		relativeShaderPath = Path.Combine(shaderRelativeFolder, shortShaderName + ".shader");
		relativeMaterialPath = Path.Combine(materialRelativeFolder, shortShaderName + ".mat");
		relativeScenePath = Path.Combine(sceneRelativeFolder, shortShaderName + ".unity");

		// Absolute directory path
		absShaderPath = Path.Combine(Application.dataPath, relativeShaderPath);
	}

    private void OnGUI()
    {

		EditorGUI.BeginChangeCheck ();
		{
			useShaderOwnFolder = EditorGUILayout.Toggle ("Use Shader Own Folder", useShaderOwnFolder);
			shaderUserName = EditorGUILayout.TextField ("Shader User Name", shaderUserName);
			shaderName = EditorGUILayout.TextField(shaderName);

			GUI.enabled = false;
			EditorGUILayout.TextField(absShaderPath);
			EditorGUILayout.Space ();

			EditorGUILayout.TextField(relativeShaderPath);
			EditorGUILayout.TextField(relativeMaterialPath);
			EditorGUILayout.TextField(relativeScenePath);
			GUI.enabled = true;
		}
		if (EditorGUI.EndChangeCheck ())
		{
			UpdateProperty();
		}

        if (GUILayout.Button("Create Shader"))
        {
			UpdateProperty ();

			// Create Folder
			CreateFolder (absShaderPath);
			CreateFolder (Path.Combine(Application.dataPath, relativeMaterialPath));
			CreateFolder (Path.Combine(Application.dataPath, relativeScenePath));

			// Create shader
			using (StreamWriter sw = File.CreateText(absShaderPath))
            {
                sw.WriteLine(@"Shader """ + fullShaderName + @""" {");
                sw.WriteLine("\tSubShader{ Pass{}}");
                sw.WriteLine("}");
                sw.Close();
            }

			// Import shader
            AssetImporter importer = AssetImporter.GetAtPath(Path.Combine("Assets", relativeShaderPath));
            if (importer != null)
            {
                importer.SaveAndReimport();
                importer.SaveAndReimport();
            }
            AssetDatabase.Refresh();

			// Find shader
            shader = Shader.Find(fullShaderName) ? Shader.Find(fullShaderName) : Shader.Find("Standard");
            
			// Create material
			material = new Material(shader);
            AssetDatabase.CreateAsset(material, Path.Combine("Assets", relativeMaterialPath));

			// Create scene
            scene = EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects, NewSceneMode.Single);
            EditorSceneManager.SaveScene(scene, Path.Combine("Assets", relativeScenePath));
        }

		// Show shader, material, scene
        EditorGUILayout.ObjectField("Shader", shader, typeof(Shader), false);
        
		EditorGUILayout.ObjectField("Material", material, typeof(Material), false);

		EditorGUILayout.TextField("Scene", scene.name);
		if (scene.IsValid() && GUILayout.Button("Open Scene"))
		{
			EditorSceneManager.OpenScene(scene.path, OpenSceneMode.Single);
		}
    }
}
