using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteAlways]
public class AmplifyPortalTargetCamera : CommandBufferBehaviour {

    private string _globalTextureName;
    public void Setup(CameraEvent cameraEvent, string globalTextureName)
    {
        _globalTextureName = globalTextureName;
        commandBufferSet.Add(new CommandBufferSet(cameraEvent));
        this.enabled = false;
        this.enabled = true;
    }

    protected override void OnCreateCommandBuffer(CommandBufferSet cbs, int index)
    {
        CommandBuffer _buffer = cbs._buffer;

        if (_buffer != null)
        {
            if (index == 0)
            {
                _buffer.name = "PortalCameraCopy";

                // Screen copy to global texture
                int tempRTID = Shader.PropertyToID("_PortalCameraCopy");
                _buffer.GetTemporaryRT(tempRTID, -1, -1, 0, FilterMode.Bilinear, RenderTextureFormat.ARGBHalf);
                _buffer.Blit(BuiltinRenderTextureType.CurrentActive, tempRTID);
                _buffer.SetGlobalTexture(_globalTextureName, tempRTID);
            }
        }
    }
}
