using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
#if UNITY_EDITOR
using UnityEditor;
using System.IO;
#endif

namespace SS
{
    public abstract class ProceduralTexture : ScriptableObject
    {
        // https://docs.unity3d.com/ScriptReference/Texture2D.SetPixel.html
        // You can use SetPixel with the following texture formats:
        // Alpha8
        // ARGB32
        // ARGB4444
        // BGRA32
        // R16
        // R8
        // RFloat
        // RG16
        // RG32
        // RGB24
        // RGB48
        // RGB565
        // RGB9e5Float
        // RGBA32
        // RGBA4444
        // RGBA64
        // RGBAFloat
        // RGBAHalf
        // RGFloat
        // RGHalf
        // RHalf
        public enum SupportTextureFormat
        {
            Alpha8,
            ARGB32,
            ARGB4444,
            BGRA32,
            R16,
            R8,
            RFloat,
            RG16,
            RG32,
            RGB24,
            RGB48,
            RGB565,
            RGB9e5Float,
            RGBA32,
            RGBA4444,
            RGBA64,
            RGBAFloat,
            RGBAHalf,
            RGFloat,
            RGHalf,
            RHalf
        }

        public enum TextureType
        {
            Default,
            NormalMap,
            Sprite
        }

        [Header("Texture Settings")]
        [SerializeField] public int targetWidth = 128;
        [SerializeField] public int targetHeight = 128;
        [SerializeField] public SupportTextureFormat textureFormat = SupportTextureFormat.RGBAHalf;
        [SerializeField] public bool generateMipMaps = true;
        [SerializeField] public bool linear = true;

        [Header("Output Settings")]
        [SerializeField] public Texture2D texture2D;
        [SerializeField] public Sprite sprite;
        [SerializeField] public Vector4 border = new Vector4(0, 0, 0, 0);
        [SerializeField] public bool outputFile = false;
        [SerializeField] public TextureType textureType = TextureType.Default;
        [SerializeField] public string outputPath;

        public TextureFormat TextureFormat
        {
            get
            {
                return Enum.TryParse<TextureFormat>(this.textureFormat.ToString(), out TextureFormat textureFormat) ? textureFormat : TextureFormat.RGBAHalf;
            }
        }

        protected virtual void GenerateTexture(Texture2D texture2D)
        {

        }

#if UNITY_EDITOR

        public void SetupTexture()
        {
            targetWidth = Mathf.Max(1, targetWidth);
            targetHeight = Mathf.Max(1, targetHeight);

            Texture2D texture2D = new Texture2D(targetWidth, targetHeight, TextureFormat, this.generateMipMaps, this.linear)
            {
                name = this.name
            };
            GenerateTexture(texture2D);
            texture2D.Apply();

            // Sprite
            Sprite sprite = null;
            if (this.textureType == TextureType.Sprite)
            {
                sprite = Sprite.Create(texture2D, new Rect(0, 0, texture2D.width, texture2D.height),
                    pivot: Vector2.one * 0.5f,
                    pixelsPerUnit: 100.0f,
                    extrude: 0,
                    meshType: SpriteMeshType.FullRect,
                    border: this.border
                );
                sprite.name = this.name;

            }

            if (this.outputFile)
            {
                byte[] bytes = texture2D.EncodeToPNG();
                var gtPath = AssetDatabase.GetAssetPath(this);
                gtPath = gtPath.Replace(Path.GetExtension(gtPath), string.Empty);

                this.outputPath = $"{gtPath}.png";
                var projectPath = (new DirectoryInfo(Application.dataPath)).Parent.ToString();
                File.WriteAllBytes(Path.Combine(projectPath, this.outputPath), bytes);
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
                var assets = AssetDatabase.LoadAllAssetsAtPath(AssetDatabase.GetAssetPath(this));
                foreach (var asset in assets)
                {
                    switch (this.textureType)
                    {
                        case TextureType.Sprite:
                            if (asset is Sprite)
                            {
                                EditorUtility.CopySerialized(sprite, asset);
                                EditorUtility.SetDirty(asset);
                                this.sprite = asset as Sprite;
                                replaced = true;
                            }
                            break;
                        default:
                            if (asset is Texture2D)
                            {
                                EditorUtility.CopySerialized(texture2D, asset);
                                EditorUtility.SetDirty(asset);
                                this.texture2D = asset as Texture2D;
                                replaced = true;
                            }
                            break;
                    }
                    if (replaced)
                        break;
                }

                if (!replaced)
                {
                    switch (this.textureType)
                    {
                        case TextureType.Sprite:
                            this.sprite = sprite;
                            AssetDatabase.AddObjectToAsset(this.sprite, this);
                            break;
                        default:
                            this.texture2D = texture2D;
                            AssetDatabase.AddObjectToAsset(texture2D, this);
                            break;
                    }
                }

                this.outputPath = string.Empty;
                EditorUtility.SetDirty(this);
            }
        }

        public void SetupImportSettings()
        {
            ProceduralTexture gt = this;

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
                        case TextureType.NormalMap:
                            importer.textureType = TextureImporterType.NormalMap;
                            break;
                        case TextureType.Sprite:
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
                            case TextureType.NormalMap:
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

        // Clear embeded isolated assets
        public void ClearIsoletedAssets()
        {
            ProceduralTexture pTex = this;
            DestroyAssetsInside<Texture2D>(pTex, pTex.texture2D);
            DestroyAssetsInside<Sprite>(pTex, pTex.sprite);
            pTex.outputPath = string.Empty;
            EditorUtility.SetDirty(pTex);
            AssetDatabase.SaveAssetIfDirty(pTex);
        }

        public static void DestroyAssetsInside<T>(UnityEngine.Object obj, params T[] ignoreObjs) where T : UnityEngine.Object
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
#endif
    }
}
