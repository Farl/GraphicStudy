using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using UnityEngine;

namespace SS
{
    [CreateAssetMenu(fileName = "MaterialTexture2D", menuName = "SS/Material Texture", order = 2)]
    public class MaterialTexture : ProceduralTexture
    {
        [Header("Material Settings")]
        [SerializeField] private Material material;
        [Tooltip("Unlit shader pass = 0. Lit shader pass = -1")]
        [SerializeField] private int pass = -1;
        [SerializeField] private Texture inputTexture;
        protected override void GenerateTexture(Texture2D texture2D)
        {
            if (material == null)
            {
                Debug.LogError("Material is null");
                return;
            }
            // Blit material to texture
            var rt = RenderTexture.GetTemporary(texture2D.width, texture2D.height, 8, RenderTextureFormat.ARGBFloat, linear? RenderTextureReadWrite.Linear: RenderTextureReadWrite.sRGB);
            Graphics.Blit(inputTexture, rt, material, pass);
            
            // Read pixels from render texture
            RenderTexture.active = rt;
            texture2D.ReadPixels(new Rect(0, 0, texture2D.width, texture2D.height), 0, 0);
            texture2D.Apply();
            RenderTexture.active = null;
        }
    }
}
