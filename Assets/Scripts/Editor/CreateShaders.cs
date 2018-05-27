using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEditor;
using UnityEditor.SceneManagement;
using System.IO;

public class CreateShaders : EditorWindow {
    [MenuItem("Tool/Create Shaders")]
    public static void CreateWindow()
    {
        CreateShaders w = EditorWindow.GetWindow<CreateShaders>();
    }

    private static string shaderName = "Test";

    private static string shaderRelativeFolder = "";
    private static string materialRelativeFolder = "";
    private static string sceneRelativeFolder = "";

    private static string shaderFolder = "";
    private static string materialFolder = "";
    private static string sceneFolder = "";

    private static string shaderPath = "";
    private static string materialPath = "";
    private static string scenePath = "";

    private static Shader shader;
    private static Material material;
    private static Scene scene;

    private void OnGUI()
    {
        shaderName = EditorGUILayout.TextField(shaderName);

        shaderRelativeFolder = "Shaders";
        materialRelativeFolder = "Materials";
        sceneRelativeFolder = "Scenes";

        shaderFolder = Path.Combine(Application.dataPath, shaderRelativeFolder);
        materialFolder = Path.Combine(Application.dataPath, materialRelativeFolder);
        sceneFolder = Path.Combine(Application.dataPath, sceneRelativeFolder);

        EditorGUILayout.TextField(shaderFolder);
        EditorGUILayout.TextField(materialFolder);
        EditorGUILayout.TextField(sceneFolder);

        shaderPath = Path.Combine(shaderRelativeFolder, shaderName + ".shader");
        materialPath = Path.Combine(materialRelativeFolder, shaderName + ".mat");
        scenePath = Path.Combine(sceneRelativeFolder, shaderName + ".unity");

        if (GUILayout.Button("Create Shader"))
        {

            string shaderCategoryName = string.Format("Custom/Farl/{0}", shaderName);
            using (StreamWriter sw = File.CreateText(Path.Combine(shaderFolder, shaderName + ".shader")))
            {
                sw.WriteLine(@"Shader """ + shaderCategoryName + @""" {");
                sw.WriteLine("\tSubShader{ Pass{}}");
                sw.WriteLine("}");
                sw.Close();
            }
            AssetImporter importer = AssetImporter.GetAtPath(Path.Combine("Assets", shaderPath));
            if (importer != null)
            {
                importer.SaveAndReimport();
                importer.SaveAndReimport();
            }
            AssetDatabase.Refresh();

            shader = Shader.Find(shaderCategoryName) ? Shader.Find(shaderCategoryName) : Shader.Find("Standard");
            material = new Material(shader);
            AssetDatabase.CreateAsset(material, Path.Combine("Assets", materialPath));

            scene = EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects, NewSceneMode.Single);
            EditorSceneManager.SaveScene(scene, Path.Combine("Assets", scenePath));
        }

        EditorGUILayout.ObjectField(shader, typeof(Shader), false);
        EditorGUILayout.ObjectField(material, typeof(Material), false);

        if (scene.IsValid())
        {
            EditorGUILayout.TextField(scene.name);
            if (GUILayout.Button("Open Scene"))
            {
                EditorSceneManager.OpenScene(scene.path, OpenSceneMode.Single);
            }
        }
    }
}
