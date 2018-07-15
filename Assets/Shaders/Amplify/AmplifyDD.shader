// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifyDD"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float3 worldPos;
		};

		uniform float4 _Color;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 normalizeResult10 = normalize( ( cross( ddx( ase_worldPos ) , ddy( ase_worldPos ) ) + float3( 1E-09,0,0 ) ) );
			o.Normal = -normalizeResult10;
			o.Albedo = _Color.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
403;438;1010;692;1779.972;519.472;2.683359;True;False
Node;AmplifyShaderEditor.CommentaryNode;14;-1591.522,95.73623;Float;False;1170.474;262.6185;;7;8;1;11;10;13;6;9;Flat;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;8;-1541.522,160.3476;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DdyOpNode;6;-1278.325,248.3548;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DdxOpNode;1;-1275.355,145.7363;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CrossProductOpNode;9;-1110.921,182.5622;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-907.3127,194.1486;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1E-09,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;10;-738.5023,198.1665;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;13;-585.048,193.3796;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;12;-310.5756,-334.8379;Float;False;Property;_Color;Color;0;0;Create;True;0;0;True;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/Farl/Amplify/AmplifyDD;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;8;0
WireConnection;1;0;8;0
WireConnection;9;0;1;0
WireConnection;9;1;6;0
WireConnection;11;0;9;0
WireConnection;10;0;11;0
WireConnection;13;0;10;0
WireConnection;0;0;12;0
WireConnection;0;1;13;0
ASEEND*/
//CHKSM=F0FA7A92C1D9B4580323F361065F3E06BD1169AA