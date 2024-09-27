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
            // Separate rect to draw image and draw alpha channel
            Rect r1 = new Rect(r.x, r.y, r.width / 2, r.height);
            Rect r2 = new Rect(r.x + r.width / 2, r.y, r.width / 2, r.height);
            if (pTex != null)
            {
                if (pTex.texture2D != null)
                {
                    Texture2D tex = pTex.texture2D;
                    if (tex != null)
                    {
                        EditorGUI.DrawPreviewTexture(r1, tex, null, ScaleMode.ScaleToFit);
                        EditorGUI.DrawTextureAlpha(r2, tex, ScaleMode.ScaleToFit);
                    }
                    else
                    {
                        EditorGUI.LabelField(r, "No Texture2D");
                    }
                }
                else if (pTex.sprite != null)
                {
                    Sprite sprite = pTex.sprite;
                    if (sprite != null && sprite.texture != null)
                    {
                        // Draw transparent sprite
                        Texture2D tex = sprite.texture;
                        EditorGUI.DrawPreviewTexture(r1, tex, null, ScaleMode.ScaleToFit);
                        EditorGUI.DrawTextureAlpha(r2, tex, ScaleMode.ScaleToFit);
                    }
                    else
                    {
                        EditorGUI.LabelField(r, "No Sprite");
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
