using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
using System.Text.RegularExpressions;
using System.IO;
using System.Linq;
using System;

namespace SS
{
    [CustomEditor(typeof(NoiseTexture2D))]
    public class NoiseTexture2DEditor : Editor
    {
        public class KernelData
        {
            public string name;
            public Vector3Int threads;
        }

        public class ComputeShaderData
        {
            public ComputeShader computeShader;
            public List<KernelData> kernels = new List<KernelData>();
            public List<string> rwTexture2Ds = new List<string>();
            public List<string> rwTexture3Ds = new List<string>();
            public List<string> floats = new List<string>();
            public List<string> float4s = new List<string>();
            public List<float> floatValues = new List<float>();
            public List<Vector4> float4Values = new List<Vector4>();

            public void Parse(ComputeShader computeShader)
            {
                this.computeShader = computeShader;
                var filePath = AssetDatabase.GetAssetPath(computeShader);
                var text = File.ReadAllText(filePath);
                var textExceptFunction = Regex.Replace(text,
                    @"([\w]+)\s+([\w]+)\s*\(([^\(\)]*)\)\s*\{((?'nested'\{)|\}(?'-nested')|[\w\W]*?)*\}",
                    ""
                );

                // Find all the kernels
                var kernelMatches = Regex.Matches(text, @"\[numthreads\((\d+),(\d+),(\d+)\)\]\svoid\s+(\w+)\s*\(");
                foreach (Match match in kernelMatches)
                {
                    var kernelName = match.Groups[4].Value;
                    var threadX = int.Parse(match.Groups[1].Value);
                    var threadY = int.Parse(match.Groups[2].Value);
                    var threadZ = int.Parse(match.Groups[3].Value);
                    kernels.Add(new KernelData { name = kernelName, threads = new Vector3Int(threadX, threadY, threadZ) });
                }

                // Find all the RWTexture2D
                var rwTexture2DMatches = Regex.Matches(textExceptFunction, @"RWTexture2D\<float4\>\s+(\w+)");
                foreach (Match match in rwTexture2DMatches)
                {
                    rwTexture2Ds.Add(match.Groups[1].Value);
                }

                // Find all the RWTexture3D
                var rwTexture3DMatches = Regex.Matches(textExceptFunction, @"RWTexture3D\<float4\>\s+(\w+)");
                foreach (Match match in rwTexture3DMatches)
                {
                    rwTexture3Ds.Add(match.Groups[1].Value);
                }

                // Find all the float not in function and get its default value
                var floatMatches = Regex.Matches(textExceptFunction,
                    @"float\s+(\w+)\s*(=\s*([\+\-]*[\d.]+))*;");
                foreach (Match match in floatMatches)
                {
                    var name = match.Groups[1].Value;
                    var value = match.Groups[3].Value;
                    if (!string.IsNullOrEmpty(value))
                    {
                        floatValues.Add(float.Parse(value));
                    }
                    else
                    {
                        floatValues.Add(0);
                    }
                    floats.Add(name);
                }

                // Find all the float4 not in function and get its default value
                var float4Matches = Regex.Matches(textExceptFunction,
                    @"float4\s+(\w+)(\s+\=\sfloat4\(([^\(\)]*)\))?;");
                foreach (Match match in float4Matches)
                {
                    var name = match.Groups[1].Value;
                    float4s.Add(name);
                    Vector4 vectorValue = new Vector4();
                    if (match.Groups[3].Success)
                    {
                        var value = match.Groups[3].Value;
                        if (!string.IsNullOrEmpty(value))
                        {
                            var values = value.Split(',', System.StringSplitOptions.RemoveEmptyEntries);
                            for (int i = 0; i < 4 && i < values.Length; i++)
                            {
                                vectorValue[i] = float.Parse(values[i]);
                            }
                        }
                    }
                    float4Values.Add(vectorValue);
                }

                // print debug data
                Debug.Log($"Compute Shader: {computeShader.name}");
                foreach (var kernel in kernels)
                {
                    Debug.Log($"Kernel: {kernel.name} Threads: {kernel.threads.x}, {kernel.threads.y}, {kernel.threads.z}");
                }
                foreach (var rwTexture2D in rwTexture2Ds)
                {
                    Debug.Log($"RWTexture2D: {rwTexture2D}");
                }
                foreach (var rwTexture3D in rwTexture3Ds)
                {
                    Debug.Log($"RWTexture3D: {rwTexture3D}");
                }
                for (int i = 0; i < floats.Count && i < floatValues.Count; i++)
                {
                    Debug.Log($"Float: {floats[i]} Value: {floatValues[i]}");
                }
                for (int i = 0; i < float4s.Count && i < float4Values.Count; i++)
                {
                    Debug.Log($"Float4: {float4s[i]} Value: {float4Values[i]}");
                }
            }
        }

        public override void OnInspectorGUI()
        {
            if (GUILayout.Button("Parse"))
            {
                foreach (var nt in targets)
                {
                    var noiseTexture = nt as NoiseTexture2D;
                    if (noiseTexture == null)
                        continue;

                    var computeShader = noiseTexture.computeShader;
                    if (computeShader != null)
                    {
                        ComputeShaderData computeShaderData = new ComputeShaderData();
                        computeShaderData.Parse(computeShader);
                        
                        // Kernel
                        noiseTexture.kernelData.Clear();
                        foreach (var kernel in computeShaderData.kernels)
                        {
                            noiseTexture.kernelData.Add(kernel.name, new NoiseTexture2D.IntVector3 { x = kernel.threads.x, y = kernel.threads.y, z = kernel.threads.z });
                        }

                        // RWTexture
                        noiseTexture.rwTextures.Clear();
                        foreach (var rwTexture2D in computeShaderData.rwTexture2Ds)
                        {
                            noiseTexture.rwTextures.Add(rwTexture2D);
                        }
                        foreach (var rwTexture3D in computeShaderData.rwTexture3Ds)
                        {
                            noiseTexture.rwTextures.Add(rwTexture3D);
                        }

                        // Parameter (float)
                        for (int i = 0; i < computeShaderData.floats.Count && i < computeShaderData.floatValues.Count; i++)
                        {
                            var name = computeShaderData.floats[i];
                            var value = computeShaderData.floatValues[i];
                            bool found = false;
                            for (int j = 0; j < noiseTexture.parameters.Length; j++)
                            {
                                var parameter = noiseTexture.parameters[j];
                                if (parameter.name == name)
                                {
                                    found = true;
                                    //parameter.value = value;
                                }
                            }
                            if (found == false)
                            {
                                ArrayUtility.Add(ref noiseTexture.parameters, new NoiseTexture2D.ComputeParameterFloat { name = name, value = value });
                            }
                        }

                        // Parameter (float4)
                        for (int i = 0; i < computeShaderData.float4s.Count && i < computeShaderData.float4Values.Count; i++)
                        {
                            var name = computeShaderData.float4s[i];
                            var value = computeShaderData.float4Values[i];
                            bool found = false;
                            for (int j = 0; j < noiseTexture.vecParameters.Length; j++)
                            {
                                var parameter = noiseTexture.vecParameters[j];
                                if (parameter.name == name)
                                {
                                    found = true;
                                    //parameter.value = value;
                                }
                            }
                            if (found == false)
                            {
                                ArrayUtility.Add(ref noiseTexture.vecParameters, new NoiseTexture2D.ComputeParameterVector { name = name, value = value });
                            }
                        }
                    }
                }
            }

            base.OnInspectorGUI();

            foreach (var nt in targets)
            {
                var noiseTexture = nt as NoiseTexture2D;
                if (noiseTexture == null)
                    continue;
                
                if (noiseTexture.kernelData.Count > 0)
                {
                    // Draw a dropdown to select the kernel
                    var kernelNames = noiseTexture.kernelData.Keys.ToArray();
                    var selectedKernelIndex = Array.IndexOf(kernelNames, noiseTexture.kernelName);
                    var newSelectedKernelIndex = EditorGUILayout.Popup("Kernel", selectedKernelIndex, kernelNames);
                    if (newSelectedKernelIndex != selectedKernelIndex)
                    {
                        noiseTexture.kernelName = kernelNames[newSelectedKernelIndex];
                        noiseTexture.computeThreads = noiseTexture.kernelData[noiseTexture.kernelName];
                    }
                }

                if (noiseTexture.rwTextures.Count > 0)
                {
                    // Draw a dropdown to select the RWTexture
                    var rwTextureNames = noiseTexture.rwTextures.ToArray();
                    var selectedRWTextureIndex = Array.IndexOf(rwTextureNames, noiseTexture.rwTexture.name);
                    var newSelectedRWTextureIndex = EditorGUILayout.Popup("RWTexture", selectedRWTextureIndex, rwTextureNames);
                    if (newSelectedRWTextureIndex != selectedRWTextureIndex)
                    {
                        noiseTexture.rwTexture.name = rwTextureNames[newSelectedRWTextureIndex];
                    }
                }
            }

            if (GUILayout.Button("Generate"))
            {
                foreach (var nt in targets)
                {
                    var noiseTexture = nt as NoiseTexture2D;
                    if (noiseTexture == null)
                        continue;
                    
                    noiseTexture.CreateRenderTexture();
                    noiseTexture.SetParameters();
                    noiseTexture.SetTexture();
                    noiseTexture.GenerateTexture();
                    noiseTexture.SaveAsset();
                }
            }
        }
    }
}
