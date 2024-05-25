using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;


#if UNITY_EDITOR
using UnityEditor;
#endif

namespace SS
{
    [CreateAssetMenu(fileName = "NoiseTexture", menuName = "SS/Noise Texture")]
    public class NoiseTexture2D : ScriptableObject
    {
        //-------------------------------------------------------------------------------------------------------------------
        // Public Structs
        //-------------------------------------------------------------------------------------------------------------------
        [System.Serializable]
        public struct IntVector3 { public int x, y, z; }

        //[System.Serializable]
        //public struct ComputeParameter<T>{ public string name; public T value; }
        //Couldn't get this to serialize with unity's inspector so I'm hardcoding 
        //it for now until I can figure out some solution
        [System.Serializable]
        public struct ComputeParameterFloat { public string name; public float value; }

        [System.Serializable]
        public struct ComputeParameterVector { public string name; public Vector4 value; }

        [System.Serializable]
        public struct ComputeRWTexture
        {
            public string name;
            [HideInInspector]
            public RenderTexture rt;
        }

        //-------------------------------------------------------------------------------------------------------------------
        // Public Variables
        //-------------------------------------------------------------------------------------------------------------------
        //public string assetName;
        public ComputeShader computeShader;
        public string kernelName;
        public IntVector3 computeThreads;
        public ComputeRWTexture rwTexture;
        public int squareResolution = 64;
        public ComputeParameterFloat[] parameters;
        public ComputeParameterVector[] vecParameters;

        // Farl: for Editor function
        [NonSerialized] public Dictionary<string, IntVector3> kernelData = new Dictionary<string, IntVector3>();
        [NonSerialized] public HashSet<string> rwTextures = new HashSet<string>();

        //-------------------------------------------------------------------------------------------------------------------
        // Generator Functions
        //-------------------------------------------------------------------------------------------------------------------
        public virtual void GenerateTexture()
        {
            int kernel = computeShader.FindKernel(kernelName);
            computeShader.Dispatch(kernel,
                squareResolution / computeThreads.x,
                squareResolution / computeThreads.y, 1);
        }

        public virtual void CreateRenderTexture()
        {
            RenderTexture rt = new RenderTexture(squareResolution, squareResolution, 24, RenderTextureFormat.ARGB32);
            rt.enableRandomWrite = true;
            rt.Create();
            rwTexture.rt = rt;
        }

        //-------------------------------------------------------------------------------------------------------------------
        // Compute Shader Getters/Setters
        //-------------------------------------------------------------------------------------------------------------------
        public void SetParameters()
        {
            /*Currently I have this hardcoded for float parameters,
			**however it very easily can be modified/extended.
			**If this becomes used more in the future, a full on
			**editor window could allow for more modularity.*/
            foreach (ComputeParameterFloat param in parameters)
                computeShader.SetFloat(param.name, param.value);
            foreach (ComputeParameterVector param in vecParameters)
                computeShader.SetVector(param.name, param.value);
        }

        public void SetTexture()
        {
            int kernel = computeShader.FindKernel(kernelName);
            computeShader.SetTexture(kernel, rwTexture.name, rwTexture.rt);
        }

        //-------------------------------------------------------------------------------------------------------------------
        // Save/Utility Functions
        //-------------------------------------------------------------------------------------------------------------------
        protected Texture2D ConvertFromRenderTexture(RenderTexture rt)
        {
            Texture2D output = new Texture2D(squareResolution, squareResolution);
            RenderTexture.active = rt;
            output.ReadPixels(new Rect(0, 0, squareResolution, squareResolution), 0, 0);
            output.Apply();
            return output;
        }

        public virtual void SaveAsset()
        {
#if UNITY_EDITOR
            Texture2D output = ConvertFromRenderTexture(rwTexture.rt);
            output.name = this.name;
            //AssetDatabase.CreateAsset(output, "Assets/Noise/" + assetName + ".asset");

            // Replace Texture2D in this object
            Texture2D texture2D = AddOrReplaceAsset<Texture2D>(output);
#endif
        }

        protected T AddOrReplaceAsset<T>(T obj) where T : UnityEngine.Object
        {
            if (obj == null) return null;
            obj.name = this.name;
            
            var assets = AssetDatabase.LoadAllAssetsAtPath(AssetDatabase.GetAssetPath(this));
            T result = null;
            foreach (var asset in assets)
            {
                if (asset is T)
                {
                    // Replace
                    result = asset as T;
                    EditorUtility.CopySerialized(obj, result);
                    break;
                }
            }

            if (result == null)
            {
                // Add
                result = obj;
                AssetDatabase.AddObjectToAsset(result, this);
            }

            if (result != null)
            {
                // Save
                EditorUtility.SetDirty(result);
                AssetDatabase.SaveAssets();
            }
            return result;
        }
    }
}
