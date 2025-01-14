// Made with Amplify Shader Editor v1.9.3.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/GPGPU/RTClick Debug"
{
	Properties
	{
		_BumpTex("Bump Tex", 2D) = "bump" {}
		_Albedo("Albedo", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Glossiness("Glossiness", Range( 0 , 1)) = 0
		_MainTex("Main Tex", 2D) = "white" {}
		_NormalScale("Normal Scale", Float) = 1
		_NormalStrength("Normal Strength", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting keepalpha exclude_path:deferred 
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _Albedo;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _BumpTex;
		uniform float4 _BumpTex_ST;
		uniform float _NormalScale;
		uniform float _NormalStrength;
		float4 _MainTex_TexelSize;
		uniform float _Metallic;
		uniform float _Glossiness;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			SurfaceOutputStandard s9 = (SurfaceOutputStandard ) 0;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 uv_BumpTex = i.uv_texcoord * _BumpTex_ST.xy + _BumpTex_ST.zw;
			float2 temp_output_2_0_g1 = uv_MainTex;
			float2 break6_g1 = temp_output_2_0_g1;
			float temp_output_25_0_g1 = ( pow( 0.5 , 3.0 ) * 0.1 );
			float2 appendResult8_g1 = (float2(( break6_g1.x + temp_output_25_0_g1 ) , break6_g1.y));
			float4 tex2DNode14_g1 = tex2D( _MainTex, temp_output_2_0_g1 );
			float temp_output_4_0_g1 = _NormalStrength;
			float3 appendResult13_g1 = (float3(1.0 , 0.0 , ( ( tex2D( _MainTex, appendResult8_g1 ).g - tex2DNode14_g1.g ) * temp_output_4_0_g1 )));
			float2 appendResult9_g1 = (float2(break6_g1.x , ( break6_g1.y + temp_output_25_0_g1 )));
			float3 appendResult16_g1 = (float3(0.0 , 1.0 , ( ( tex2D( _MainTex, appendResult9_g1 ).g - tex2DNode14_g1.g ) * temp_output_4_0_g1 )));
			float3 normalizeResult22_g1 = normalize( cross( appendResult13_g1 , appendResult16_g1 ) );
			float3 waveNormal24 = normalizeResult22_g1;
			float3 normalVec29 = ( UnpackScaleNormal( tex2D( _BumpTex, uv_BumpTex ), _NormalScale ) + waveNormal24 );
			s9.Albedo = tex2D( _Albedo, ( float3( uv_MainTex ,  0.0 ) + ( normalVec29 * _MainTex_TexelSize.x ) ).xy ).rgb;
			s9.Normal = normalize( WorldNormalVector( i , normalVec29 ) );
			s9.Emission = float3( 0,0,0 );
			s9.Metallic = _Metallic;
			s9.Smoothness = _Glossiness;
			s9.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi9 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g9 = UnityGlossyEnvironmentSetup( s9.Smoothness, data.worldViewDir, s9.Normal, float3(0,0,0));
			gi9 = UnityGlobalIllumination( data, s9.Occlusion, s9.Normal, g9 );
			#endif

			float3 surfResult9 = LightingStandard ( s9, viewDir, gi9 ).rgb;
			surfResult9 += s9.Emission;

			#ifdef UNITY_PASS_FORWARDADD//9
			surfResult9 -= s9.Emission;
			#endif//9
			c.rgb = surfResult9;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19303
Node;AmplifyShaderEditor.TexturePropertyNode;21;-1986.501,-199.3057;Float;True;Property;_MainTex;Main Tex;6;0;Create;False;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TextureCoordinatesNode;22;-1707.227,-296.8336;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;23;-1011.507,282.3299;Float;False;Property;_NormalStrength;Normal Strength;8;0;Create;True;0;0;0;False;0;False;1;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;20;-739.9722,81.26657;Inherit;False;NormalCreate;0;;1;e12f7ae19d416b942820e3932b56220f;0;4;1;SAMPLER2D;;False;2;FLOAT2;0,0;False;3;FLOAT;0.5;False;4;FLOAT;2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1449.305,-413.2848;Float;False;Property;_NormalScale;Normal Scale;7;0;Create;False;0;0;0;False;0;False;1;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-461.8186,81.13995;Float;False;waveNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;12;-1249.502,-482.0201;Inherit;True;Property;_BumpTex;Bump Tex;2;0;Create;True;0;0;0;False;0;False;-1;None;b3d940e75e1f5d24684cd93a2758e1bf;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;26;-1154.62,-242.0606;Inherit;False;24;waveNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-897.9619,-375.3321;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-735.0333,-352.0338;Float;False;normalVec;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-1764.136,-711.8063;Inherit;False;29;normalVec;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexelSizeNode;34;-1766.244,-606.434;Inherit;False;-1;1;0;SAMPLER2D;;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-1579.735,-693.8931;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-1417.021,-706.8613;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;13;-1191.51,-745.5198;Inherit;True;Property;_Albedo;Albedo;3;0;Create;True;0;0;0;False;0;False;-1;None;a9f953c7353804247b8c3ed6e1c46a2e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;-722.9288,-164.5162;Float;False;Property;_Glossiness;Glossiness;5;0;Create;True;0;0;0;False;0;False;0;0.68;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-732.8263,-52.34346;Float;False;Property;_Metallic;Metallic;4;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;35;-1599.912,116.7243;Inherit;True;Property;_TextureSample3;Texture Sample 3;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomStandardSurface;9;-439.1969,-338.8025;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Custom/Farl/GPGPU/RTClick Debug;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;False;0;False;Opaque;;Geometry;ForwardOnly;0;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;22;2;21;0
WireConnection;20;1;21;0
WireConnection;20;2;22;0
WireConnection;20;4;23;0
WireConnection;24;0;20;0
WireConnection;12;5;28;0
WireConnection;27;0;12;0
WireConnection;27;1;26;0
WireConnection;29;0;27;0
WireConnection;34;0;21;0
WireConnection;33;0;32;0
WireConnection;33;1;34;1
WireConnection;30;0;22;0
WireConnection;30;1;33;0
WireConnection;13;1;30;0
WireConnection;35;0;21;0
WireConnection;35;1;22;0
WireConnection;9;0;13;0
WireConnection;9;1;29;0
WireConnection;9;3;14;0
WireConnection;9;4;15;0
WireConnection;0;13;9;0
ASEEND*/
//CHKSM=E2EC26F93E30BCA9AA7A8F103AB25115F2535A96