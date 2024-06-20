using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class MipMapBiasEditor : EditorWindow
{
    [MenuItem("Assets/SS TechArt/Edit Mip Map Bias")]
    public static void Open()
    {
        MipMapBiasEditor window = (MipMapBiasEditor)EditorWindow.GetWindow(typeof(MipMapBiasEditor));
        window.Show();
    }

    private void OnGUI()
    {
        // Get all selection Textures, and show them and their mip map bias.
        // You can also editor bias value here.
        Object[] textures = Selection.GetFiltered(typeof(Texture), SelectionMode.Assets);
        foreach (Object texture in textures)
        {
            TextureImporter importer = AssetImporter.GetAtPath(AssetDatabase.GetAssetPath(texture)) as TextureImporter;
            if (importer != null)
            {
                EditorGUILayout.LabelField(texture.name);
                EditorGUILayout.BeginHorizontal();
                // Show object reference
                EditorGUILayout.ObjectField(texture, typeof(Texture), false);
                importer.mipMapBias = EditorGUILayout.FloatField(importer.mipMapBias);
                EditorGUILayout.EndHorizontal();
            }
        }
    }
}
