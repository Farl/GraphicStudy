using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AmplifyPortalPlayer : MonoBehaviour {

    public float _speed = 10f;
    public float _angularSpeed = 180f;
    Transform _transform;
    Transform _cameraTransform;

	// Use this for initialization
	void Start () {
        _transform = transform;
        Camera cam = GetComponentInChildren<Camera>();
        if (cam)
        {
            _cameraTransform = cam.transform;
        }
	}
	
	// Update is called once per frame
	void Update ()
    {
        float horizontal = Input.GetAxis("Horizontal");
        float vertical = Input.GetAxis("Vertical");
        Vector3 moveVec = _transform.forward * vertical;
        _transform.rotation = Quaternion.RotateTowards(_transform.rotation, _transform.rotation * Quaternion.AngleAxis(horizontal, Vector3.up), _angularSpeed * Time.deltaTime);
        _transform.position = Vector3.MoveTowards(_transform.position, _transform.position + moveVec, _speed * Time.deltaTime);
    }
}
