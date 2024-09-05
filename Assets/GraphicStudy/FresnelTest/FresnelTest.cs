using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SS
{
    public class FresnelTest : MonoBehaviour
    {
        public Animator animator;
        public Renderer renderer;

        public string colorPropertyName = "_FresnelFXColor";
        [ColorUsage(true, true)]
        public Color color1;
        [ColorUsage(true, true)]
        public Color color2;

        private Material material;

        private float timer = 0;

        // Start is called before the first frame update
        void Start()
        {
        
        }

        // Update is called once per frame
        void Update()
        {
            if (!material)
            {
                if (renderer)
                {
                    // Do instance
                    material = renderer.material;
                }
            }
            if (material)
            {
                material.SetColor(colorPropertyName, Color.Lerp(color1, color2, Mathf.Sin(timer)));
            }
            timer += Time.deltaTime;
        }
    }
}
