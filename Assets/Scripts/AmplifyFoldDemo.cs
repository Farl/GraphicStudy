using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AmplifyFoldDemo : MonoBehaviour {
	public Animator[] animators;
	public string parameterName = "Blend";

	[Range(0f, 1f)]
	public float currValue;

	[Range(0f, 1f)]
	public float targetValue = 1;

	public float speed = 1;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		if (Input.GetKey (KeyCode.Alpha0))
			targetValue = 0;
		else if (Input.GetKey (KeyCode.Alpha1))
			targetValue = 1;
		else if (Input.GetKey (KeyCode.Alpha5))
			targetValue = 0.5f;
		
		foreach (Animator a in animators) {
			if (a) {
				a.SetFloat (parameterName, currValue);
			}
		}

		currValue = Mathf.MoveTowards(currValue, targetValue, Time.deltaTime * speed);
	}
}
