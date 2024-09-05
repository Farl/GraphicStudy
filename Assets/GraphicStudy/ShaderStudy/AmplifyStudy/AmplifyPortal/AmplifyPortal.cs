using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;
using UnityEngine.Rendering;

[ExecuteAlways]
public class AmplifyPortal : MonoBehaviour {

    [SerializeField] public Transform _targetTransform;
    private Transform _transform;
    private Camera _camera;
    private Transform _cameraTrans;
    private Transform _cameraRootTrans;
    private RenderTexture _renderTexture;

    private Camera _mainCam;
    private Transform _mainCamTrans;
    private Matrix4x4 _offsetMatrix;

    private int widthScale = 1;

    private void OnDestroy()
    {
        if (_camera)
        {
            _camera.targetTexture = null;
            DestroyImmediate(_camera.gameObject);
        }
        if (_cameraRootTrans)
        {
            DestroyImmediate(_cameraRootTrans.gameObject);
        }
        if (_renderTexture)
        {
            DestroyImmediate(_renderTexture);
        }
    }

    private void LateUpdate()
    {
        widthScale = XRSettings.enabled ? 2 : 1;

        if (_transform == null)
        {
            _transform = transform;
        }

        // Create portal camera
        if (_camera == null)
        {
            GameObject camRootGO = new GameObject(name + "_CameraRoot");
            camRootGO.hideFlags = HideFlags.DontSave;
            _cameraRootTrans = camRootGO.transform;

            GameObject camGO = new GameObject(name + "_Camera");
            camGO.hideFlags = HideFlags.DontSave;
            _cameraTrans = camGO.transform;
            _cameraTrans.SetParent(_cameraRootTrans, false);

            _camera = camGO.AddComponent<Camera>();

            // Create render texture as camera target
            if (_renderTexture == null)
            {
                _renderTexture = new RenderTexture(Screen.width * widthScale, Screen.height, 24, RenderTextureFormat.ARGBHalf);
                _renderTexture.hideFlags = HideFlags.DontSave;
                _renderTexture.wrapMode = TextureWrapMode.Repeat;
                _renderTexture.name = name + "~" + (_targetTransform ? _targetTransform.name : "");
                _renderTexture.vrUsage = VRTextureUsage.TwoEyes;
                _renderTexture.SetGlobalShaderProperty("_Portal");
            }
            _camera.targetTexture = _renderTexture;

            _camera.depth = -2;
            var comp = camGO.AddComponent<AmplifyPortalTargetCamera>();
            if (comp)
            {
                comp.Setup(CameraEvent.AfterForwardOpaque, "_PortalCameraCopy");
            }
        }
        if (_mainCam == null)
        {
            AmplifyPortalCamera apc = FindObjectOfType<AmplifyPortalCamera>();
            _mainCam = apc.GetComponent<Camera>();
            _mainCamTrans = _mainCam.transform;
        }

        // Calculate portal camera transform
        if (_camera)
        {
            if (_mainCam)
            {
                _camera.aspect = (Screen.width / (float)widthScale) / Screen.height;
                _camera.fieldOfView = _mainCam.fieldOfView;
                _camera.nearClipPlane = _mainCam.nearClipPlane;
                _camera.farClipPlane = _mainCam.farClipPlane;

                if (XRSettings.enabled)
                {
                    _offsetMatrix = Matrix4x4.Inverse(_transform.localToWorldMatrix) * _mainCamTrans.parent.localToWorldMatrix;
                }
                else
                {
                    _offsetMatrix = Matrix4x4.Inverse(_transform.localToWorldMatrix) * _mainCamTrans.localToWorldMatrix;
                }

            }
            if (_cameraTrans)
            {
                Matrix4x4 m = _targetTransform.localToWorldMatrix * _offsetMatrix;

                if (XRSettings.enabled)
                {
                    _cameraRootTrans.SetPositionAndRotation(m.MultiplyPoint3x4(Vector3.zero), m.rotation);
                    _cameraTrans.localPosition = InputTracking.GetLocalPosition(XRNode.LeftEye);
                    _cameraTrans.localRotation = InputTracking.GetLocalRotation(XRNode.LeftEye);
                }
                else
                {
                    _cameraTrans.SetPositionAndRotation(m.MultiplyPoint3x4(Vector3.zero), m.rotation);
                }
            }

        }
    }

    public void Teleport(Transform target)
    {
        if (target && _targetTransform)
        {
            _offsetMatrix = Matrix4x4.Inverse(_transform.localToWorldMatrix) * target.localToWorldMatrix;
            Matrix4x4 m = _targetTransform.localToWorldMatrix * _offsetMatrix;
            target.SetPositionAndRotation(m.MultiplyPoint3x4(Vector3.zero), m.rotation);
        }
    }
}
