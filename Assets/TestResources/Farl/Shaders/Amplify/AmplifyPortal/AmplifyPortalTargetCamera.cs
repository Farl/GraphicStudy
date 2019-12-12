using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class AmplifyPortalTargetCamera : CommandBufferBehaviour {

    protected override void Awake()
    {
        //commandBufferSet.Add(new CommandBufferSet(CameraEvent.AfterSkybox));
        base.Awake();
    }

    protected override void OnCreateCommandBuffer(CommandBufferSet cbs, int index)
    {
        CommandBuffer _buffer = cbs._buffer;

        if (_buffer != null)
        {
            if (index == 0)
            {
                _buffer.name = "PortalCameraCopy";

                // Screen copy
                int screenCopyID = Shader.PropertyToID("_PortalCameraCopy");
                _buffer.GetTemporaryRT(screenCopyID, -1, -1, 24, FilterMode.Bilinear, RenderTextureFormat.ARGBHalf);
                _buffer.Blit(BuiltinRenderTextureType.CurrentActive, screenCopyID);
                _buffer.SetGlobalTexture("_PortalCameraCopy", screenCopyID);
            }
        }
    }
}
