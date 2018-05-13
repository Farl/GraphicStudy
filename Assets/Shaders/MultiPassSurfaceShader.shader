Shader "Custom/DoubleSided" {
	Properties{
		_MainTex("Base (RGB)", 2D) = "white" {}
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200
		// Render back faces first
		Cull Front
		CGPROGRAM
#pragma surface surf Lambert vertex:vert

		sampler2D _MainTex;

	struct Input {
		float2 uv_MainTex;
	};

	// Flip normal for back faces
	void vert(inout appdata_full v) {
		v.normal *= -1;
	}
	// Red back faces
	void surf(Input IN, inout SurfaceOutput o) {
		half4 c = tex2D(_MainTex, IN.uv_MainTex);
		o.Albedo = fixed3(1,0,0);
		o.Alpha = c.a;
	}
	ENDCG

		// Now render front faces
		Cull Back
		CGPROGRAM
#pragma surface surf Lambert

		sampler2D _MainTex;

	struct Input {
		float2 uv_MainTex;
	};
	// Green front faces
	void surf(Input IN, inout SurfaceOutput o) {
		half4 c = tex2D(_MainTex, IN.uv_MainTex);
		o.Albedo = fixed3(0,1,0);
		o.Alpha = c.a;
	}
	ENDCG


	}
		FallBack "Diffuse"
}