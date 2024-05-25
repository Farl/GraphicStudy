namespace SS
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

    [ExecuteAlways]
    public class ShaderProperty : MonoBehaviour
    {
        public Transform cachedTransform
        {
            get
            {
                if (_cachedTransform == null)
                    _cachedTransform = transform;
                return _cachedTransform;
            }
        }
        private Transform _cachedTransform;

        [SerializeField]
        private Material m_material;
        [SerializeField]
        private string m_positionProperty;
        [SerializeField]
        private string m_localScaleProperty;
        [SerializeField]
        private string m_forwardProperty;

        // Update is called once per frame
        void Update()
        {
            if (!string.IsNullOrEmpty(m_positionProperty))
            {
                if (m_material == null)
                    Shader.SetGlobalVector(m_positionProperty, cachedTransform.position);
                else
                    m_material.SetVector(m_positionProperty, cachedTransform.position);
            }
            if (!string.IsNullOrEmpty(m_localScaleProperty))
            {
                if (m_material == null)
                    Shader.SetGlobalVector(m_localScaleProperty, cachedTransform.localScale);
                else
                    m_material.SetVector(m_localScaleProperty, cachedTransform.localScale);
            }
            if (!string.IsNullOrEmpty(m_forwardProperty))
            {
                if (m_material == null)
                    Shader.SetGlobalVector(m_forwardProperty, cachedTransform.forward);
                else
                    m_material.SetVector(m_forwardProperty, cachedTransform.forward);
            }
        }
    }

}