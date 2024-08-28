using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SS.Experiment
{

	[ExecuteAlways]
	public class RTClick : MonoBehaviour
	{
		#region Enums / Classes

		public enum OutputType
		{
			Position,
			Velocity
		}

		public enum OutputMethod
		{
			Global,
			Renderer,
			Renderer_MaterialPropertyBlock,
			Material,
		}

		[System.Serializable]
		public class OutputMaterial
		{
			public OutputMethod method = OutputMethod.Renderer_MaterialPropertyBlock;
			public Renderer renderer;
			public Material material;
			public OutputType type;
			public string propertyName;
			[NonSerialized] public MaterialPropertyBlock propertyBlock;
		}

		#endregion

		#region Inspector
		[SerializeField] public Shader kernel;
		[SerializeField] public Material kernelMaterial;
		[SerializeField] public int fixedFrameRate = 60;
		[SerializeField] public float waveDensity = 0.01f;
		[SerializeField] public float waveDampingForce = 50.0f;
		[Range(0.0f, 1.0f)]
		[SerializeField] public float waveSpeed = 0.99f;
		[Range(0.0f, 1.0f)]
		[SerializeField] public float waveDamping = 0.99f;

		[Header("Output")]
		[SerializeField] public OutputMaterial[] outputMaterials;
		[SerializeField] public bool singleBuffer = false;
		[Header("Render Texture")]
		[SerializeField] public int rtWidth = 256;
		[SerializeField] public int rtHeight = 256;
		[SerializeField] public RenderTextureFormat rtFormat = RenderTextureFormat.ARGB32;
		[SerializeField] public TextureWrapMode rtWrap = TextureWrapMode.Repeat;
		[SerializeField] public FilterMode rtFilter = FilterMode.Bilinear;
		[Header("Parameters")]
		[SerializeField] private float clickRadius = 0.05f;
		#endregion

		#region Public
		private RenderTexture positionTexture1;
		private RenderTexture positionTexture2;
		private RenderTexture velocityTexture1;
		private RenderTexture velocityTexture2;
		private List<Vector4> clickList = new List<Vector4>();
		private List<Vector4> clickVecArray = new List<Vector4>();
		public void SetClickTexCoord(Vector3 texcoord, float radius)
		{
			clickList.Add(new Vector4(texcoord.x, texcoord.y, texcoord.z, radius));
		}
		#endregion

		#region Private / Protected
		private bool doInit = false;    // Already initialized
		private bool click = false; // Is clicking
		private Material instancedMaterial;

		private void OnValidate()
		{
			_CleanUp();
			_Init();
		}

		private RenderTexture CreateTexture(string name)
		{
			rtWidth = Mathf.Max(1, rtWidth);
			rtHeight = Mathf.Max(1, rtHeight);
			RenderTexture rt = new RenderTexture(rtWidth, rtHeight, 0, rtFormat);
			rt.name = name;
			rt.hideFlags = HideFlags.DontSave;
			rt.filterMode = rtFilter;
			rt.wrapMode = rtWrap;
			return rt;
		}

		private void OnDestroy()
		{
			if (instancedMaterial)
			{
				if (Application.isPlaying)
					DestroyImmediate(instancedMaterial);
			}
		}

		private void _Init()
		{
			if (positionTexture1 == null)
			{
				positionTexture1 = CreateTexture("Position 1");
				positionTexture2 = CreateTexture("Position 2");
				doInit = true;
			}

			if (velocityTexture1 == null)
			{
				velocityTexture1 = CreateTexture("Velocity 1");
				velocityTexture2 = CreateTexture("Velocity 2");
				doInit = true;
			}

			if (kernelMaterial == null && kernel != null)
			{
				kernelMaterial = new Material(kernel);
				kernelMaterial.hideFlags = HideFlags.DontSave;

				kernelMaterial.SetTexture("_PositionBuffer", positionTexture1);
				kernelMaterial.SetTexture("_VelocityBuffer", velocityTexture1);

				// Output prepare
				if (outputMaterials != null)
				{
					foreach (OutputMaterial om in outputMaterials)
					{
						Texture tex = null;
						switch (om.type)
						{
							case OutputType.Velocity:
								tex = velocityTexture1;
								break;
							case OutputType.Position:
								tex = positionTexture1;
								break;
						}

						if (tex)
						{
							switch (om.method)
							{
								case OutputMethod.Global:
									if (!string.IsNullOrEmpty(om.propertyName))
									{
										Shader.SetGlobalTexture(om.propertyName, tex);
									}
									break;
								case OutputMethod.Renderer_MaterialPropertyBlock:
									if (om.renderer)
									{
										if (om.propertyBlock == null)
										{
											om.propertyBlock = new MaterialPropertyBlock();
										}
										om.renderer.GetPropertyBlock(om.propertyBlock);
										om.propertyBlock.SetTexture(om.propertyName, tex);
										om.renderer.SetPropertyBlock(om.propertyBlock);
									}
									break;

								case OutputMethod.Renderer:
									if (om.renderer)
									{
										if (Application.isPlaying)
										{
											instancedMaterial = om.renderer.material;
										}
										else
										{
											instancedMaterial = om.renderer.sharedMaterial;
										}
										if (instancedMaterial != null)
										{
											if (!string.IsNullOrEmpty(om.propertyName) && instancedMaterial.HasProperty(om.propertyName))
											{
												instancedMaterial.SetTexture(om.propertyName, tex);
											}
											else
											{
												instancedMaterial.mainTexture = tex;
											}
										}
									}
									break;
								case OutputMethod.Material:
									if (om.material)
									{
										if (!string.IsNullOrEmpty(om.propertyName) && om.material.HasProperty(om.propertyName))
										{
											om.material.SetTexture(om.propertyName, tex);
										}
										else
										{
											om.material.mainTexture = tex;
										}
									}
									break;
								default:
									break;
							}
						}
					}
				}

				// Initialize

				if (kernelMaterial != null)
				{
					if (positionTexture1)
						Graphics.Blit(null, positionTexture1, kernelMaterial, 2);
					if (positionTexture2)
						Graphics.Blit(null, positionTexture2, kernelMaterial, 2);
					if (!singleBuffer)
					{
						if (velocityTexture1)
							Graphics.Blit(null, velocityTexture1, kernelMaterial, 3);
						if (velocityTexture2)
							Graphics.Blit(null, velocityTexture2, kernelMaterial, 3);
					}
				}

				doInit = true;
			}
		}

		private void _CleanUp()
		{
			foreach (OutputMaterial om in outputMaterials)
			{
				if (om.propertyBlock != null && om.renderer != null)
				{
					om.renderer.SetPropertyBlock(null);
				}
			}
			if (kernelMaterial)
			{
				DestroyImmediate(kernelMaterial);
				kernelMaterial = null;
			}
			if (positionTexture1)
				DestroyImmediate(positionTexture1);
			if (velocityTexture1)
				DestroyImmediate(velocityTexture1);
			if (positionTexture2)
				DestroyImmediate(positionTexture2);
			if (velocityTexture2)
				DestroyImmediate(velocityTexture2);
		}

		private void OnEnable()
		{
			_CleanUp();
			_Init();
		}

		private void OnDisable()
		{
			_CleanUp();
		}

		private void UpdateInput()
		{
			click = false;
			Vector3 texcoord = Vector3.zero;
			if (kernelMaterial)
			{
				if (Input.GetMouseButton(0))
				{
					Vector3 sPos = Input.mousePosition;
					Ray ray = Camera.main.ScreenPointToRay(sPos);
					RaycastHit hitInfo;
					if (Physics.Raycast(ray, out hitInfo, 100))
					{
						texcoord = hitInfo.textureCoord;
						click = true;

						SetClickTexCoord(texcoord, clickRadius);
					}
				}
			}

			int count = 6;
			clickVecArray.Clear();
			while (count > 0)
			{
				if (clickList.Count > 0)
				{
					clickVecArray.Add(clickList[0]);
					clickList.RemoveAt(0);
				}
				else
				{
					clickVecArray.Add(new Vector4(0, 0, 0, 0));
				}
				count--;
			}
			clickList.Clear();

			kernelMaterial.SetVectorArray("_ClickList", clickVecArray);
		}

		// Update is called once per frame
		private void Update()
		{
			_Init();

			UpdateInput();

			if (kernelMaterial)
			{
				if (!singleBuffer)
				{
					// Swap buffer
					var tempVelocityTex = velocityTexture1;
					var tempPositionTex = positionTexture1;

					velocityTexture1 = velocityTexture2;
					velocityTexture2 = tempVelocityTex;

					positionTexture1 = positionTexture2;
					positionTexture2 = tempPositionTex;

					if (positionTexture1 && positionTexture2 && velocityTexture1 && velocityTexture2)
					{
						kernelMaterial.SetVector("_WaveParam", new Vector4(waveDensity, waveDampingForce, waveSpeed, waveDamping));
						var frameRate = Time.deltaTime;
						if (fixedFrameRate > 0)
						{
							frameRate = 1.0f / fixedFrameRate;
						}
						kernelMaterial.SetVector("_SimulationParameter", new Vector4(Time.deltaTime, 0, 0, 0));

						kernelMaterial.SetTexture("_PositionBuffer", positionTexture1);
						kernelMaterial.SetTexture("_VelocityBuffer", velocityTexture1);
						Graphics.Blit(null, positionTexture2, kernelMaterial, 0);
						kernelMaterial.SetTexture("_PositionBuffer", positionTexture2);
						kernelMaterial.SetTexture("_VelocityBuffer", velocityTexture1);
						Graphics.Blit(null, velocityTexture2, kernelMaterial, 1);
					}
				}
				else
				{
					if (positionTexture1 && positionTexture2)
					{
						kernelMaterial.SetVector("_WaveParam", new Vector4(waveDensity, waveDampingForce, waveSpeed, waveDamping));
						var frameRate = Time.deltaTime;
						if (fixedFrameRate > 0)
						{
							frameRate = 1.0f / fixedFrameRate;
						}
						kernelMaterial.SetVector("_SimulationParameter", new Vector4(Time.deltaTime, 0, 0, 0));

						kernelMaterial.SetTexture("_PositionBuffer", positionTexture1);
						Graphics.Blit(null, positionTexture2, kernelMaterial, 0);
						kernelMaterial.SetTexture("_PositionBuffer", positionTexture2);
						Graphics.Blit(null, positionTexture1, kernelMaterial, 1);
					}
				}
			}
		}

		#endregion
	}

}