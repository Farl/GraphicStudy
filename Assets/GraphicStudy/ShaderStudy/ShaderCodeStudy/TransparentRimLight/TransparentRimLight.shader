﻿Shader "Custom/Farl/TransparentRimLight" {
	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
		_RimColor("Rim Color", Color) = (0.26,0.19,0.16,0.0)
		_RimPower("Rim Power", Range(0.5,8.0)) = 3.0
	}

	SubShader{
		//Tags{ "Queue" = "Background" }
		//Tags{ "Queue" = "Geometry" }

		//Tags{ "Queue" = "AlphaTest-1" }
		//Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }

		Tags{ "Queue" = "AlphaTest" }
		//Tags{ "Queue" = "Transparent" }
		//Tags{ "Queue" = "Overlay" }

		//Offset 0, 1
		Pass
		{
			Name "ShaderCaster"
			Tags{ "LightMode" = "ShadowCaster" }

			ZWrite On
			ZTest LEqual
			ColorMask 0
			Lighting Off
		}
		
		//Offset 0, 0

		Pass
		{
			Name "RimLight"
			// Now render color channel
			ZWrite Off
			ZTest LEqual
			ColorMask RGBA
			Blend SrcAlpha OneMinusSrcAlpha
			Lighting Off

			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				sampler2D _MainTex;
				fixed4 _Color;
				fixed4 _RimColor;
				fixed _RimPower;
				
				struct v2f {
					float2 uv : TEXCOORD0;
					fixed4 vertex : SV_POSITION;
					fixed4 color : COLOR;
				};

				v2f vert(appdata_full v) {
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);

					// Get view direction
					fixed3 viewDir = normalize(ObjSpaceViewDir(v.vertex));

					// 越是面向camera的vertex在dot計算後會獲得越大的計算結果
					fixed dotProduct = dot(v.normal, viewDir);

					// smoothstep用法同lerp, 但其曲線在頭尾都會趨緩

					fixed rimFactor = pow((1 - smoothstep(0.5, 1, dotProduct)), _RimPower);
					o.color = _RimColor * rimFactor * v.color;
					o.color.a = rimFactor * v.color.a;
					o.uv = v.texcoord;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target{
					fixed4 col = _Color * tex2D(_MainTex, i.uv);
					return col * i.color;
				}
			ENDCG
		}

	}
	Fallback "Transparent/Cutout/VertexLit"
}