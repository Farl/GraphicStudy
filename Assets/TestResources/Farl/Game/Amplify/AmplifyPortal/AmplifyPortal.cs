using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;

//[ExecuteAlways]
public class AmplifyPortal : MonoBehaviour {

    private Transform _transform;
    public Transform _targetTransform;
    private Camera _camera;
    private Transform _cameraTrans;
    private Transform _cameraRootTrans;
    private RenderTexture _renderTexture;
    public RenderTexture _portalCameraRT;

    private Camera _mainCam;
    private Transform _mainCamTrans;
    private Matrix4x4 _offsetMatrix;

    private int widthScale = 1;

    private void OnDestroy()
    {
        if (_renderTexture)
        {
            DestroyImmediate(_renderTexture);
        }
        if (_camera)
        {
            DestroyImmediate(_camera.gameObject);
        }
        if (_cameraRootTrans)
        {
            DestroyImmediate(_cameraRootTrans.gameObject);
        }
    }

    private void LateUpdate()
    {
        widthScale = ((UnityEngine.XR.XRSettings.enabled) ? 2 : 1);

        if (_transform == null)
        {
            _transform = transform;
        }
        if (_renderTexture == null)
        {
            _renderTexture = new RenderTexture(Screen.width * widthScale, Screen.height, 24, RenderTextureFormat.ARGBHalf);
            _renderTexture.hideFlags = HideFlags.DontSave;
            _renderTexture.wrapMode = TextureWrapMode.Repeat;
            _renderTexture.name = name + "~" + ((_targetTransform)?_targetTransform.name: "");
            _renderTexture.vrUsage = VRTextureUsage.TwoEyes;
            _renderTexture.SetGlobalShaderProperty("Portal");
        }
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
            if (_portalCameraRT)
            {
                _camera.targetTexture = _portalCameraRT;
            }
            else
            {
                _camera.targetTexture = _renderTexture;
            }

            _camera.depth = -2;
            camGO.AddComponent<AmplifyPortalTargetCamera>();
        }
        if (_mainCam == null)
        {
            AmplifyPortalCamera apc = FindObjectOfType<AmplifyPortalCamera>();
            _mainCam = apc.GetComponent<Camera>();
            _mainCamTrans = _mainCam.transform;
        }
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
