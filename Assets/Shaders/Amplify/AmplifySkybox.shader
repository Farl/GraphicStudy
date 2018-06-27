// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifySkybox"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
		_Tiling("Tiling", Int) = 0
		_Power("Power", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float3 worldPos;
		};

		uniform sampler2D _MainTex;
		uniform int _Tiling;
		uniform float _Power;

		inline fixed4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return fixed4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 normalizeResult69 = normalize( ase_worldPos );
			float3 position73 = normalizeResult69;
			float2 appendResult78 = (float2(position73.x , position73.z));
			float2 normalizeResult96 = normalize( appendResult78 );
			float2 appendResult105 = (float2(sign( -position73.z ) , 0));
			float dotResult79 = dot( normalizeResult96 , appendResult105 );
			float phi88 = ( acos( dotResult79 ) / UNITY_PI );
			float2 appendResult64 = (float2(position73.x , position73.y));
			float dotResult65 = dot( appendResult64 , float2( 0,-1 ) );
			float theta86 = ( acos( dotResult65 ) / UNITY_PI );
			float2 appendResult10 = (float2(phi88 , theta86));
			float4 temp_cast_0 = (_Power).xxxx;
			o.Emission = pow( tex2D( _MainTex, ( appendResult10 * _Tiling ) ) , temp_cast_0 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
0;413;1440;381;1580.374;1090.039;1.536343;True;False
Node;AmplifyShaderEditor.CommentaryNode;75;-1433.915,-1344.036;Float;False;727.8961;246.3495;Comment;3;70;69;73;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;70;-1383.915,-1276.686;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;69;-1168.959,-1291.179;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;77;-1270.897,-1031.126;Float;False;1800.629;318.1894;Comment;12;88;81;82;90;79;78;84;83;96;105;114;112;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;-940.0182,-1294.036;Float;False;position;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;83;-1230.115,-967.4662;Float;False;73;0;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;84;-1019.024,-972.1324;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CommentaryNode;76;-1241.336,-661.4021;Float;False;1526.029;287.9402;Comment;9;67;63;74;68;66;65;64;86;104;;1,1,1,1;0;0
Node;AmplifyShaderEditor.NegateNode;112;-786.0845,-839.6153;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;74;-1191.336,-491.7356;Float;False;73;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SignOpNode;114;-649.3495,-825.7881;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;78;-694.9698,-980.2366;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;63;-954.1271,-499.4743;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NormalizeNode;96;-516.4812,-959.5736;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;64;-719.8001,-561.0593;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;104;-583.287,-492.4022;Float;False;Constant;_Vector1;Vector 1;3;0;Create;True;0;0;False;0;0,-1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;105;-484.9612,-830.3973;Float;False;FLOAT2;4;0;FLOAT;-1;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;65;-464.7207,-604.0814;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;79;-318.2814,-970.8047;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ACosOpNode;90;-158.2174,-974.6501;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ACosOpNode;66;-345.0551,-610.256;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;68;-366.8148,-477.3212;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;82;-179.7933,-849.7828;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;81;9.421582,-964.1205;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;67;-180.1957,-611.4023;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;87;-501.4473,-292.964;Float;False;86;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;88;194.4214,-985.1172;Float;True;phi;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;86;19.76049,-617.2692;Float;True;theta;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-503.4985,-155.2964;Float;False;88;0;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;98;-266.2122,-28.14774;Float;False;Property;_Tiling;Tiling;1;0;Create;True;0;0;False;0;0;1;0;1;INT;0
Node;AmplifyShaderEditor.DynamicAppendNode;10;-291.871,-215.2811;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-65.44962,-89.07304;Float;False;2;2;0;FLOAT2;0,0;False;1;INT;10;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;102;367.0282,75.75494;Float;False;Property;_Power;Power;2;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;80.80107,-185.3436;Float;True;Property;_MainTex;Main Tex;0;0;Create;True;0;0;False;0;323372d8965c24e7abcbc4867052e272;e28dc97a9541e3642a48c0e3886688c5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;101;442.6958,-114.4367;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;15;618.1204,-218.0928;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;Custom/Farl/Amplify/AmplifySkybox;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Opaque;0.5;True;False;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;69;0;70;0
WireConnection;73;0;69;0
WireConnection;84;0;83;0
WireConnection;112;0;84;2
WireConnection;114;0;112;0
WireConnection;78;0;84;0
WireConnection;78;1;84;2
WireConnection;63;0;74;0
WireConnection;96;0;78;0
WireConnection;64;0;63;0
WireConnection;64;1;63;1
WireConnection;105;0;114;0
WireConnection;65;0;64;0
WireConnection;65;1;104;0
WireConnection;79;0;96;0
WireConnection;79;1;105;0
WireConnection;90;0;79;0
WireConnection;66;0;65;0
WireConnection;81;0;90;0
WireConnection;81;1;82;0
WireConnection;67;0;66;0
WireConnection;67;1;68;0
WireConnection;88;0;81;0
WireConnection;86;0;67;0
WireConnection;10;0;89;0
WireConnection;10;1;87;0
WireConnection;28;0;10;0
WireConnection;28;1;98;0
WireConnection;1;1;28;0
WireConnection;101;0;1;0
WireConnection;101;1;102;0
WireConnection;15;2;101;0
ASEEND*/
//CHKSM=C44D62C34DE56657548AD18B71834495F56B79B1