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
			float2 temp_output_2_0_g30 = uv_FlowMap;
			float temp_output_25_0_g30 = ( pow( _NormalCreateOffset , 3 ) * 0.1 );
			float2 appendResult8_g30 = (float2(( temp_output_2_0_g30.x + temp_output_25_0_g30 ) , temp_output_2_0_g30.y));
			float4 tex2DNode14_g30 = tex2D( _FlowMap, temp_output_2_0_g30 );
			float temp_output_4_0_g30 = _NormalCreateStrength;
			float3 appendResult13_g30 = (float3(1 , 0 , ( ( tex2D( _FlowMap, appendResult8_g30 ).g - tex2DNode14_g30.g ) * temp_output_4_0_g30 )));
			float2 appendResult9_g30 = (float2(temp_output_2_0_g30.x , ( temp_output_2_0_g30.y + temp_output_25_0_g30 )));
			float3 appendResult16_g30 = (float3(0 , 1 , ( ( tex2D( _FlowMap, appendResult9_g30 ).g - tex2DNode14_g30.g ) * temp_output_4_0_g30 )));
			float3 normalizeResult22_g30 = normalize( cross( appendResult13_g30 , appendResult16_g30 ) );
			#ifdef _USEHEIGHTMAP_ON
				float4 staticSwitch36_g29 = float4( (normalizeResult22_g30).xy, 0.0 , 0.0 );
			#else
				float4 staticSwitch36_g29 = tex2D( _FlowMap, uv_FlowMap );
			#endif
			float2 _Vector0 = float2(1,1);
			float mulTime7_g29 = _Time.y * _TimeScale;
			float temp_output_8_0_g29 = frac( mulTime7_g29 );
			float temp_output_29_0_g29 = _FlowStrength;
			float4 lerpResult26_g29 = lerp( tex2D( _BumpTex, ( float4( uv_BumpTex, 0.0 , 0.0 ) + ( (float4( -_Vector0, 0.0 , 0.0 ) + (staticSwitch36_g29 - float4( 0,0,0,0 )) * (float4( _Vector0, 0.0 , 0.0 ) - float4( -_Vector0, 0.0 , 0.0 )) / (float4( 1,1,1,1 ) - float4( 0,0,0,0 ))) * temp_output_8_0_g29 * temp_output_29_0_g29 ) ).rg ) , tex2D( _BumpTex, ( float4( uv_BumpTex, 0.0 , 0.0 ) + ( (float4( -_Vector0, 0.0 , 0.0 ) + (staticSwitch36_g29 - float4( 0,0,0,0 )) * (float4( _Vector0, 0.0 , 0.0 ) - float4( -_Vector0, 0.0 , 0.0 )) / (float4( 1,1,1,1 ) - float4( 0,0,0,0 ))) * frac( ( mulTime7_g29 + 0.5 ) ) * temp_output_29_0_g29 ) ).rg ) , ( abs( ( -temp_output_8_0_g29 + 0.5 ) ) * 2.0 ));
			float3 normal80 = UnpackNormal( lerpResult26_g29 );
			o.Normal = normal80;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 temp_output_2_0_g32 = uv_FlowMap;
			float temp_output_25_0_g32 = ( pow( _NormalCreateOffset , 3 ) * 0.1 );
			float2 appendResult8_g32 = (float2(( temp_output_2_0_g32.x + temp_output_25_0_g32 ) , temp_output_2_0_g32.y));
			float4 tex2DNode14_g32 = tex2D( _FlowMap, temp_output_2_0_g32 );
			float temp_output_4_0_g32 = _NormalCreateStrength;
			float3 appendResult13_g32 = (float3(1 , 0 , ( ( tex2D( _FlowMap, appendResult8_g32 ).g - tex2DNode14_g32.g ) * temp_output_4_0_g32 )));
			float2 appendResult9_g32 = (float2(temp_output_2_0_g32.x , ( temp_output_2_0_g32.y + temp_output_25_0_g32 )));
			float3 appendResult16_g32 = (float3(0 , 1 , ( ( tex2D( _FlowMap, appendResult9_g32 ).g - tex2DNode14_g32.g ) * temp_output_4_0_g32 )));
			float3 normalizeResult22_g32 = normalize( cross( appendResult13_g32 , appendResult16_g32 ) );
			#ifdef _USEHEIGHTMAP_ON
				float4 staticSwitch36_g31 = float4( (normalizeResult22_g32).xy, 0.0 , 0.0 );
			#else
				float4 staticSwitch36_g31 = tex2D( _FlowMap, uv_FlowMap );
			#endif
			float mulTime7_g31 = _Time.y * _TimeScale;
			float temp_output_8_0_g31 = frac( mulTime7_g31 );
			float temp_output_29_0_g31 = _FlowStrength;
			float4 lerpResult26_g31 = lerp( tex2D( _MainTex, ( float4( uv_MainTex, 0.0 , 0.0 ) + ( (float4( -_Vector0, 0.0 , 0.0 ) + (staticSwitch36_g31 - float4( 0,0,0,0 )) * (float4( _Vector0, 0.0 , 0.0 ) - float4( -_Vector0, 0.0 , 0.0 )) / (float4( 1,1,1,1 ) - float4( 0,0,0,0 ))) * temp_output_8_0_g31 * temp_output_29_0_g31 ) ).rg ) , tex2D( _MainTex, ( float4( uv_MainTex, 0.0 , 0.0 ) + ( (float4( -_Vector0, 0.0 , 0.0 ) + (staticSwitch36_g31 - float4( 0,0,0,0 )) * (float4( _Vector0, 0.0 , 0.0 ) - float4( -_Vector0, 0.0 , 0.0 )) / (float4( 1,1,1,1 ) - float4( 0,0,0,0 ))) * frac( ( mulTime7_g31 + 0.5 ) ) * temp_output_29_0_g31 ) ).rg ) , ( abs( ( -temp_output_8_0_g31 + 0.5 ) ) * 2.0 ));
			float4 color17 = lerpResult26_g31;
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
311;600;1666;974;4439.434;348.2585;1.692573;True;False
Node;AmplifyShaderEditor.RangedFloatNode;10;-3719.921,127.8677;Float;False;Property;_TimeScale;Time Scale;4;0;Create;True;0;0;False;0;1;0.12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;67;-3714.886,274.9777;Float;True;Property;_BumpTex;Normal Map;1;1;[Normal];Create;False;0;0;False;0;None;e08c295755c0885479ad19f518286ff2;True;bump;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-3734.827,59.12391;Float;False;Property;_FlowStrength;Flow Strength;3;0;Create;True;0;0;False;0;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;63;-3768.338,-143.6013;Float;True;Property;_FlowMap;Flow Map;2;0;Create;True;0;0;False;0;None;68386fc9897223346a683105b4dc1662;False;bump;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.FunctionNode;95;-3324.439,184.6382;Float;False;FlowMap;0;;29;2217becc26828db4ab706ea4a37b9140;0;4;28;SAMPLER2D;;False;35;SAMPLER2D;;False;29;FLOAT;0.1;False;30;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;79;-3740.468,-336.8338;Float;True;Property;_MainTex;Main Tex;0;0;Create;True;0;0;False;0;None;a9f953c7353804247b8c3ed6e1c46a2e;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.FunctionNode;96;-3334.041,-219.1525;Float;False;FlowMap;0;;31;2217becc26828db4ab706ea4a37b9140;0;4;28;SAMPLER2D;;False;35;SAMPLER2D;;False;29;FLOAT;0.1;False;30;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;77;-3010.873,245.6374;Float;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;18;-217.6492,-36.02423;Float;False;17;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-2737.331,259.4302;Float;True;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;-2980.288,-215.8995;Float;True;color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;-240.1474,122.6714;Float;False;80;0;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/Farl/Amplify/AmplifyFlowMap;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;95;28;67;0
WireConnection;95;35;63;0
WireConnection;95;29;41;0
WireConnection;95;30;10;0
WireConnection;96;28;79;0
WireConnection;96;35;63;0
WireConnection;96;29;41;0
WireConnection;96;30;10;0
WireConnection;77;0;95;0
WireConnection;80;0;77;0
WireConnection;17;0;96;0
WireConnection;0;0;18;0
WireConnection;0;1;69;0
ASEEND*/
//CHKSM=DCD5E5CA0AF533C4D30EA82D7B47EDB5B1B50C68