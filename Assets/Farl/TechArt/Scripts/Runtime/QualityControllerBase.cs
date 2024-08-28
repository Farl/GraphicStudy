namespace SS
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
    using UnityEngine.UI;

    public class QualityControllerBase : MonoBehaviour
    {
        public static QualityControllerBase Instance;

        public int targetFrameRate = -1;
        public int resolution = -1;

        public List<int> debugResolutions = new List<int>();
        public List<int> debugFrameRates = new List<int>();

        protected static bool initResolution = false;
        protected static int origWidth;
        protected static int origHeight;
        protected static float origAspect;


        private static void Init()
        {
            if (initResolution == false)
            {
                origWidth = Screen.width;
                origHeight = Screen.height;
                origAspect = (float)origWidth / origHeight;
                initResolution = true;
            }
        }

        public static void SetResolution(int resolution, int frameRate)
        {
            Init();

            if (resolution < 0)
            {
                resolution = Mathf.Min(origHeight, origWidth);
            }
            if (origAspect > 0)
            {
                int width = (int)(resolution * origAspect);
                int height = resolution;
                Debug.Log($"{width} x {height}");
                Screen.SetResolution(width, height, FullScreenMode.ExclusiveFullScreen, frameRate);
            }
            else
            {
                int width = resolution;
                int height = (int)(resolution / origAspect);
                Debug.Log($"{width} x {height}");
                Screen.SetResolution(width, height, FullScreenMode.ExclusiveFullScreen, frameRate);
            }
        }

        void Awake()
        {
            if (Instance == null)
            {
                Instance = this;
            }
            else
            {
                Destroy(this);
            }
        }

        protected virtual void OnStart()
        {

        }

        private void Start()
        {
            Application.targetFrameRate = targetFrameRate;
            Init();
            SetResolution(resolution, targetFrameRate);
            OnStart();

        }

        private void OnDestroy()
        {
            if (Instance == this)
                Instance = null;
        }
    }
}
