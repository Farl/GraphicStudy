// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// http://matthias-mueller-fischer.ch/talks/GDC2008.pdf
// https://www.youtube.com/watch?v=hswBi5wcqAA

Shader "Hidden/Farl/RTClick_v2"
{
	Properties
	{
		_WaveParam ("Wave (Density, Damping Force, Speed, Damping", Vector) = (0, 0, 0, 0)
        _PositionBuffer ("-", 2D) = "gray"
        _VelocityBuffer ("-", 2D) = "gray"
	}

	CGINCLUDE
			
		#include "UnityCG.cginc"

		sampler2D _PositionBuffer;
		uniform float4 _PositionBuffer_TexelSize;
		sampler2D _VelocityBuffer;

		float4 _WaveParam;
		float4 _ClickList[6];
		float4 _SimulationParameter;

		#define PositionEncodeMaximum 0.5
		#define VelocityEncodeMaximum 0.5

		float4 encode01(float4 input, float maximum)
		{
			return (clamp(input, -maximum, maximum) + maximum) / (2 * maximum);
		}

		float4 decode01(float4 input, float maximum)
		{
			return input * (2 * maximum) - maximum;
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
   			float4 p = decode01(tex2D(_PositionBuffer, i.uv), PositionEncodeMaximum);
   			float4 v = decode01(tex2D(_VelocityBuffer, i.uv), VelocityEncodeMaximum);

			float dt = _SimulationParameter.x;	//1 / 60.0;

			p.xyz = p.xyz + v.xyz * dt;

			float damping = _WaveParam.w;
			p.y *= damping;

			for (int j = 0; j < 6; j++)
			{
				if (_ClickList[j].w > 0)
				{
					float radius = _ClickList[j].w;
					float distance = length(_ClickList[j].xy - i.uv);
					if (distance < radius)
					{
						p.y = -0.5;
					}
				}
			}

   			p = encode01(p, PositionEncodeMaximum);

			return p;
		}

		float4 defaultPosition(v2f_img i) : SV_Target
		{
			//return float4(0.5, 0.5, 0.5, 0.5);
			return encode01(float4(0, 0, 0, 0), PositionEncodeMaximum);
		}

		float4 updateVelocity(v2f_img i) : SV_Target
		{
   			float4 v = decode01(tex2D(_VelocityBuffer, i.uv), VelocityEncodeMaximum);

			for (int j = 0; j < 6; j++)
			{
				if (_ClickList[j].w > 0)
				{
					float radius = _ClickList[j].w;
					float distance = length(_ClickList[j].xy - i.uv);
					if (distance < radius)
					{
						v.y = 0;
					}
				}
			}

			float dt = _SimulationParameter.x;	//1 / 60.0;

   			float h = max(_WaveParam.x, 1e-9);	// Density
			float k = _WaveParam.y;	// Damping force
   			float c = _WaveParam.z * ((h / dt) - 1e-9);	// Speed (0 <= c <= 1. c < h / dt) Information can only propagate 1 cell per time step

   			float4 p = tex2D(_PositionBuffer, i.uv);
   			float2 uvOffset = _PositionBuffer_TexelSize.xy;
			float f = tex2D(_PositionBuffer, i.uv + float2(uvOffset.x, 0)).y;
			f += tex2D(_PositionBuffer, i.uv + float2(-uvOffset.x, 0)).y;
			f += tex2D(_PositionBuffer, i.uv + float2(0, uvOffset.y)).y;
			f += tex2D(_PositionBuffer, i.uv + float2(0, -uvOffset.y)).y;
			f -= 4 * p.y;

			p = decode01(p, PositionEncodeMaximum);
			f = f * 2 * PositionEncodeMaximum;	// scale with no offset

			float damping = _WaveParam.w;
			float dampingForce = -p.y * k * damping;
			float3 acc = float3(0, (dampingForce + (c * c) * f / (h * h)), 0);

   			v.xyz = v.xyz + acc * dt;

   			v *= damping;

   			v = encode01(v, VelocityEncodeMaximum);

			return v;
		}

		float4 defaultVelocity(v2f_img i) : SV_Target
		{
			//return float4(0.5, 0.5, 0.5, 0.5);
			return encode01(float4(0, 0, 0, 0), VelocityEncodeMaximum);
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