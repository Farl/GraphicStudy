// GPU Particle

Shader "Hidden/Farl/GPUParticle"
{
	Properties
	{
		_Click ("Click", Vector) = (0, 0, 0, 0)
        _PositionBuffer ("-", 2D) = "gray"
        _VelocityBuffer ("-", 2D) = "gray"
        _PositionRange ("Position Range", float) = 1
        _VelocityRange ("Velocity Range", float) = 5
	}

	CGINCLUDE
			
		#include "UnityCG.cginc"

		float4 _Click;
		sampler2D _PositionBuffer;
		uniform float4 _PositionBuffer_TexelSize;
		sampler2D _VelocityBuffer;
		float4 _ClickList[6];
        float _PositionRange;
        float _VelocityRange;

		struct v2f 
		{
			float4 pos  : POSITION;
			float2 uv   : TEXCOORD0;
			float3 wpos : TEXCOORD1;
			float3 vpos : TEXCOORD2;
		};

		float4 remapTo01(float4 v, float range)
		{
			return (clamp(v, -range, range) + range) / (2 * range);
		}

		float4 remapFrom01(float4 v, float range)
		{
			return (v - 0.5) * 2 * range;
		}

		float4 updatePosition(v2f_img i) : SV_Target
		{
   			float4 p = remapFrom01(tex2D(_PositionBuffer, i.uv), _PositionRange);
   			float4 v = remapFrom01(tex2D(_VelocityBuffer, i.uv), _VelocityRange);
			float dt = 1 / 60.0;

			p.xyz = p.xyz + v.xyz * dt;

			return remapTo01(p, _PositionRange);
		}

		float4 updateVelocity(v2f_img i) : SV_Target
		{
   			float4 v = remapFrom01(tex2D(_VelocityBuffer, i.uv), _VelocityRange);
			float dt = 1 / 60.0;

   			float4 p = (tex2D(_PositionBuffer, i.uv));
			float f = (tex2D(_PositionBuffer, saturate(i.uv + float2(1, 0) * _PositionBuffer_TexelSize.xy))).y;
			f += (tex2D(_PositionBuffer, saturate(i.uv + float2(-1, 0) * _PositionBuffer_TexelSize.xy))).y;
			f += (tex2D(_PositionBuffer, saturate(i.uv + float2(0, 1) * _PositionBuffer_TexelSize.xy))).y;
			f += (tex2D(_PositionBuffer, saturate(i.uv + float2(0, -1) * _PositionBuffer_TexelSize.xy))).y;
			f -= 4 * p.y;
			p = remapFrom01(p, _PositionRange);
			f = f * _PositionRange * 2;	// Only scale. Don't do offset

   			float2 origPos = (i.uv * 2 - 1);
   			float2 clickPos = (_Click.w >= 1)? (_Click.xy * 2 - 1): p.xz;

			float3 force = float3(0, 0, 0);
   			force.y = ((0 - p.y) * 30) + (pow(0.3, 2) * f / pow(0.02, 2));

   			float3 extraForce = float3(0, 0, 0);
   			if (_Click.w >= 1)
   			{
				float f = 1 / pow(length(clickPos - p.xz), 2);
				extraForce.y = -f;
				extraForce.xz = _PositionBuffer_TexelSize.xy * (p.xz - clickPos) * f * 5;
   			}

   			force.xz = (origPos - p.xz) * 20;

   			// Damping
   			v *= 0.97;

   			// Acc
   			v.xyz = v.xyz + (force + extraForce) * dt;

			return remapTo01(v, _VelocityRange);
		}


		float4 initPosition(v2f_img i) : SV_Target
		{
			return remapTo01(float4(i.uv.x * 2 - 1, 0, i.uv.y * 2 - 1, 0), _PositionRange);
		}


		float4 initVelocity(v2f_img i) : SV_Target
		{
			return remapTo01(float4(0, 0, 0, 0), _VelocityRange);
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
			#pragma fragment initPosition

			ENDCG
		}
		Pass
		{
            CGPROGRAM
            #pragma target 3.0
			#pragma vertex vert_img
			#pragma fragment initVelocity
			ENDCG
		}
	}
}