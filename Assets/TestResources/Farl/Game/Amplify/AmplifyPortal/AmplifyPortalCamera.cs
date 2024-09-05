using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteAlways]
public class AmplifyPortalCamera : CommandBufferBehaviour
{

    [SerializeField] private Shader maskShader;
    [SerializeField] public Material _postFXMaterial;
    [SerializeField] private Transform teleportTransform;
    [SerializeField] private string screenCopyPropertyName = "_ScreenCopy";
    [SerializeField] private string portalMaskPropertyName = "_PortalMask";

    private AmplifyPortal[] _portals;
    private Transform _transform;
    private Material _maskMaterial;
    protected AmplifyPortalPlayer _player;
    private Vector3 lastPosition;

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

                // Screen copy to global texture
                int screenCopyID = Shader.PropertyToID("_ScreenCopy");
                _buffer.GetTemporaryRT(screenCopyID, -1, -1, 24, FilterMode.Bilinear, RenderTextureFormat.ARGBHalf);
                _buffer.Blit(BuiltinRenderTextureType.CurrentActive, screenCopyID);
                _buffer.SetGlobalTexture(screenCopyPropertyName, screenCopyID);
            }
            else if (index == 1)
            {
                _buffer.name = "Portal";

                // Render portal renderer into Portal mask
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
                            if (_maskMaterial)
                            {
                                _buffer.DrawRenderer(ren, _maskMaterial);
                            }
                            else
                            {
                                _buffer.DrawRenderer(ren, ren.sharedMaterial);
                            }
                        }
                    }
                }
                _buffer.SetGlobalTexture(portalMaskPropertyName, portalMaskID);
            }
        }
    }

    protected override void OnEnable()
    {
        _portals = FindObjectsOfType<AmplifyPortal>();

        if (_maskMaterial == null && maskShader != null)
        {
            _maskMaterial = new Material(maskShader);
        }

        base.OnEnable();
    }

    protected virtual void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, _postFXMaterial);
    }

    private void Update()
    {
        if (!Application.isPlaying)
        {
            return;
        }
        Vector3 currPosition = transform.position;
        Ray ray = new Ray(lastPosition, currPosition - lastPosition);
        RaycastHit hitInfo;
        if (Physics.Raycast(ray, out hitInfo, Vector3.Distance(currPosition, lastPosition)))
        {
            AmplifyPortal portal = hitInfo.collider.GetComponent<AmplifyPortal>();
            if (portal)
            {
                portal.Teleport(teleportTransform? teleportTransform: _player.transform);
            }
        }
        lastPosition = _transform.position;
    }
}
