using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class WireCubeDetector : MonoBehaviour
{
    public Transform trackTransform;
    public System.Action<RaycastHit> onPressed;
    private Vector3 prevPos;

    private IEnumerator Start()
    {
        var rigidbody = GetComponent<Rigidbody>();

        if (rigidbody)
        {
            rigidbody.isKinematic = true;
        }
        var cachedTransform = transform;
        while (true)
        {
            if (trackTransform)
            {
                var diff = (prevPos - trackTransform.position).magnitude;

                if (cachedTransform.childCount == 0 || diff > 1)
                {
                    var go = new GameObject(cachedTransform.childCount.ToString());
                    var trans = go.transform;

                    trans.position = trackTransform.position;
                    trans.rotation = trackTransform.rotation;

                    prevPos = trans.position;

                    var box = go.AddComponent<BoxCollider>();
                    box.isTrigger = true;
                    box.size = new Vector3(1.0f, 1.0f, 1.0f);

                    trans.SetParent(cachedTransform);
                }

                yield return null;
            }
            else
            {
                yield return null;
            }
        }
    }
}
