using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace SS
{
    [CreateAssetMenu(fileName ="GradientTexture2D", menuName ="SS/Gradient Texture", order = 1)]
    public class GradientTexture : ProceduralTexture
    {
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
        [SerializeField] public Mode mode = Mode.HorizontalAndVertical;

        [FormerlySerializedAs("gradientHorizontal")]
        [SerializeField] public Gradient gradient1 = new Gradient();
        [FormerlySerializedAs("gradientVertical")]
        [SerializeField] public Gradient gradient2 = new Gradient();
        [SerializeField] public ColorBlendMode blendMode = ColorBlendMode.Multiply;

#if UNITY_EDITOR

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

        protected override void GenerateTexture(Texture2D texture2D)
        {
            GradientTexture gt = this;
            switch (gt.mode)
            {
                case Mode.HorizontalAndVertical:
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
                case Mode.Radial:
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
                case Mode.FourCorners:
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
#endif
    }
}
