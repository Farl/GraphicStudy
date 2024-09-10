using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIDetail : BaseMeshEffect, IMaterialModifier
{
    private RectTransform _rectTransform;
    private RectTransform rectTransform
    {
        get
        {
            if (_rectTransform == null)
            {
                _rectTransform = GetComponent<RectTransform>();
            }
            return _rectTransform;
        }
    }

    public Material GetModifiedMaterial(Material baseMaterial)
    {
        return baseMaterial;
    }

    public override void ModifyMesh(VertexHelper vh)
    {
        // Add UV2 into UI vertex
        var vert = new UIVertex();
        var count = vh.currentVertCount;
        var rect = rectTransform.rect;

        // Define Remap function
        float Remap(float input, float inputMin, float inputMax, float outputMin, float outputMax)
        {
            var t = Mathf.InverseLerp(inputMin, inputMax, input);
            return Mathf.LerpUnclamped(outputMin, outputMax, t);
        }
        for (int i = 0; i < count; i++)
        {
            vh.PopulateUIVertex(ref vert, i);

            // Convert vertex position to texture coordinate UV1 (0-1)
            var newUV = rect.width < rect.height?
            new Vector2(
                Remap(vert.position.x, rect.yMin, rect.yMax, 0, 1),
                Remap(vert.position.y, rect.yMin, rect.yMax, 0, 1)
            ):
            new Vector2(
                Remap(vert.position.x, rect.xMin, rect.xMax, 0, 1),
                Remap(vert.position.y, rect.xMin, rect.xMax, 0, 1)
            );
            vert.uv2 = newUV;

            vh.SetUIVertex(vert, i);
        }

    }
}
