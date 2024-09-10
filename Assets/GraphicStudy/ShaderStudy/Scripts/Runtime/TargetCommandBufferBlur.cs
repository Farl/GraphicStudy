using UnityEngine;
using UnityEngine.Rendering;
using System.Collections.Generic;

// See _ReadMe.txt for an overview
[ExecuteInEditMode]
public class TargetCommandBufferBlur : CommandBufferSetup
{
	[SerializeField] public Shader blurShader;
	[SerializeField] private Material blurMaterial;
	[SerializeField] public Material maskMaterial;
	[SerializeField] private string maskTextureProperty = "_MaskTex";
	[SerializeField] private string grabBlurTextureProperty = "_GrabBlurTexture";

	// Remove command buffers from all cameras we added into
	public override void Cleanup()
	{
		base.Cleanup ();
		Object.DestroyImmediate (blurMaterial);
	}

	// Whenever any camera will render us, add a command buffer to do the work on it
	protected override void SetupCommandBuffer(CommandBuffer buf)
	{
		if (!blurMaterial && blurShader)
		{
			blurMaterial = new Material(blurShader);
			blurMaterial.hideFlags = HideFlags.HideAndDontSave;
		}

		List<Renderer> rendererList = CollectRenderer ();

		if (!blurMaterial)
			return;
		if (!maskMaterial)
			return;

		// copy screen into temporary RT
		int screenCopyID = Shader.PropertyToID("_ScreenCopyTexture");
        int maskID = Shader.PropertyToID("_MaskRT");
        int maskID2 = Shader.PropertyToID("_MaskRT2");

        buf.GetTemporaryRT (screenCopyID, -1, -1, 0, FilterMode.Bilinear);
        buf.GetTemporaryRT(maskID, -1, -1, 32, FilterMode.Bilinear, RenderTextureFormat.ARGBHalf);
        buf.GetTemporaryRT(maskID2, -1, -1, 0, FilterMode.Bilinear);

        buf.Blit(BuiltinRenderTextureType.CurrentActive, screenCopyID);
        buf.Blit(BuiltinRenderTextureType.CurrentActive, maskID);

        // get two smaller RTs
        int blurredID = Shader.PropertyToID("_Temp1");
		int blurredID2 = Shader.PropertyToID("_Temp2");
		buf.GetTemporaryRT (blurredID, -2, -2, 0, FilterMode.Bilinear);
		buf.GetTemporaryRT (blurredID2, -2, -2, 0, FilterMode.Bilinear);
		
		// downsample screen copy into smaller RT, release screen RT
		buf.Blit (screenCopyID, blurredID);
		buf.ReleaseTemporaryRT (screenCopyID); 
		
		// horizontal blur
		buf.SetGlobalVector("offsets", new Vector4(2,0,0,0));
		buf.Blit (blurredID, blurredID2, blurMaterial);
		// vertical blur
		buf.SetGlobalVector("offsets", new Vector4(0,2,0,0));
		buf.Blit (blurredID2, blurredID, blurMaterial);
		// horizontal blur
		buf.SetGlobalVector("offsets", new Vector4(4,0,0,0));
		buf.Blit (blurredID, blurredID2, blurMaterial);
		// vertical blur
		buf.SetGlobalVector("offsets", new Vector4(0,4,0,0));
		buf.Blit (blurredID2, blurredID, blurMaterial);

		buf.SetGlobalTexture(grabBlurTextureProperty, blurredID);

        buf.ReleaseTemporaryRT(blurredID2);

        // Draw mask

        buf.SetRenderTarget (maskID);

		// clear render texture before drawing to it each frame!!
		buf.ClearRenderTarget(false, true, new Color(0, 0, 0, 0));

		foreach (Renderer r in rendererList) {
			int i = 0;
			foreach (Material m in r.sharedMaterials) {
				buf.DrawRenderer (r, maskMaterial, i, -1);
				i++;
			}
		}

		buf.SetGlobalVector("offsets", new Vector4(4,0,0,0));
		buf.Blit (maskID, maskID2, blurMaterial);
		buf.SetGlobalVector("offsets", new Vector4(0,4,0,0));
		buf.Blit (maskID2, maskID, blurMaterial);
		buf.SetGlobalTexture(maskTextureProperty, maskID);

        buf.ReleaseTemporaryRT(maskID2);
	}	
}
