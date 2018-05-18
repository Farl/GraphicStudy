// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "Farl/DitherOpacityStandard" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_BumpMap("Normal Map", 2D) = "bump" {}
		
		_Alpha("Alpha", Range(0,1)) = 0.1
		_AlphaGridTex("Alpha Grid Texture", 2D) = "white" {}
		_GridSize("Grid Size", Range(1,1024)) = 16
		_RimPower("Rim Power", Range(0.5,8.0)) = 3.0
		
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		//Tags{ "RenderType" = "Transparent" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard addshadow fullforwardshadows vertex:vert


		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BumpMap;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float4 screenPos;
			float3 viewDir;
			float3 normal;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		
		float _Alpha;
		sampler2D _AlphaGridTex;
		float4 _AlphaGridTex_ST;
		fixed _RimPower;
		int _GridSize;
		
		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
		// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			//float4 hpos = UnityObjectToClipPos(v.vertex);
			//o.screenPos = ComputeScreenPos(hpos);
			//o.screenPos.xy *= _ScreenParams.xy / 16;	//此处不能先除w，会导致插值精度不够

			//o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
		}

		void surf (Input IN, inout SurfaceOutputStandard o)
		{
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;

			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;

			IN.screenPos.xy *= _ScreenParams.xy / _GridSize;
			float gridAlpha = tex2Dproj(_AlphaGridTex, IN.screenPos).r;

			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));

			//边缘颜色    
			half rim = saturate(dot(normalize(IN.viewDir), o.Normal));
			//计算出边缘颜色强度系数
			half finalRim = pow(rim, _RimPower) * gridAlpha + 0.01;
			
			clip( (_Alpha - finalRim) );
			
			//o.Alpha = c.a;
		}
		
		ENDCG
	}
	//Fallback "Legacy Shaders/Transparent/Cutout/VertexLit"
	Fallback "Standard"
}
