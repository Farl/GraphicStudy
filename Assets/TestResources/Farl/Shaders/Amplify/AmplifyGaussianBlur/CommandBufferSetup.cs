using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class CommandBufferSetup : MonoBehaviour
{
	static private Dictionary<string, CommandBufferRecord> recordMap = new Dictionary<string, CommandBufferRecord> ();
	static private Dictionary<string, CommandBufferSetup> setupMap = new Dictionary<string, CommandBufferSetup> ();

	static public void RegisterTag(CommandBufferTag tag)
	{
		CommandBufferRecord record = null;
		if (!recordMap.ContainsKey (tag.commandBufferName)) {
			record = new CommandBufferRecord ();
			record.commandBufferName = tag.commandBufferName;
			recordMap.Add (record.commandBufferName, record);
		} else {
			record = recordMap [tag.commandBufferName];
		}

		if (record != null) {
			record.Register (tag);
		}
	}

	static public void UnregisterTag(string registerName, CommandBufferTag tag)
	{
		CommandBufferRecord record = null;
		if (recordMap.ContainsKey (registerName)) {
			record = recordMap [registerName];
			if (record != null) {
				record.Unregister (tag);
			}
			// TODO: Is empty
		}
	}

	static public void TagOnRenderObject(CommandBufferTag tag)
	{
		if (!string.IsNullOrEmpty (tag.commandBufferName)) {
			CommandBufferRecord record = null;
			if (!recordMap.ContainsKey (tag.commandBufferName)) {
				RegisterTag (tag);
			}
			if (recordMap.ContainsKey (tag.commandBufferName)) {
				record = recordMap [tag.commandBufferName];
				record.OnRenderObject ();
			}
		}
	}


	public string commandBufferName;
	public CameraEvent cameraEvent;

	private string recordName;
	private CommandBufferRecord record;
	private Dictionary<Camera,CommandBuffer> commandBufferMap = new Dictionary<Camera,CommandBuffer>();

	protected virtual void OnValidate()
	{
		if (!string.IsNullOrEmpty (recordName) && commandBufferName != recordName) {
			Unregister ();
		}
		if (!setupMap.ContainsValue(this) || recordMap.ContainsKey(commandBufferName) ||
			(!string.IsNullOrEmpty (commandBufferName) && commandBufferName != recordName)) {
			Register ();
		}
	}

	protected virtual void OnEnable()
	{
		Cleanup ();
	}

	protected virtual void OnDisable()
	{
		Cleanup ();
	}

	protected virtual void Register()
	{
		if (!string.IsNullOrEmpty (commandBufferName)) {
			if (setupMap.ContainsKey (commandBufferName)) {
				Debug.LogWarning ("Duplicate setup name " + commandBufferName, setupMap [commandBufferName]);
				setupMap [commandBufferName] = this;
			} else {
				setupMap.Add (commandBufferName, this);
			}

			if (!recordMap.ContainsKey (commandBufferName)) {
				record = new CommandBufferRecord ();
				record.commandBufferName = commandBufferName;
				recordMap.Add (commandBufferName, record);
			} else {
				record = recordMap [commandBufferName];
			}

			if (record != null) {
				if (record.setup) {
					Debug.LogWarning ("Duplicate command buffer setup! " + this.name, record.setup);
				}
				record.setup = this;
			}

			recordName = commandBufferName;
		}
	}

	protected virtual void Unregister()
	{
		if (!string.IsNullOrEmpty(recordName))
		{
			setupMap.Remove (recordName);

			if (record != null && record.tags != null && record.tags.Count <= 0) {
				recordMap.Remove (recordName);
			}
		}
	}

	protected virtual void Awake()
	{
		Register ();
	}

	protected virtual void OnDestory()
	{
		Unregister ();
	}

	public virtual void Setup()
	{
		if (!isActiveAndEnabled)
			return;
		
		Camera currCam = Camera.current;
		if (record != null) {
			if (record.cameraEvent != cameraEvent) {
				Cleanup ();
			}

			CommandBuffer cmdBuf = null;

			// Did we already add the command buffer on this camera? Nothing to do then.
			if (commandBufferMap.ContainsKey (currCam)) {
				cmdBuf = commandBufferMap [currCam];
			}
			if (cmdBuf == null) {
				cmdBuf = new CommandBuffer ();
				commandBufferMap.Add (currCam, cmdBuf);
				cmdBuf.name = commandBufferName;

				// Remember which camera event when create
				record.cameraEvent = cameraEvent;

				// Do anything you want
				SetupCommandBuffer (cmdBuf);

				currCam.AddCommandBuffer (record.cameraEvent, cmdBuf);
			}
		}
	}

	// Whenever any camera will render us, add a command buffer to do the work on it
	protected virtual void SetupCommandBuffer (CommandBuffer cmdBuf)
	{
		List<Renderer> rendererList = CollectRenderer ();

		// Draw renderer
		foreach (Renderer r in rendererList) {
			int i = 0;
			foreach (Material m in r.sharedMaterials) {
				cmdBuf.DrawRenderer (r, m, i, -1);
				i++;
			}
		}
	}

	protected virtual List<Renderer> CollectRenderer()
	{
		List<Renderer> rendererList = new List<Renderer> ();
		if (record.tags != null) {
			// Collect renderer
			foreach (CommandBufferTag tag in record.tags) {
				if (tag) {
					rendererList.AddRange(tag.GetComponentsInChildren<Renderer>(false));
				}
			}
		}
		return rendererList;
	}

	// Remove command buffers from all cameras we added into
	public virtual void Cleanup()
	{
		if (record != null) {
			foreach (KeyValuePair<Camera, CommandBuffer> kvp in commandBufferMap) {
				Camera c = kvp.Key;
				if (c) {
					// Remove camera event record from create
					c.RemoveCommandBuffer (record.cameraEvent, kvp.Value);
				}
			}
			commandBufferMap.Clear ();
		}
	}
}

public class CommandBufferRecord
{
	public string commandBufferName;
	public CommandBufferSetup setup;
	public HashSet<CommandBufferTag> tags = new HashSet<CommandBufferTag> ();
	public CameraEvent cameraEvent;
	public bool dirtyFlag;

	public void Register(CommandBufferTag tag)
	{
		if (!tags.Contains (tag)) {
			tags.Add (tag);
			dirtyFlag = true;
		}
	}

	public void Unregister(CommandBufferTag tag)
	{
		if (tags.Contains (tag)) {
			tags.Remove (tag);
			dirtyFlag = true;
		}
	}

	public void OnRenderObject()
	{
		if (setup) {
			if (dirtyFlag) {
				setup.Cleanup ();
				dirtyFlag = false;
			}
			setup.Setup ();
		}
	}
}