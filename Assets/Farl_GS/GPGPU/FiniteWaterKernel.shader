// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Wave propagation simulation using finite differences.
// See (f.ex.) http://www.uio.no/studier/emner/matnat/ifi/INF2340/v05/foiler/sim04.pdf
// for the model and equations.
// Reference: https://www.shadertoy.com/view/4sd3WB

Shader "Hidden/Farl/FiniteWaterKernel"
{
	Properties
	{
		_WaveParam ("Wave (Density, Damping Force, Speed, Damping", Vector) = (0, 0, 0, 0)
        _PositionBuffer ("-", 2D) = "white"
        //_VelocityBuffer ("-", 2D) = "gray"
	}

	CGINCLUDE
			
		#include "UnityCG.cginc"

		sampler2D _PositionBuffer;
		uniform float4 _PositionBuffer_TexelSize;
		//sampler2D _VelocityBuffer;

		float4 _WaveParam;
		float4 _ClickList[6];
		float4 _SimulationParameter;

		float4 encode01(float4 input, float maximum)
		{
			//return (clamp(input, -maximum, maximum) + maximum) / (2 * maximum);
			return input;
		}

		float4 decode01(float4 input, float maximum)
		{
			//return input * (2 * maximum) - maximum;
			return input;
		}

		struct v2f 
		{
			float4 pos  : POSITION;
			float2 uv   : TEXCOORD0;
			float3 wpos : TEXCOORD1;
			float3 vpos : TEXCOORD2;
		};

		float4 updatePosition(v2f_img i) : SV_Target
		{
   			float4 p = /*decode01*/(tex2D(_PositionBuffer, i.uv)/*, 1*/);
   			//float4 v = decode01(tex2D(_VelocityBuffer, i.uv), 10);

			float dt = _SimulationParameter.x;	//1 / 60.0;

			//p.xyz = p.xyz + v.xyz * dt;

			for (int j = 0; j < 6; j++)
			{
				if (_ClickList[j].w > 0)
				{
					float radius = _ClickList[j].w;

					float2 r = _ClickList[j].xy - i.uv;
					float d = dot(r, r);
					float f = smoothstep(0, 1, saturate((radius - length(r)) / radius));
					//if (f > 0) {p.x = min(p.x, -f);}
					if (d < radius * radius)
					{
						p.x = 0.2 * f;
						p.y = 0;
					}
				}
			}

   			//p = encode01(p, 1);

			return p;
		}

		float4 defaultPosition(v2f_img i) : SV_Target
		{
			return float4(0.0, 0.0, 0.0, 0.0);
		}

		float4 updateVelocity(v2f_img i) : SV_Target
		{
			//float4 v = decode01(tex2D(_VelocityBuffer, i.uv), 10);

			//float dt = _SimulationParameter.x;	//1 / 60.0;


   			float h = max(_WaveParam.x, 1e-9);
			float k = _WaveParam.y;
   			float c = _WaveParam.z;
			//c *= (h / dt);

   			float4 p = tex2D(_PositionBuffer, i.uv);
   			float2 uvOffset = _PositionBuffer_TexelSize.xy;

			float u = p.y;	// old elevation
			float du = p.x;	// old velocity (du/dt)

			float f = tex2D(_PositionBuffer, i.uv + float2(uvOffset.x, 0)).y;
			f += tex2D(_PositionBuffer, i.uv + float2(-uvOffset.x, 0)).y;
			f += tex2D(_PositionBuffer, i.uv + float2(0, uvOffset.y)).y;
			f += tex2D(_PositionBuffer, i.uv + float2(0, -uvOffset.y)).y;
			
			//p = decode01(p, 1);
			//f = f * 2 * 1;	// scale with no offset

			//float3 acc = float3(0, ((0 - p.y) * k) + (pow(c, 2) * f / pow(h, 2)), 0);

   			float drag = _WaveParam.w;

   			//v.xyz = v.xyz + acc * dt;

   			//v *= drag;

   			//v = encode01(v, 10);

			//return v;

			f -= 4.0 * u;
			float cdh = min(0.5, pow(c, 2) / pow(h, 2));
			float nu = u + du + (0 - p.y) * k + cdh * f;
			//float nu = u + du + 0.5 * f;
			nu *= drag;

			return float4(nu - u, nu, 0, 0);
		}

		float4 defaultVelocity(v2f_img i) : SV_Target
		{
			return float4(0.0, 0.0, 0.0, 0.0);
		}

	ENDCG

	SubShader
	{
		Pass
		{
            CGPROGRAM
            #pragma target 3.0
			#pragma vertex vert_img
			#pragma fragment updatePosition

			ENDCG
		}
		Pass
		{
            CGPROGRAM
            #pragma target 3.0
			#pragma vertex vert_img
			#pragma fragment updateVelocity
			ENDCG
		}
		Pass
		{
            CGPROGRAM
            #pragma target 3.0
			#pragma vertex vert_img
			#pragma fragment defaultPosition
			ENDCG
		}
		Pass
		{
            CGPROGRAM
            #pragma target 3.0
			#pragma vertex vert_img
			#pragma fragment defaultVelocity
			ENDCG
		}
	}
}