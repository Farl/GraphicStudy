using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.PlayerLoop;

namespace SS
{
    public class NumericSpring : MonoBehaviour
    {
        public enum InputParameter
        {
            DampingRatio,
            HalfLife
        }
        public enum SpringMethod
        {
            Implicit,
            SemiImplicit
        }
        [Flags]
        public enum SpringControl
        {
            Position = 1 << 0,
            Rotation = 1 << 1
        }

        [SerializeField] private SpringControl springControl = SpringControl.Position;
        [SerializeField] private SpringMethod springMethod = SpringMethod.Implicit;
        [SerializeField] private InputParameter inputParameter = InputParameter.DampingRatio;

        [SerializeField] private Transform controlTransform;
        [SerializeField] private Transform targetTransform;

        // Public variables for designers to tweak
        [SerializeField] public float oscillationFrequency = 2f; // Oscillations per second
        [Range(0f, 1f)]
        [SerializeField] public float dampingRatio = 0.9f; // Percentage of oscillation reduction per second
        [SerializeField] public float halfLife = 1f; // Half-life in seconds

        // Internal variables for the spring simulation
        private float omega; // Angular frequency (calculated from oscillationFrequency)
        private float zeta; // Damping ratio (calculated from dampingRatio)
        private float lambda; // half-life
        private Vector3 x; // Current postiion value
        private Vector3 v; // Current velocity
        private Vector3 xt; // Target position value
        // Rotation
        private Quaternion r;
        private Quaternion w;
        private Quaternion rt;

        private void UpdateRotation()
        {
            if ((springControl & SpringControl.Rotation) == 0)
            {
                return;
            }
            if (controlTransform == null || targetTransform == null)
            {
                return;
            }
            
            r = controlTransform.rotation;
            rt = targetTransform.rotation;

            // Call the Spring function to update r and w
            switch (springMethod)
            {
                case SpringMethod.Implicit:
                    ImplicitSpring(ref r, ref w, rt, zeta, omega, Time.deltaTime);
                    break;
                case SpringMethod.SemiImplicit:
                    SemiImplicitSpring(ref r, ref w, rt, zeta, omega, Time.deltaTime);
                    break;
            }

            // Use the updated r value (e.g., for position, rotation)
            // ... Your code to apply the spring simulation to a GameObject ...
            controlTransform.rotation = r;
        }

        private void UpdatePosition()
        {
            if ((springControl & SpringControl.Position) == 0)
            {
                return;
            }
            if (controlTransform == null || targetTransform == null)
            {
                return;
            }
            x = controlTransform.position;
            xt = targetTransform.position;

            // Call the Spring function to update x and v
            switch (springMethod)
            {
                case SpringMethod.Implicit:
                    ImplicitSpring(ref x, ref v, xt, zeta, omega, Time.deltaTime);
                    break;
                case SpringMethod.SemiImplicit:
                    SemiImplicitSpring(ref x, ref v, xt, zeta, omega, Time.deltaTime);
                    break;
            }

            // Use the updated x value (e.g., for position, rotation)
            // ... Your code to apply the spring simulation to a GameObject ... 
            controlTransform.position = x;
        }

        private void LateUpdate()
        {
            // Calculate omega  from designer-friendly parameters
            omega = 2f * Mathf.PI * oscillationFrequency;

            // Calculate zeta
            if (omega == 0f)
            {
                zeta = 0f;
            }
            else
            {
                switch (inputParameter)
                {
                    case InputParameter.DampingRatio:
                        if (dampingRatio >= 1f)
                        {
                            zeta = 1f;
                        }
                        else
                        {
                            zeta = -Mathf.Log(1f - dampingRatio) / omega;
                        }
                        break;
                    case InputParameter.HalfLife:
                        // Calculate lambda from half-life
                        lambda = halfLife;
                        if (lambda == 0f)
                        {
                            zeta = 0f;
                        }
                        else
                        {
                            zeta = -Mathf.Log(0.5f) / (omega * lambda);
                        }
                        break;
                }
            }

            UpdatePosition();
            UpdateRotation();
        }

        /** Implicit Euler method
         *  x = (f * x + h * v + h^2 * xt) / (1 + h^2 * omega^2)
         *  v = (v + h * omega^2 * (xt - x)) / (1 + h^2 * omega^2)
         */

        static void ImplicitSpring(ref Vector3 x, ref Vector3 v, Vector3 xt, float zeta, float omega, float h)
        {
            float f = 1.0f + 2.0f * h * zeta * omega;
            float oo = omega * omega;
            float hoo = h * oo;
            float hhoo = h * hoo;
            float detInv = 1.0f / (f + hhoo);
            var detX = f * x + h * v + hhoo * xt;
            var detV = v + hoo * (xt - x);
            x = detX * detInv;
            v = detV * detInv;
        }

        static void ImplicitSpring(ref float x, ref float v, float xt, float zeta, float omega, float h)
        {
            float f = 1.0f + 2.0f * h * zeta * omega;
            float oo = omega * omega;
            float hoo = h * oo;
            float hhoo = h * hoo;
            float detInv = 1.0f / (f + hhoo);
            var detX = f * x + h * v + hhoo * xt;
            var detV = v + hoo * (xt - x);
            x = detX * detInv;
            v = detV * detInv;
        }

        // Implicit Euler method for rotation (Qauternion)
        static void ImplicitSpring(ref Quaternion x, ref Quaternion v, Quaternion xt, float zeta, float omega, float h)
        {
            float f = 1.0f + 2.0f * h * zeta * omega;
            float oo = omega * omega;
            float hoo = h * oo;
            float hhoo = h * hoo;
            float detInv = 1.0f / (f + hhoo);

            //var detX = f * x + h * v + hhoo * xt;
            x.ToAngleAxis(out float angle, out Vector3 axis);
            var fx = Quaternion.AngleAxis(f * angle, axis);
            v.ToAngleAxis(out angle, out axis);
            var hv = Quaternion.AngleAxis(h * angle, axis);
            xt.ToAngleAxis(out angle, out axis);
            var hhooxt = Quaternion.AngleAxis(hhoo * angle, axis);
            var detX = hhooxt * hv * fx;

            //var detV = v + hoo * (xt - x);
            var xtMinusX = xt * Quaternion.Inverse(x);
            xtMinusX.ToAngleAxis(out angle, out axis);
            var hooxtMinusX = Quaternion.AngleAxis(hoo * angle, axis);
            var detV = hooxtMinusX * v;

            //x = detX * detInv;
            detX.ToAngleAxis(out angle, out axis);
            x = Quaternion.AngleAxis(detInv * angle, axis);
            //v = detV * detInv;
            detV.ToAngleAxis(out angle, out axis);
            v = Quaternion.AngleAxis(detInv * angle, axis);
        }

        /** Semi-Implicit Euler method
         *  v = (v + h * omega^2 * (xt - x)) / (1 + h^2 * omega^2)
         *  x = x + h * v
         */
        static void SemiImplicitSpring(ref Vector3 x, ref Vector3 v, Vector3 xt, float zeta, float omega, float h)
        {
            v += -2.0f * h * zeta * omega * v + h * omega * omega * (xt - x);
            x += h * v;
        }

        static void SemiImplicitSpring(ref float x, ref float v, float xt, float zeta, float omega, float h)
        {
            v += -2.0f * h * zeta * omega * v + h * omega * omega * (xt - x);
            x += h * v;
        }

        static void SemiImplicitSpring(ref Quaternion x, ref Quaternion v, Quaternion xt, float zeta, float omega, float h)
        {
            //v += -2.0f * h * zeta * omega * v + h * omega * omega * (xt - x);
            var xtMinusX = Quaternion.Inverse(x) * xt;
            xtMinusX.ToAngleAxis(out float angle, out Vector3 axis);
            var hooxTMinusxt = Quaternion.AngleAxis(h * omega * omega * angle, axis);
            v.ToAngleAxis(out angle, out axis);
            var minus2hzov = Quaternion.AngleAxis(-2.0f * h * zeta * omega * angle, axis);
            v = minus2hzov * hooxTMinusxt;

            //x += h * v;
            var hv = Quaternion.AngleAxis(h * angle, axis);
            x = x * hv;
        }
    }
}
