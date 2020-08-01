Shader "Custom/Farl/ConeFog"
{
	Properties
	{
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" { }
        [HDR] _Color ("Color", Color) = (1, 1, 1, 1)

		[Header(Noise)]
		_NoiseTex ("Noise Map", 3D) = "white" { }
		_NoiseScale ("Noise Scale", Vector) = (1, 1, 1)
		_NoiseDensity ("Noise Density (Bias, Scale, Power)", Vector) = (0, 1, 1)
		_NoiseSpeed ("Noise Speed", Vector) = (0, 0, 0)

		[Header(Raymarching)]
		_StepSize ("Step Size", Float) = 0.1
		[Integer]
		_Sample ("Sample", Int) = 16

		[Header(Signed Distance Field)]
		_Edge ("Edge", Float) = 0
		_EdgeFallOff ("Edge Fall Off", Float) = 0
		_Center ("Center", Vector) = (0, 0, 0)
		_Size ("Size", Vector) = (1, 1, 1)

		[Header(Lighting)]
		_LightDir ("Light Dir", Vector) = (0, 1, 0)
		_LightSample ("Light Sample", Int) = 16
		_LightStepSize ("Light Step Size", Float) = 0.1
		_LightIntensity ("Light Intensity", Float) = 1
		_LightAmbient ("Light Ambient", Float) = 0

		[Header(Debug)]
		_DebugStep ("Debug Step", Float) = 0.1
	}
	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			Cull Off
			Name "Test"
			ZWrite On

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

            // make fog work
            #pragma multi_compile_fog

			#include "UnityCG.cginc"

			struct v2f
			{
                float2 uv : TEXCOORD0Falloff;
                float3 worldPos : TEXCOORD2;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
			};

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler3D _NoiseTex;
            float3 _NoiseScale;
            float3 _NoiseDensity;
            float3 _NoiseSpeed;

            float _StepSize;
            int _Sample;

            float _Edge;
            float _EdgeFallOff;

            float3 _Size;
            float3 _Center;
            float3 _Size2;
            float3 _Center2;

            float3 _LightDir;
            int _LightSample;
            float _LightStepSize;
            float _LightIntensity;
            float _LightAmbient;

            float _DebugStep;

			v2f vert( appdata_full v )
			{
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
			}

			float sdf_sphere(float3 p, float3 center, float radius)
			{
				return distance(p, center) - radius;
			}

			float vmax(float3 v)
			{
				return max(max(v.x, v.y), v.z);
			}

			float sdf_boxcheap(float3 p, float3 c, float3 s)
			{
				return vmax(abs(p-c) - s);
			}

			float sdf_cylinder(float3 p, float3 c)
			{
				return length(p.xz - c.xy) - c.z;
			}

			float sdf_cone( float3 p, float3 c, float3 s )
			{
			    float2 q = float2( length(p.xz - c.xz), p.y - c.y );
			    float d1 = -(p.y - c.y) - s.z;
			    float d2 = max( dot(q, s.xy), (p.y - c.y));
			    return length(max(float2(d1, d2), 0.0)) + min(max(d1, d2), 0.0);
			}

			float sdf_union(float sdf1, float sdf2)
			{
				return min(sdf1, sdf2);
			}

			float sdf_intersection(float sdf1, float sdf2)
			{
				return max(sdf1, sdf2);
			}

			float sdf_difference(float sdf1, float sdf2)
			{
				return max(sdf1, -sdf2);
			}

			float sdf_lerp(float sdf1, float sdf2, float t)
			{
				return sdf1 * (1 - t) + sdf2 * t;
			}

			float sdf(float3 worldPos)
			{
				return sdf_cone(worldPos, _Center, _Size);
			}

			float sdfRange(float3 worldPos, float edge, float fallOff)
			{
				float v = sdf(worldPos) - edge + fallOff;
				if (fallOff == 0)
				{
					if (v > 0)
						return 1;
					else
						return v;
				}
				fallOff = abs(fallOff);
				return saturate(v / fallOff);
			}

			float4 density(float4 v, float bias, float scale, float power)
			{
				return saturate(pow(v * scale, power) + float4(1,1,1,1) * bias);
			}

			float4 GetNoise(float3 p)
			{
				return density(tex3D(_NoiseTex, p * _NoiseScale + _NoiseSpeed * _Time), _NoiseDensity.x, _NoiseDensity.y, _NoiseDensity.z);
			}

			fixed4 frag( v2f IN) : SV_Target
			{
				fixed3 viewDir = UnityWorldSpaceViewDir( IN.worldPos );
				fixed3 cameraPos = IN.worldPos + viewDir;
				fixed3 worldViewDir = normalize(viewDir);

                // sample the texture
                fixed4 col = float4(0, 0, 0, 1);

                float4 cOut = float4(1, 1, 1, 0);
                float sOut = 0;

                //float3 startPos = cameraPos - ((_DebugStep * floor(length(viewDir) / _DebugStep + 0.5)) * worldViewDir);
                float3 startPos = IN.worldPos;

                float surfSDF = sdf(startPos);
                if (surfSDF > _Edge)
                	startPos = startPos - worldViewDir * surfSDF;
                //startPos = IN.worldPos;

                float3 q = startPos;

                for (int i = _Sample - 1; i >= 0; i--)
                {
                	float3 p = startPos - i * worldViewDir * _StepSize;
                	q = p;

                	sOut = 0;
                	for (int j = 1; j <= _LightSample; j++)
                	{
                		if (sOut < 1)
                		{
	                		q = p + j * normalize(_LightDir) * _LightStepSize;
	                		float4 sIn = GetNoise(q);
	                		sIn.a *= 1 - saturate(sdfRange(q, _Edge, _EdgeFallOff));

	                		sOut = sOut * (1 - sIn.a) + 1 * (sIn.a);
                		}
                	}
                	sOut = sOut;

                	float4 cIn = GetNoise(p);
                	cIn.a *= 1 - saturate(sdfRange(p, _Edge, _EdgeFallOff));
                	cOut = cOut * (1 - cIn.a) + float4(float3(1, 1, 1) * clamp((1 - sOut), _LightAmbient, 1) * _LightIntensity, 1) * (cIn.a);
                }

                col = cOut;

                // apply fog
                UNITY_APPLY_FOG(IN.fogCoord, col);

                return col;
			}
			ENDCG
		}
	}
}
