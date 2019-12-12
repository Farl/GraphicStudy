using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SyncOffsetCamera : MonoBehaviour {
	[System.Serializable]
	public class Pair
	{
		public Transform src;
		public Transform dst;
	}
	public List<Pair> pairs = new List<Pair> ();

	// Use this for initialization
	void Start () {
	}
	
	// Update is called once per frame
	void Update () {
		foreach (Pair p in pairs) {
			if (p.src && p.dst) {
				p.dst.localPosition = p.src.localPosition;
				p.dst.localRotation = p.src.localRotation;
				p.dst.localScale = p.src.localScale;
			}
		}
	}
}
