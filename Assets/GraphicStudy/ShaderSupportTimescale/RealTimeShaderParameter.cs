using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class RealTimeShaderParameter : MonoBehaviour
{
    public string realTimePropertyName = "_RealTime";

    private static RealTimeShaderParameter _Instance;

    private void Awake()
    {
        if (!Application.isPlaying)
            return;
        if (_Instance == null)
            _Instance = this;
        else
        {
            Destroy(this);
        }
    }

    private void OnDestroy()
    {
        if (!Application.isPlaying)
            return;
        if (_Instance == this)
            _Instance = null;
    }

    // Update is called once per frame
    private void Update()
    {
        Shader.SetGlobalFloat(realTimePropertyName, Time.realtimeSinceStartup);
    }

    [ContextMenu("TimeScale = 0")]
    public void TestTimeScale0()
    {
        Time.timeScale = 0f;
    }
    [ContextMenu("TimeScale = 0.5")]
    public void TestTimeScale0_5()
    {
        Time.timeScale = 0.5f;
    }
    [ContextMenu("TimeScale = 1")]
    public void TestTimeScale1()
    {
        Time.timeScale = 1f;
    }
}
