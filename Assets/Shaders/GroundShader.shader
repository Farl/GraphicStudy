// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/GroundShader" {
	Properties{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	}
		SubShader{
		Pass{

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"

		sampler2D _MainTex;

	struct v2f {
		float4 pos : SV_POSITION;
		float2 uv1 : TEXCOORD0;
	};

	float4 _MainTex_ST;

	v2f vert(appdata_full v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv1 = TRANSFORM_TEX(v.texcoord, _MainTex);
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		float4 c1 = tex2D(_MainTex, i.uv1);

		return c1;
	}
		ENDCG

	}
	}
}