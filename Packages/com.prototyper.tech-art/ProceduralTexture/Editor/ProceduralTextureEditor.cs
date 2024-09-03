using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace SS
{
    [CustomEditor(typeof(ProceduralTexture), editorForChildClasses: true)]
    public class ProceduralTextureEditor : Editor
    {
        // Static
        private static bool dynamicUpdate = false;

        // Draw preview window
        public override bool HasPreviewGUI()
        {
            return true;
        }

        public override void OnPreviewGUI(Rect r, GUIStyle background)
        {
            ProceduralTexture pTex = target as ProceduralTexture;
            if (pTex != null)
            {
                if (pTex.texture2D != null)
                {
                    Texture2D tex = pTex.texture2D;
                    if (tex != null)
                    {
                        EditorGUI.DrawPreviewTexture(r, tex, null, ScaleMode.ScaleToFit);
                    }
                }
                else if (pTex.sprite != null)
                {
                    Sprite sprite = pTex.sprite;
                    if (sprite != null)
                    {
                        EditorGUI.DrawPreviewTexture(r, sprite.texture, null, ScaleMode.ScaleToFit);
                    }
                }
                else
                {
                    EditorGUI.LabelField(r, "No texture");
                }
            }
        }


        public override void OnInspectorGUI()
        {
            // Draw dynamic update
            dynamicUpdate = EditorGUILayout.Toggle("Dynamic Update", dynamicUpdate);

            EditorGUILayout.Separator();

            // Draw default inspector
            EditorGUI.BeginChangeCheck();
            base.OnInspectorGUI();
            if (EditorGUI.EndChangeCheck())
            {
                if (dynamicUpdate)
                {
                    foreach (ProceduralTexture pTex in targets)
                    {
                        pTex.SetupTexture();
                    }
                    AssetDatabase.Refresh();
                }
            }

            // Create texture
            if (GUILayout.Button("Create"))
            {
                foreach (ProceduralTexture pTex in targets)
                {
                    pTex.SetupTexture();
                }
                AssetDatabase.Refresh();

                // Set texture asset importer
                foreach (ProceduralTexture pTex in targets)
                {
                    pTex.SetupImportSettings();
                }
                AssetDatabase.Refresh();
            }

            // Clear assets
            if (GUILayout.Button("Clear embeded isolated assets"))
            {
                // Prompt to delete
                var result = EditorUtility.DisplayDialog("Clear Embeded Assets", "Are you sure to clear embeded isolated assets?", "Yes", "No");
                if (result)
                {
                    foreach (ProceduralTexture pTex in targets)
                    {
                        pTex.ClearIsoletedAssets();
                    }
                    AssetDatabase.Refresh();
                }
            }
        }

    }

}
