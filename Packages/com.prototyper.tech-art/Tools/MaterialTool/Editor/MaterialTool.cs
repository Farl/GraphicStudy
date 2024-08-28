using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace SS
{

    public class MaterialTool : EditorWindow
    {
        private List<Material> materials = new List<Material>();

        [MenuItem("Tools/SS/Material Tool")]
        private static void Open()
        {
            var w = EditorWindow.GetWindow<MaterialTool>();
            w.titleContent = new GUIContent("Material Tool");
        }

        private void Clean(Material material)
        {
            if (!material)
                return;
            if (!material.shader)
                return;

            var so = new SerializedObject(material);

            System.Action<string> removeUselessProperties = (string path) =>
            {
                var properties = so.FindProperty(path);
                if (properties != null && properties.isArray)
                {
                    for (int j = properties.arraySize - 1; j >= 0; j--)
                    {
                        string propName = properties.GetArrayElementAtIndex(j).FindPropertyRelative("first").stringValue;
                        bool exists = material.HasProperty(propName);

                        if (!exists)
                        {
                            properties.DeleteArrayElementAtIndex(j);
                            so.ApplyModifiedProperties();
                        }
                    }
                }
            };

            removeUselessProperties("m_SavedProperties.m_TexEnvs");
            removeUselessProperties("m_SavedProperties.m_Ints");
            removeUselessProperties("m_SavedProperties.m_Floats");
            removeUselessProperties("m_SavedProperties.m_Colors");
        }


        private void OnGUI()
        {
            if (GUILayout.Button("Clean material properties"))
            {
                materials.Clear();
                var objs = Selection.objects;
                foreach (var obj in objs)
                {
                    var material = obj as Material;
                    if (material)
                    {
                        Clean(material);
                    }
                }
            }
        }
    }
}
