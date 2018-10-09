// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifyFlowMap"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
		[Normal]_BumpTex("Normal Map", 2D) = "bump" {}
		_FlowMap("Flow Map", 2D) = "gray" {}
		_FlowStrength("Flow Strength", Float) = 0
		_TimeScale("Time Scale", Float) = 1
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _BumpTex;
		uniform sampler2D _FlowMap;
		uniform float4 _FlowMap_ST;
		uniform float _TimeScale;
		uniform float _FlowStrength;
		uniform float4 _BumpTex_ST;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _Metallic;
		uniform float _Smoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_FlowMap = i.uv_texcoord * _FlowMap_ST.xy + _FlowMap_ST.zw;
			float3 linearToGamma158 = LinearToGammaSpace( tex2D( _FlowMap, uv_FlowMap ).rgb );
			float mulTime7_g96 = _Time.y * _TimeScale;
			float temp_output_8_0_g96 = frac( mulTime7_g96 );
			float temp_output_29_0_g96 = _FlowStrength;
			float2 uv_BumpTex = i.uv_texcoord * _BumpTex_ST.xy + _BumpTex_ST.zw;
			float4 lerpResult26_g96 = lerp( tex2D( _BumpTex, ( ( (float2( -1,-1 ) + ((linearToGamma158).xy - float2( 0,0 )) * (float2( 1,1 ) - float2( -1,-1 )) / (float2( 1,1 ) - float2( 0,0 ))) * temp_output_8_0_g96 * temp_output_29_0_g96 ) + uv_BumpTex ) ) , tex2D( _BumpTex, ( uv_BumpTex + ( temp_output_29_0_g96 * (float2( -1,-1 ) + ((linearToGamma158).xy - float2( 0,0 )) * (float2( 1,1 ) - float2( -1,-1 )) / (float2( 1,1 ) - float2( 0,0 ))) * frac( ( 0.5 + mulTime7_g96 ) ) ) ) ) , ( abs( ( -temp_output_8_0_g96 + 0.5 ) ) * 2 ));
			float3 normal80 = UnpackNormal( lerpResult26_g96 );
			o.Normal = normal80;
			float mulTime7_g97 = _Time.y * _TimeScale;
			float temp_output_8_0_g97 = frac( mulTime7_g97 );
			float temp_output_29_0_g97 = _FlowStrength;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 lerpResult26_g97 = lerp( tex2D( _MainTex, ( ( (float2( -1,-1 ) + ((linearToGamma158).xy - float2( 0,0 )) * (float2( 1,1 ) - float2( -1,-1 )) / (float2( 1,1 ) - float2( 0,0 ))) * temp_output_8_0_g97 * temp_output_29_0_g97 ) + uv_MainTex ) ) , tex2D( _MainTex, ( uv_MainTex + ( temp_output_29_0_g97 * (float2( -1,-1 ) + ((linearToGamma158).xy - float2( 0,0 )) * (float2( 1,1 ) - float2( -1,-1 )) / (float2( 1,1 ) - float2( 0,0 ))) * frac( ( 0.5 + mulTime7_g97 ) ) ) ) ) , ( abs( ( -temp_output_8_0_g97 + 0.5 ) ) * 2 ));
			float4 color17 = lerpResult26_g97;
			o.Albedo = color17.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
1927;239;1906;912;5417.953;976.8395;1.619407;True;True
Node;AmplifyShaderEditor.TexturePropertyNode;63;-5183.886,-376.1676;Float;True;Property;_FlowMap;Flow Map;2;0;Create;True;0;0;False;0;None;7a0a5980402c8dc4883451cecaab01de;True;gray;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.CommentaryNode;125;-4843.389,-606.4722;Float;False;910.8104;452.1393;Comment;6;144;156;142;159;158;130;Flow Map;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;130;-4818.629,-379.0865;Float;True;Property;_TextureSample3;Texture Sample 3;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LinearToGammaNode;158;-4513.237,-488.0764;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;159;-4364.006,-391.4688;Float;False;FLOAT2;0;1;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;142;-4200.104,-530.7127;Float;True;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;3;FLOAT2;-1,-1;False;4;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RelayNode;145;-3851.956,-315.6733;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-3719.921,127.8677;Float;False;Property;_TimeScale;Time Scale;4;0;Create;True;0;0;False;0;1;0.93;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-3734.827,59.12391;Float;False;Property;_FlowStrength;Flow Strength;3;0;Create;True;0;0;False;0;0;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;67;-3713.842,274.9777;Float;True;Property;_BumpTex;Normal Map;1;1;[Normal];Create;False;0;0;False;0;None;f5453dca2ac649e4182c56a3966ad395;True;bump;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.FunctionNode;164;-3324.439,184.6382;Float;False;FlowMap;-1;;96;2217becc26828db4ab706ea4a37b9140;0;4;28;SAMPLER2D;;False;55;FLOAT2;0,0;False;29;FLOAT;0.1;False;30;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;79;-3698.302,-547.6595;Float;True;Property;_MainTex;Main Tex;0;0;Create;True;0;0;False;0;None;c68296334e691ed45b62266cbc716628;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;77;-3010.873,245.6374;Float;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;165;-3320.339,-219.1525;Float;False;FlowMap;-1;;97;2217becc26828db4ab706ea4a37b9140;0;4;28;SAMPLER2D;;False;55;FLOAT2;0,0;False;29;FLOAT;0.1;False;30;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-2737.331,259.4302;Float;True;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;143;-4495.064,-693.4909;Float;False;FLOAT2;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-3438.041,-1079.898;Float;False;17;0;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-4134.146,9.897872;Float;False;Property;_Float0;Float 0;6;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;-2980.288,-215.8995;Float;True;color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;161;-3671.35,-892.3803;Float;False;Property;_Smoothness;Smoothness;7;0;Create;True;0;0;False;0;0;0.75;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GammaToLinearNode;156;-4523.212,-587.803;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;160;-3661.467,-968.6177;Float;False;Property;_Metallic;Metallic;8;0;Create;True;0;0;False;0;0;0.34;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;144;-4737.514,-562.3878;Fixed;False;Property;_Color0;Color 0;5;1;[Gamma];Create;True;0;0;False;0;0.4980392,0.5294118,0,1;0.5019608,0.5019608,0,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;69;-3635.603,-1041.205;Float;False;80;0;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-3220.392,-1043.873;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/Farl/Amplify/AmplifyFlowMap;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;130;0;63;0
WireConnection;158;0;130;0
WireConnection;159;0;158;0
WireConnection;142;0;159;0
WireConnection;145;0;142;0
WireConnection;164;28;67;0
WireConnection;164;55;145;0
WireConnection;164;29;41;0
WireConnection;164;30;10;0
WireConnection;77;0;164;0
WireConnection;165;28;79;0
WireConnection;165;55;145;0
WireConnection;165;29;41;0
WireConnection;165;30;10;0
WireConnection;80;0;77;0
WireConnection;17;0;165;0
WireConnection;0;0;18;0
WireConnection;0;1;69;0
WireConnection;0;3;160;0
WireConnection;0;4;161;0
ASEEND*/
//CHKSM=97A2E287D3BF399ECB914042BCAE7D5829313D4E