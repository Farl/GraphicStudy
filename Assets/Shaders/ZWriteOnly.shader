Shader "Farl/ZWriteOnly" {
	Properties{
	}

	SubShader{
		//Tags{ "Queue" = "Background" }
		//Tags{ "Queue" = "Geometry" }

		Tags{ "Queue" = "AlphaTest-1" }

		//Tags{ "Queue" = "AlphaTest" }
		//Tags{ "Queue" = "Transparent" }
		//Tags{ "Queue" = "Overlay" }

		Offset 0, 1
		Pass
		{
			Name "ShaderCaster"
			Tags{ "LightMode" = "ShadowCaster" }

			ZWrite On
			ZTest LEqual
			ColorMask 0
			Lighting Off
		}

	}
	Fallback "Transparent/Cutout/VertexLit"
}