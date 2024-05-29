using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Serialization;

namespace SS
{
    [CreateAssetMenu(fileName ="GradientTexture2D", menuName ="SS/Gradient Texture", order = 1)]
    public class GradientTexture : ScriptableObject
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

        public enum ColorBlendMode
        {
            Multiply,
            Add,
            Subtract,
            // Divide,
            Screen,
            // Overlay,
            // SoftLight,
            // HardLight,
            // ColorDodge,
            // ColorBurn,
            // Darken,
            // Lighten,
            // Difference,
            // Exclusion,
            // Hue,
            // Saturation,
            // Color,
            // Luminosity
        }

        public enum Mode
        {
            HorizontalAndVertical,
            Radial,
            FourCorners
        }

        [Header("Gradient Settings")]
        public Mode mode = Mode.HorizontalAndVertical;

        [FormerlySerializedAs("gradientHorizontal")]
        public Gradient gradient1 = new Gradient();
        [FormerlySerializedAs("gradientVertical")]
        public Gradient gradient2 = new Gradient();
        public ColorBlendMode blendMode = ColorBlendMode.Multiply;

        [Header("Texture Settings")]
        public int targetWidth = 128;
        public int targetHeight = 1;
        public SupportTextureFormat textureFormat = SupportTextureFormat.RGBA32;
        public bool generateMipMaps = true;
        public bool linear = true;

        [Header("Output")]
        public Texture2D texutre2D;
        public bool outputFile = false;
        public string outputPath;
    }
}
