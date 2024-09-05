using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[ExecuteAlways]
public class UIImageAnimation : Image
{
    [SerializeField]
    private float propertyValue = 0;

    [SerializeField]
    private string propertyName;
    
    private Material currMaterial;
    private Material instancedMaterial;

    protected override void Start()
    {
        base.Start();

        if (Application.isPlaying)
        {
            currMaterial = null;
            instancedMaterial = null;
            OnDirtyMaterial();
        }
    }

    protected override void OnDestroy()
    {
        base.OnDestroy();
        UnregisterDirtyMaterialCallback(OnDirtyMaterial);
        ClearInstancedMaterial();
    }

    void ClearInstancedMaterial()
    {
        if (!Application.isPlaying)
            DestroyImmediate(instancedMaterial);
        else
            Destroy(instancedMaterial);
        instancedMaterial = null;
    }

    public override Material materialForRendering
    {
        get
        {
            CheckMaterial();
            return instancedMaterial;
        }
    }

    void OnDirtyMaterial()
    {
        CheckMaterial();

        if (instancedMaterial && !string.IsNullOrEmpty(propertyName))
        {
            if (instancedMaterial.HasProperty(propertyName))
                instancedMaterial.SetFloat(propertyName, propertyValue);
        }
    }

    void CheckMaterial()
    {
        if (Application.isPlaying == false && m_OnDirtyMaterialCallback == null)
            RegisterDirtyMaterialCallback(OnDirtyMaterial);

        if (currMaterial != material)
        {
            currMaterial = material;
            ClearInstancedMaterial();
        }
        if (material != null && instancedMaterial == null)
        {
            var newMaterial = new Material(material);
            newMaterial.name += " (Instanced)";
            instancedMaterial = newMaterial;

            UnregisterDirtyMaterialCallback(OnDirtyMaterial);
            RegisterDirtyMaterialCallback(OnDirtyMaterial);
        }
    }
}
