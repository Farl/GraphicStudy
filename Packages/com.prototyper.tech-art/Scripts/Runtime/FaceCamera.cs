using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.PlayerLoop;

namespace SS
{
    public class FaceCamera : MonoBehaviour
    {
        #region Enums / Classes

        public enum Axis
        {
            X,
            Y,
            Z,
            MINUS_X,
            MINUS_Y,
            MINUS_Z
        }

        public enum UpdateMethod
        {
            Update,
            LateUpdate,
            FixedUpdate,
            Manual
        }

        #endregion

        #region Insepctor
        [SerializeField] private bool useAxis;
        [SerializeField] public Transform axisTransform;
        [SerializeField] public Axis axis = Axis.Y;
        [SerializeField] private bool rotateByAxis = false;
        [SerializeField] private UpdateMethod updateMethod = UpdateMethod.Update;

        #endregion

        #region Public
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

        public virtual void DoFace()
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
        #endregion

        #region Private / Protected
        private Transform _cachedTransform;
        private Transform _cameraTransform;
        protected void Update()
        {
            if (updateMethod != UpdateMethod.Update)
            {
                return;
            }
            DoFace();
        }
        protected void LateUpdate()
        {
            if (updateMethod != UpdateMethod.LateUpdate)
            {
                return;
            }
            DoFace();
        }
        protected void FixedUpdate()
        {
            if (updateMethod != UpdateMethod.FixedUpdate)
            {
                return;
            }
            DoFace();
        }
        #endregion


    }
}
