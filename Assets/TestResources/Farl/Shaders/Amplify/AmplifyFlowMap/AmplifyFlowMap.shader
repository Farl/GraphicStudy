// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifyFlowMap"
{
	Properties
	{
		[Toggle(_USEHEIGHTMAP_ON)] _UseHeightMap("Use Height Map", Float) = 0
		_MainTex("Main Tex", 2D) = "white" {}
		[Header(FlowMap)]
		[Header(NormalCreate)]
		[Normal]_BumpTex("Normal Map", 2D) = "bump" {}
		_FlowMap("Flow Map", 2D) = "bump" {}
		_FlowStrength("Flow Strength", Float) = 0
		_NormalCreateStrength("Normal Create Strength", Float) = 2
		_NormalCreateOffset("Normal Create Offset", Float) = 0.5
		_TimeScale("Time Scale", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature _USEHEIGHTMAP_ON
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _BumpTex;
		uniform float4 _BumpTex_ST;
		uniform sampler2D _FlowMap;
		uniform float4 _FlowMap_ST;
		uniform float _NormalCreateOffset;
		uniform float _NormalCreateStrength;
		uniform float _TimeScale;
		uniform float _FlowStrength;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BumpTex = i.uv_texcoord * _BumpTex_ST.xy + _BumpTex_ST.zw;
			float2 uv_FlowMap = i.uv_texcoord * _FlowMap_ST.xy + _FlowMap_ST.zw;
			float2 temp_output_2_0_g62 = uv_FlowMap;
			float temp_output_25_0_g62 = ( pow( _NormalCreateOffset , 3 ) * 0.1 );
			float2 appendResult8_g62 = (float2(( temp_output_2_0_g62.x + temp_output_25_0_g62 ) , temp_output_2_0_g62.y));
			float4 tex2DNode14_g62 = tex2D( _FlowMap, temp_output_2_0_g62 );
			float temp_output_4_0_g62 = _NormalCreateStrength;
			float3 appendResult13_g62 = (float3(1 , 0 , ( ( tex2D( _FlowMap, appendResult8_g62 ).g - tex2DNode14_g62.g ) * temp_output_4_0_g62 )));
			float2 appendResult9_g62 = (float2(temp_output_2_0_g62.x , ( temp_output_2_0_g62.y + temp_output_25_0_g62 )));
			float3 appendResult16_g62 = (float3(0 , 1 , ( ( tex2D( _FlowMap, appendResult9_g62 ).g - tex2DNode14_g62.g ) * temp_output_4_0_g62 )));
			float3 normalizeResult22_g62 = normalize( cross( appendResult13_g62 , appendResult16_g62 ) );
			#ifdef _USEHEIGHTMAP_ON
				float3 staticSwitch36_g61 = normalizeResult22_g62;
			#else
				float3 staticSwitch36_g61 = UnpackNormal( tex2D( _FlowMap, uv_FlowMap ) );
			#endif
			float mulTime7_g61 = _Time.y * _TimeScale;
			float temp_output_8_0_g61 = frac( mulTime7_g61 );
			float temp_output_29_0_g61 = _FlowStrength;
			float4 lerpResult26_g61 = lerp( tex2D( _BumpTex, ( float3( uv_BumpTex ,  0.0 ) + ( staticSwitch36_g61 * temp_output_8_0_g61 * temp_output_29_0_g61 ) ).xy ) , tex2D( _BumpTex, ( float3( uv_BumpTex ,  0.0 ) + ( staticSwitch36_g61 * frac( ( mulTime7_g61 + 0.5 ) ) * temp_output_29_0_g61 ) ).xy ) , ( abs( ( -temp_output_8_0_g61 + 0.5 ) ) * 2.0 ));
			float3 normal80 = UnpackNormal( lerpResult26_g61 );
			o.Normal = normal80;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 temp_output_2_0_g64 = uv_FlowMap;
			float temp_output_25_0_g64 = ( pow( _NormalCreateOffset , 3 ) * 0.1 );
			float2 appendResult8_g64 = (float2(( temp_output_2_0_g64.x + temp_output_25_0_g64 ) , temp_output_2_0_g64.y));
			float4 tex2DNode14_g64 = tex2D( _FlowMap, temp_output_2_0_g64 );
			float temp_output_4_0_g64 = _NormalCreateStrength;
			float3 appendResult13_g64 = (float3(1 , 0 , ( ( tex2D( _FlowMap, appendResult8_g64 ).g - tex2DNode14_g64.g ) * temp_output_4_0_g64 )));
			float2 appendResult9_g64 = (float2(temp_output_2_0_g64.x , ( temp_output_2_0_g64.y + temp_output_25_0_g64 )));
			float3 appendResult16_g64 = (float3(0 , 1 , ( ( tex2D( _FlowMap, appendResult9_g64 ).g - tex2DNode14_g64.g ) * temp_output_4_0_g64 )));
			float3 normalizeResult22_g64 = normalize( cross( appendResult13_g64 , appendResult16_g64 ) );
			#ifdef _USEHEIGHTMAP_ON
				float3 staticSwitch36_g63 = normalizeResult22_g64;
			#else
				float3 staticSwitch36_g63 = UnpackNormal( tex2D( _FlowMap, uv_FlowMap ) );
			#endif
			float mulTime7_g63 = _Time.y * _TimeScale;
			float temp_output_8_0_g63 = frac( mulTime7_g63 );
			float temp_output_29_0_g63 = _FlowStrength;
			float4 lerpResult26_g63 = lerp( tex2D( _MainTex, ( float3( uv_MainTex ,  0.0 ) + ( staticSwitch36_g63 * temp_output_8_0_g63 * temp_output_29_0_g63 ) ).xy ) , tex2D( _MainTex, ( float3( uv_MainTex ,  0.0 ) + ( staticSwitch36_g63 * frac( ( mulTime7_g63 + 0.5 ) ) * temp_output_29_0_g63 ) ).xy ) , ( abs( ( -temp_output_8_0_g63 + 0.5 ) ) * 2.0 ));
			float4 color17 = lerpResult26_g63;
			o.Albedo = color17.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
281;572;1666;974;4408.77;308.2237;1.63949;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;67;-3714.886,274.9777;Float;True;Property;_BumpTex;Normal Map;1;1;[Normal];Create;False;0;0;False;0;None;4b8d081e9d114c7f1100f5ab44295342;True;bump;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;63;-3768.338,-143.6013;Float;True;Property;_FlowMap;Flow Map;2;0;Create;True;0;0;False;0;None;aa2d6aee3ae75ad4caa9cc051bef46a0;False;bump;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-3734.827,59.12391;Float;False;Property;_FlowStrength;Flow Strength;3;0;Create;True;0;0;False;0;0;0.17;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-3719.921,127.8677;Float;False;Property;_TimeScale;Time Scale;4;0;Create;True;0;0;False;0;1;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;111;-3324.439,184.6382;Float;False;FlowMap;0;;61;2217becc26828db4ab706ea4a37b9140;0;4;28;SAMPLER2D;;False;35;SAMPLER2D;;False;29;FLOAT;0.1;False;30;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;79;-3740.468,-336.8338;Float;True;Property;_MainTex;Main Tex;0;0;Create;True;0;0;False;0;None;a9f953c7353804247b8c3ed6e1c46a2e;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.FunctionNode;112;-3334.041,-219.1525;Float;False;FlowMap;0;;63;2217becc26828db4ab706ea4a37b9140;0;4;28;SAMPLER2D;;False;35;SAMPLER2D;;False;29;FLOAT;0.1;False;30;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;77;-3010.873,245.6374;Float;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;18;-217.6492,-36.02423;Float;False;17;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-2737.331,259.4302;Float;True;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;-2980.288,-215.8995;Float;True;color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;-240.1474,122.6714;Float;False;80;0;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/Farl/Amplify/AmplifyFlowMap;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;111;28;67;0
WireConnection;111;35;63;0
WireConnection;111;29;41;0
WireConnection;111;30;10;0
WireConnection;112;28;79;0
WireConnection;112;35;63;0
WireConnection;112;29;41;0
WireConnection;112;30;10;0
WireConnection;77;0;111;0
WireConnection;80;0;77;0
WireConnection;17;0;112;0
WireConnection;0;0;18;0
WireConnection;0;1;69;0
ASEEND*/
//CHKSM=73CD4FDFB1DB44F72ABBDCB1BDBE90D0D6FCE394