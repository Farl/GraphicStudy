using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class CommandBufferBehaviour : MonoBehaviour {

    [System.Serializable]
    public class CommandBufferSet
    {
        private Camera _camera;
        public CameraEvent _cameraEvent;
        private CameraEvent _prevCameraEvent;
        public CommandBuffer _buffer;

        public CommandBufferSet(CameraEvent camEvent)
        {
            _cameraEvent = camEvent;
        }

        public void Create(Camera cam)
        {
            if (_camera == null)
            {
                _camera = cam;
                if (_camera)
                {
                    _buffer = new CommandBuffer();
                    _camera.AddCommandBuffer(_cameraEvent, _buffer);
                    _prevCameraEvent = _cameraEvent;
                }
            }
        }

        public void Clear()
        {
            if (_camera && _buffer != null)
            {
                _camera.RemoveCommandBuffer(_prevCameraEvent, _buffer);
            }
        }
    }

    public List<CommandBufferSet> commandBufferSet = new List<CommandBufferSet>();

    protected Camera _camera;

    // Use this for initialization
    protected virtual void Awake()
    {
        _camera = GetComponent<Camera>();
    }

    protected virtual void OnDisable()
    {
        if (_camera)
        {
            foreach (CommandBufferSet cbs in commandBufferSet)
            {
                cbs.Clear();
            }
        }
    }

    protected virtual void OnCreateCommandBuffer(CommandBufferSet cbs, int index)
    {
    }

    protected virtual void OnEnable()
    {
        int index = 0;
        foreach (CommandBufferSet cbs in commandBufferSet)
        {
            cbs.Create(_camera);
            OnCreateCommandBuffer(cbs, index);
            index++;
        }
    }
}
