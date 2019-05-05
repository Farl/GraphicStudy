using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CommandBufferTag : MonoBehaviour
{
	public string commandBufferName;
	private string recordName;

	protected virtual void Register()
	{
		if (!string.IsNullOrEmpty (commandBufferName)) {
			CommandBufferSetup.RegisterTag(this);
			recordName = commandBufferName;
		}
	}

	protected virtual void Unregister()
	{
		if (!string.IsNullOrEmpty (recordName)) {
			CommandBufferSetup.UnregisterTag(recordName, this);
		}
	}

	protected virtual void OnValidate()
	{
		if (!string.IsNullOrEmpty(recordName) && commandBufferName != recordName) {
			Unregister ();
		}
		if (!string.IsNullOrEmpty(commandBufferName) && commandBufferName != recordName)
		{
			Register();
		}
	}

	protected virtual void OnBecameVisible()
	{
		Register ();
	}

	protected virtual void OnBecameInvisible()
	{
		Unregister ();
	}

	protected virtual void OnDisable()
	{
		Unregister ();
	}

	protected virtual void OnWillRenderObject()
	{
		CommandBufferSetup.TagOnRenderObject (this);
	}
}