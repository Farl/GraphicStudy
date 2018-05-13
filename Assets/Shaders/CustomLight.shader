Shader "Farl/CustomLight" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_NdotLightPow("Ndot Lighting Power ", Range(0,20)) = 1
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }
		cull off ZWrite On
		CGPROGRAM
#pragma surface surf StandardCustom fullforwardshadows
#include "UnityPBSLighting.cginc"

		sampler2D _MainTex;

	struct Input {
		float2 uv_MainTex;
	};

	half _Glossiness,_Metallic,_NdotLightPow;
	fixed4 _Color;

	UNITY_INSTANCING_CBUFFER_START(Props)
		UNITY_INSTANCING_CBUFFER_END

	void surf(Input IN, inout SurfaceOutputStandard o) {
		fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
		o.Albedo = c.rgb;
		o.Metallic = _Metallic;
		o.Smoothness = _Glossiness;
		o.Alpha = c.a;
	}

	half4 LightingStandardCustom(SurfaceOutputStandard s, half3 viewDir, UnityGI gi) {
		half NdotL = saturate(dot(s.Normal, 1 - gi.light.dir));
		half NdotL2 = saturate(dot(s.Normal, 1 - viewDir));
		half4 c = LightingStandard(s,viewDir,gi);
		//return c + c * NdotL * _NdotLightPow;
		return c + (1,0,0,1) * NdotL2 * _NdotLightPow;
	}

	inline void LightingStandardCustom_GI(SurfaceOutputStandard s,UnityGIInput data,inout UnityGI gi)
	{
		LightingStandard_GI(s, data, gi);
	}
	ENDCG
	}
	FallBack "Diffuse"
}