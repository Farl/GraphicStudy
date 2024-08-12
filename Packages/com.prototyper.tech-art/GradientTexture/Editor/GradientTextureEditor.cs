using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System;
using System.Drawing.Drawing2D;
namespace SS
{
    [CustomEditor(typeof(GradientTexture))]
    public class GradientTextureEditor : Editor
    {
        // Static
        private static bool dynamicUpdate = false;

        private static Color BlendColor(Color c1, Color c2, GradientTexture.ColorBlendMode mode)
        {
            switch (mode)
            {
                default:
                case GradientTexture.ColorBlendMode.Multiply:
                    return c1 * c2;
                case GradientTexture.ColorBlendMode.Add:
                    return c1 + c2;
                case GradientTexture.ColorBlendMode.Subtract:
                    return c1 - c2;
                case GradientTexture.ColorBlendMode.Screen:
                    return Color.white - (Color.white - c1) * (Color.white - c2);
            }
        }

        private static void GenerateGradient(GradientTexture gt, Texture2D texture2D)
        {
            switch (gt.mode)
            {
                case GradientTexture.Mode.HorizontalAndVertical:
                    for (var j = 0; j < gt.targetHeight; j++)
                    {
                        for (var i = 0; i < gt.targetWidth; i++)
                        {
                            var hColor = gt.gradient1.Evaluate(i / (float)gt.targetWidth);
                            var vColor = gt.gradient2.Evaluate(j / (float)gt.targetHeight);
                            texture2D.SetPixel(i, j, BlendColor(hColor, vColor, gt.blendMode));
                        }
                    }
                    break;
                case GradientTexture.Mode.Radial:
                    var center = new Vector2(gt.targetWidth / 2, gt.targetHeight / 2);
                    var radius = Mathf.Min(gt.targetWidth, gt.targetHeight) / 2;
                    for (var j = 0; j < gt.targetHeight; j++)
                    {
                        for (var i = 0; i < gt.targetWidth; i++)
                        {
                            var p = new Vector2(i, j);
                            // Polar coordinates
                            var distance = Vector2.Distance(p, center);
                            var angle = Mathf.Atan2(p.y - center.y, p.x - center.x);
                            var Color1 = gt.gradient1.Evaluate(distance / radius);
                            var Color2 = gt.gradient2.Evaluate(Mathf.InverseLerp(-1, 1, angle / (1 * Mathf.PI)));
                            var color = BlendColor(Color1, Color2, gt.blendMode);
                            texture2D.SetPixel(i, j, color);
                        }
                    }
                    break;
                case GradientTexture.Mode.FourCorners:
                    for (var j = 0; j < gt.targetHeight; j++)
                    {
                        for (var i = 0; i < gt.targetWidth; i++)
                        {
                            var Color1 = gt.gradient1.Evaluate(i / (float)gt.targetWidth);
                            var Color2 = gt.gradient2.Evaluate(i / (float)gt.targetWidth);
                            var color = Color.Lerp(Color1, Color2, j / (float)gt.targetHeight);
                            texture2D.SetPixel(i, j, color);
                        }
                    }
                    break;
            }
        }
        
        private static void SetupTexture(GradientTexture gt)
        {
            if (gt == null)
                return;

            gt.targetWidth = Mathf.Max(1, gt.targetWidth);
            gt.targetHeight = Mathf.Max(1, gt.targetHeight);
            TextureFormat textureFormat = Enum.TryParse<TextureFormat>(gt.textureFormat.ToString(), out textureFormat) ? textureFormat : TextureFormat.RGBA32;

            Texture2D texture2D = new Texture2D(gt.targetWidth, gt.targetHeight, textureFormat, gt.generateMipMaps, gt.linear)
            {
                name = gt.name
            };
            GenerateGradient(gt, texture2D);
            texture2D.Apply();

            // Sprite
            Sprite sprite = null;
            if (gt.textureType == GradientTexture.TextureType.Sprite)
            {
                sprite = Sprite.Create(texture2D, new Rect(0, 0, texture2D.width, texture2D.height), Vector2.one * 0.5f);
                sprite.name = gt.name;
            }

            if (gt.outputFile)
            {
                byte[] bytes = texture2D.EncodeToPNG();
                var gtPath = AssetDatabase.GetAssetPath(gt);
                gtPath = gtPath.Replace(Path.GetExtension(gtPath), string.Empty);

                gt.outputPath = $"{gtPath}.png";
                var projectPath = (new DirectoryInfo(Application.dataPath)).Parent.ToString();
                File.WriteAllBytes(Path.Combine(projectPath, gt.outputPath), bytes);
                var asset = AssetDatabase.LoadAssetAtPath<Texture2D>(gtPath);
                if (asset)
                {
                    EditorUtility.SetDirty(asset);
                }
            }
            else
            {
                // Try replace into GradientTexture object
                bool replaced = false;
                var assets = AssetDatabase.LoadAllAssetsAtPath(AssetDatabase.GetAssetPath(gt));
                foreach (var asset in assets)
                {
                    switch (gt.textureType)
                    {
                        case GradientTexture.TextureType.Sprite:
                            if (asset is Sprite)
                            {
                                EditorUtility.CopySerialized(sprite, asset);
                                EditorUtility.SetDirty(asset);
                                gt.sprite = asset as Sprite;
                                replaced = true;
                            }
                            break;
                        default:
                            if (asset is Texture2D)
                            {
                                EditorUtility.CopySerialized(texture2D, asset);
                                EditorUtility.SetDirty(asset);
                                gt.texture2D = asset as Texture2D;
                                replaced = true;
                            }
                            break;
                    }
                    if (replaced)
                        break;
                }

                if (!replaced)
                {
                    switch (gt.textureType)
                    {
                        case GradientTexture.TextureType.Sprite:
                            gt.sprite = sprite;
                            AssetDatabase.AddObjectToAsset(gt.sprite, gt);
                            break;
                        default:
                            gt.texture2D = texture2D;
                            AssetDatabase.AddObjectToAsset(texture2D, gt);
                            break;
                    }
                }

                gt.outputPath = string.Empty;
                EditorUtility.SetDirty(gt);
            }
        }

        private static void DestroyAssetsInside<T>(UnityEngine.Object obj, params T[] ignoreObjs) where T : UnityEngine.Object
        {
            if (obj == null)
                return;
            var assets = AssetDatabase.LoadAllAssetsAtPath(AssetDatabase.GetAssetPath(obj));
            foreach (var asset in assets)
            {
                if (asset is T && !System.Array.Exists(ignoreObjs, e => e == asset))
                {
                    Debug.Log($"Destroy '{asset.name}' in {obj.name}");
                    DestroyImmediate(asset, true);
                }
            }
            EditorUtility.SetDirty(obj);
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
                    foreach (GradientTexture gt in targets)
                    {
                        SetupTexture(gt);
                    }
                    AssetDatabase.Refresh();
                }
            }


            if (GUILayout.Button("Create Texture"))
            {
                foreach (GradientTexture gt in targets)
                {
                    SetupTexture(gt);
                }
                AssetDatabase.Refresh();

                // Set texture asset importer
                foreach (GradientTexture gt in targets)
                {
                    if (gt == null)
                        continue;

                    if (string.IsNullOrEmpty(gt.outputPath))
                    {

                    }
                    else
                    {
                        var path = gt.outputPath;
                        var importer = AssetImporter.GetAtPath(path) as TextureImporter;
                        if (importer != null)
                        {
                            switch (gt.textureType)
                            {
                                case GradientTexture.TextureType.NormalMap:
                                    importer.textureType = TextureImporterType.NormalMap;
                                    break;
                                case GradientTexture.TextureType.Sprite:
                                    importer.textureType = TextureImporterType.Sprite;
                                    break;
                                default:
                                    importer.textureType = TextureImporterType.Default;
                                    break;
                            }
                            importer.isReadable = true;
                            importer.wrapMode = TextureWrapMode.Clamp;
                            // Check if texture has alpha channel
                            if (gt.texture2D != null)
                            {
                                importer.alphaIsTransparency = gt.texture2D.alphaIsTransparency;
                            }
                            var settings = importer.GetDefaultPlatformTextureSettings();
                            if (settings != null)
                            {
                                settings.overridden = true;
                                switch (gt.textureType)
                                {
                                    default:
                                        settings.format = TextureImporterFormat.RGBA32;
                                        break;
                                    case GradientTexture.TextureType.NormalMap:
                                        settings.format = TextureImporterFormat.RGBA32;
                                        break;
                                }
                                //settings.maxTextureSize = 128;
                            }
                            importer.SetPlatformTextureSettings(settings);
                        }
                        else
                        {
                            Debug.LogError($"Failed to get TextureImporter at {path}");
                        }
                        gt.texture2D = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
                    }
                    EditorUtility.SetDirty(gt);
                    AssetDatabase.SaveAssetIfDirty(gt);
                }
                AssetDatabase.Refresh();
            }

            if (GUILayout.Button("Clear embeded isolated assets"))
            {
                // Prompt to delete
                var result = EditorUtility.DisplayDialog("Clear Embeded Assets", "Are you sure to clear embeded isolated assets?", "Yes", "No");
                if (result)
                {
                    foreach (GradientTexture gt in targets)
                    {
                        DestroyAssetsInside<Texture2D>(gt, gt.texture2D);
                        DestroyAssetsInside<Sprite>(gt, gt.sprite);
                        gt.outputPath = string.Empty;
                        EditorUtility.SetDirty(gt);
                        AssetDatabase.SaveAssetIfDirty(gt);
                    }
                    AssetDatabase.Refresh();
                }
            }
        }
    }
}
