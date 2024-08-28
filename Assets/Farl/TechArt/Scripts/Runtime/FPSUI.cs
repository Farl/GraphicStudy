namespace SS
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
    using UnityEngine.UI;

    public class FPSUI : MonoBehaviour
    {
        public bool showFPS;
        [SerializeField]
        private Text fpsText;

        #region FPS
        public float fpsUpdateInterval = 0.5f;

        private float accum = 0; // FPS accumulated over the interval
        private int frames = 0; // Frames drawn over the interval
        private float timeleft; // Left time for current interval
        private string _format;
        private float _fps;

        private void UpdateFPS()
        {
            if (fpsText == null || !showFPS) return;

            timeleft -= Time.deltaTime;
            accum += Time.timeScale / Time.deltaTime;
            ++frames;

            // Interval ended - update GUI text and start new interval
            if (timeleft <= 0.0)
            {
                // display two fractional digits (f2 format)
                _fps = accum / frames;
                _format = $"<color={((_fps < 30) ? "red" : (_fps < 60) ? "yellow" : "#00FF00")}>{_fps:0.0}</color>";

                fpsText.text = _format;

                timeleft = fpsUpdateInterval;
                accum = 0.0F;
                frames = 0;
            }
        }
        #endregion

        private void Awake()
        {
            if (fpsText != null)
            {
                fpsText.gameObject.SetActive(showFPS);
            }
        }

        private void Update()
        {
            UpdateFPS();
        }
    }
}
