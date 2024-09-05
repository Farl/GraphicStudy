using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SS
{
    [ExecuteAlways]
    public class OnRenderImageEffect : MonoBehaviour
    {
        // A Material with the Unity shader you want to process the image with
        [SerializeField] public Material mat;
        [SerializeField] private bool executeAlways = false;


        void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            if (mat == null || !executeAlways && !Application.isPlaying)
            {
                Graphics.Blit(src, dest);
                return;
            }

            // Read pixels from the source RenderTexture, apply the material, copy the updated results to the destination RenderTexture
            Graphics.Blit(src, dest, mat);
        }
    }
}
