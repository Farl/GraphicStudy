using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace KawaseBlur
{
    /// <summary>
    /// Settings
    /// </summary>
    [System.Serializable]
    public class KawaseBlurSettings
    {
        public enum RenderTarget
        {
            TemporaryRT,
            RT,
            FrameBuffer
        }
        public enum BlurMethod
        {
            Kawase,
            Gaussian3D,
            Gaussian2D
        }

        public bool bypass = false;
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
        public Material blurMaterial = null;
        public string blurPropertyName = "_offset";
        public BlurMethod blurMethod = BlurMethod.Kawase;

        [Range(1, 15)]
        public float offsetScale = 1;

        [Range(0, 15)]
        public int blurPasses = 1;

        [Range(1, 8)]
        public int downsample = 1;

        public RenderTarget renderTarget;
        public string targetName = "_blurTexture";
    }

    /// <summary>
    /// Kawase Blur render feature
    /// </summary>
    public class KawaseBlur : ScriptableRendererFeature
    {
        public KawaseBlurSettings settings = new KawaseBlurSettings();

        private KawaseBlurRenderPass scriptablePass;

        public override void Create()
        {
            scriptablePass = new KawaseBlurRenderPass("KawaseBlur")
            {
                settings = settings
            };

            scriptablePass.renderPassEvent = settings.renderPassEvent;
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            if (renderingData.cameraData.cameraType != CameraType.Game)
            {
                //return;
            }
            scriptablePass.Setup(renderer);
            renderer.EnqueuePass(scriptablePass);
        }

        protected override void Dispose(bool disposing)
        {
            base.Dispose(disposing);
            if (disposing && scriptablePass != null)
            {
                scriptablePass.OnDispose();
            }
        }
    }

    /// <summary>
    /// Render pass
    /// </summary>
    class KawaseBlurRenderPass : ScriptableRenderPass
    {
        public KawaseBlurSettings settings { get; set; }

        private string profilerTag;
        private int tmpId1;
        private int tmpId2;

        private RenderTargetIdentifier source { get; set; }
        private RenderTargetIdentifier tmpRT1;
        private RenderTargetIdentifier tmpRT2;

        private int origWidth;
        private int origHeight;
        private RenderTargetIdentifier rt3;
        private RenderTexture _rt3;

#if UNITY_2022_1_OR_NEWER
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            base.OnCameraSetup(cmd, ref renderingData);
            var renderer = renderingData.cameraData.renderer;
            var handle = renderer.cameraColorTargetHandle;
            var source = handle.nameID;
            this.source = source;
        }
#endif

        public void Setup(ScriptableRenderer renderer)
        {
#if UNITY_2022_1_OR_NEWER
#else
            var source = renderer.cameraColorTarget;
            this.source = source;
#endif
        }

        public KawaseBlurRenderPass(string profilerTag)
        {
            this.profilerTag = profilerTag;
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            var width = cameraTextureDescriptor.width / settings.downsample;
            var height = cameraTextureDescriptor.height / settings.downsample;

            tmpId1 = Shader.PropertyToID(nameof(tmpId1));
            tmpId2 = Shader.PropertyToID(nameof(tmpId2));
            cmd.GetTemporaryRT(tmpId1, width, height, 0, FilterMode.Bilinear, RenderTextureFormat.ARGB32);
            cmd.GetTemporaryRT(tmpId2, width, height, 0, FilterMode.Bilinear, RenderTextureFormat.ARGB32);

            tmpRT1 = new RenderTargetIdentifier(tmpId1);
            tmpRT2 = new RenderTargetIdentifier(tmpId2);

            ConfigureTarget(tmpRT1);
            ConfigureTarget(tmpRT2);

            if (settings.renderTarget == KawaseBlurSettings.RenderTarget.RT)
            {
                if (origHeight != height || origWidth != width)
                {
                    if (_rt3 != null)
                    {
                        Object.DestroyImmediate(_rt3);
                    }
                    _rt3 = new RenderTexture(width, height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
                    _rt3.name = $"KawaseBlur RT {width}x{height}";
                    rt3 = new RenderTargetIdentifier(_rt3);
                    origWidth = width;
                    origHeight = height;
                }
            }
        }

        public virtual void OnDispose()
        {
            if (_rt3 != null)
            {
                Object.DestroyImmediate(_rt3);
            }
        }

        private void BlurBlitPingPong(CommandBuffer cmd)
        {
            cmd.Blit(tmpRT1, tmpRT2, settings.blurMaterial);

            // PingPong
            var rttmp = tmpRT1;
            tmpRT1 = tmpRT2;
            tmpRT2 = rttmp;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (settings == null || settings.bypass)
            {
                return;
            }

            CommandBuffer cmd = CommandBufferPool.Get(profilerTag);

            RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
            opaqueDesc.depthBufferBits = 0;

            var material = settings.blurMaterial;

            // Run blur passes
            if (settings.blurMethod == KawaseBlurSettings.BlurMethod.Gaussian3D || settings.blurMethod == KawaseBlurSettings.BlurMethod.Gaussian2D)
            {
                // Clone source buffer
                cmd.Blit(source, tmpRT1, null);

                for (var i = 0; i < settings.blurPasses; i++)
                {
                    // Use 2D kernel
                    if (settings.blurMethod == KawaseBlurSettings.BlurMethod.Gaussian2D)
                    {
                        cmd.SetGlobalVector(settings.blurPropertyName, new Vector2(settings.offsetScale, 0));
                        BlurBlitPingPong(cmd);
                        cmd.SetGlobalVector(settings.blurPropertyName, new Vector2(0, settings.offsetScale));
                        BlurBlitPingPong(cmd);
                    }
                    else
                    {
                        cmd.SetGlobalFloat(settings.blurPropertyName, settings.offsetScale);
                        BlurBlitPingPong(cmd);
                    }
                }
                material = null;
            }
            else
            {
                // First pass
                cmd.SetGlobalFloat(settings.blurPropertyName, settings.offsetScale * 1.5f);
                cmd.Blit(source, tmpRT1, settings.blurMaterial);

                for (var i = 0; i < settings.blurPasses - 1; i++)
                {
                    cmd.SetGlobalFloat(settings.blurPropertyName, 0.5f + settings.offsetScale * i);
                    BlurBlitPingPong(cmd);
                }

                // Final pass
                cmd.SetGlobalFloat(settings.blurPropertyName, 0.5f + settings.offsetScale * (settings.blurPasses - 1));
            }

            // Blit to render target
            if (settings.renderTarget == KawaseBlurSettings.RenderTarget.FrameBuffer)
            {
                cmd.Blit(tmpRT1, source, material);
            }
            else if (settings.renderTarget == KawaseBlurSettings.RenderTarget.TemporaryRT)
            {
                cmd.Blit(tmpRT1, tmpRT2, material);
                cmd.SetGlobalTexture(settings.targetName, tmpRT2);
            }
            else
            {
                cmd.Blit(tmpRT1, rt3, material);
                cmd.SetGlobalTexture(settings.targetName, rt3);
            }
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();

            CommandBufferPool.Release(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            base.FrameCleanup(cmd);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            base.OnCameraCleanup(cmd);
        }
    }


}
