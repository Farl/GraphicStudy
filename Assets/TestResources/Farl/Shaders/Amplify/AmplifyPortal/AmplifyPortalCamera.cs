using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class AmplifyPortalCamera : CommandBufferBehaviour {
    
    private AmplifyPortal[] _portals;
    private Transform _transform;
    private Material _maskMaterial;
    public Material _postFXMaterial;
    protected AmplifyPortalPlayer _player;

    protected override void Awake()
    {
        base.Awake();
        _transform = transform;
        _player = GetComponentInParent<AmplifyPortalPlayer>();
    }

    protected override void OnCreateCommandBuffer(CommandBufferSet cbs, int index)
    {
        CommandBuffer _buffer = cbs._buffer;

        if (_buffer != null)
        {
            if (index == 0)
            {
                _buffer.name = "ScreenCopy";

                // Screen copy
                int screenCopyID = Shader.PropertyToID("_ScreenCopy");
                _buffer.GetTemporaryRT(screenCopyID, -1, -1, 24, FilterMode.Bilinear, RenderTextureFormat.ARGBHalf);
                _buffer.Blit(BuiltinRenderTextureType.CurrentActive, screenCopyID);
                _buffer.SetGlobalTexture("ScreenCopy", screenCopyID);
            }
            else if (index == 1)
            {
                _buffer.name = "Portal";

                // Portal mask
                int portalMaskID = Shader.PropertyToID("_PortalMask");
                _buffer.GetTemporaryRT(portalMaskID, -1, -1, 24, FilterMode.Bilinear, RenderTextureFormat.ARGBHalf);
                _buffer.SetRenderTarget(portalMaskID);
                _buffer.ClearRenderTarget(false, true, Color.black);

                foreach (AmplifyPortal p in _portals)
                {
                    if (p)
                    {
                        Renderer ren = p.GetComponent<Renderer>();
                        if (ren)
                        {
                            _buffer.DrawRenderer(ren, _maskMaterial);
                        }
                    }
                }
                _buffer.SetGlobalTexture("PortalMask", portalMaskID);

                _buffer.ReleaseTemporaryRT(portalMaskID);
            }
        }
    }

    protected override void OnEnable()
    {
        _portals = FindObjectsOfType<AmplifyPortal>();

        if (_maskMaterial == null)
        {
            //_maskMaterial = new Material(Shader.Find("Unlit/Color"));
            _maskMaterial = new Material(Shader.Find("Custom/AmplifyPortalMask"));
        }

        base.OnEnable();
    }

    protected virtual void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, _postFXMaterial);
    }

    private Vector3 lastPosition;

    private void Update()
    {
        Vector3 currPosition = transform.position;
        Ray ray = new Ray(lastPosition, currPosition - lastPosition);
        RaycastHit hitInfo;
        if (Physics.Raycast(ray, out hitInfo, Vector3.Distance(currPosition, lastPosition)))
        {
            AmplifyPortal portal = hitInfo.collider.GetComponent<AmplifyPortal>();
            if (portal)
            {
                portal.Teleport(_player.transform);
            }
        }
        lastPosition = _transform.position;
    }
}
