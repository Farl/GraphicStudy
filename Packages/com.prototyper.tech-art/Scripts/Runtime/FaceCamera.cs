using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SS
{
    public class FaceCamera : MonoBehaviour
    {
        [SerializeField] private bool useAxis;
        public enum Axis
        {
            X,
            Y,
            Z,
            MINUS_X,
            MINUS_Y,
            MINUS_Z
        }
        [SerializeField] public Transform axisTransform;
        [SerializeField] public Axis axis = Axis.Y;
        [SerializeField] private bool rotateByAxis = false;
        
        private Transform _cachedTransform;
        public Transform cachedTransform
        {
            get
            {
                if (_cachedTransform == null)
                {
                    _cachedTransform = transform;
                }
                return _cachedTransform;
            }
        }
        private Transform _cameraTransform;
        public Transform cameraTransform
        {
            get
            {
                if (_cameraTransform == null)
                {
                    if (Camera.main != null)
                        _cameraTransform = Camera.main.transform;
                }
                return _cameraTransform;
            }
        }

        public virtual void Update()
        {
            if (cachedTransform == null || cameraTransform == null)
            {
                return;
            }
            if (!useAxis)
            {
                cachedTransform.rotation = cameraTransform.rotation;
            }
            else
            {
                var lookVec = cachedTransform.position - cameraTransform.position;
                Vector3 axisVec = Vector3.up;
                if (axisTransform != null)
                {
                    axisVec = axisTransform.up;
                    switch (axis)
                    {
                        case Axis.X:
                            axisVec = axisTransform.right;
                            break;
                        case Axis.Y:
                            axisVec = axisTransform.up;
                            break;
                        case Axis.Z:
                            axisVec = axisTransform.forward;
                            break;
                        case Axis.MINUS_X:
                            axisVec = -axisTransform.right;
                            break;
                        case Axis.MINUS_Y:
                            axisVec = -axisTransform.up;
                            break;
                        case Axis.MINUS_Z:
                            axisVec = -axisTransform.forward;
                            break;
                    }
                }
                else
                {
                    axisVec = Vector3.up;
                    switch (axis)
                    {
                        case Axis.X:
                            axisVec = Vector3.right;
                            break;
                        case Axis.Y:
                            axisVec = Vector3.up;
                            break;
                        case Axis.Z:
                            axisVec = Vector3.forward;
                            break;
                        case Axis.MINUS_X:
                            axisVec = -Vector3.right;
                            break;
                        case Axis.MINUS_Y:
                            axisVec = -Vector3.up;
                            break;
                        case Axis.MINUS_Z:
                            axisVec = -Vector3.forward;
                            break;
                    }
                }
                if (rotateByAxis)
                {
                    lookVec = Vector3.ProjectOnPlane(lookVec, axisVec);
                }
                var lookAtPos = cachedTransform.position + lookVec;
                cachedTransform.LookAt(lookAtPos, axisVec);
            }
        }
    }
}
