// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifyBillboard"
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
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			fixed filler;
		};

		uniform float4 _Color;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float4 appendResult36 = (float4(( ase_vertex3Pos.x * length( (float4( unity_ObjectToWorld[0][0],unity_ObjectToWorld[1][0],unity_ObjectToWorld[2][0],unity_ObjectToWorld[3][0] )).xyz ) ) , ( ase_vertex3Pos.y * length( (float4( unity_ObjectToWorld[0][1],unity_ObjectToWorld[1][1],unity_ObjectToWorld[2][1],unity_ObjectToWorld[3][1] )).xyz ) ) , ( ase_vertex3Pos.z * length( (float4( unity_ObjectToWorld[0][2],unity_ObjectToWorld[1][2],unity_ObjectToWorld[2][2],unity_ObjectToWorld[3][2] )).xyz ) ) , 0));
			float3 normalizeResult63 = normalize( (UNITY_MATRIX_V[0]).xyz );
			float3 rightCamVec7 = normalizeResult63;
			float3 normalizeResult61 = normalize( (UNITY_MATRIX_V[1]).xyz );
			float3 upCamVec5 = normalizeResult61;
			float3 normalizeResult62 = normalize( (UNITY_MATRIX_V[2]).xyz );
			float3 forwardCamVec6 = -normalizeResult62;
			float4x4 rotationCamMatrix8 = float4x4(float4( rightCamVec7 , 0.0 ), float4( upCamVec5 , 0.0 ), float4( forwardCamVec6 , 0.0 ), float4(0,0,0,1));
			float4 appendResult68 = (float4((float4( unity_ObjectToWorld[0][3],unity_ObjectToWorld[1][3],unity_ObjectToWorld[2][3],unity_ObjectToWorld[3][3] )).xyz , 1));
			float4 vertexPos42 = mul( unity_WorldToObject, ( mul( appendResult36, rotationCamMatrix8 ) + appendResult68 ) );
			v.vertex.xyz = vertexPos42.xyz;
			float3 ase_vertexNormal = v.normal.xyz;
			float3 normalizeResult57 = normalize( mul( float4( ase_vertexNormal , 0.0 ), rotationCamMatrix8 ).xyz );
			float3 vertexNormal27 = normalizeResult57;
			v.normal = vertexNormal27;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
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
28;189;1412;554;3198.785;-566.056;2.876253;True;False
Node;AmplifyShaderEditor.ViewMatrixNode;1;-1572.13,-680.1273;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;9;-1370.13,-633.1273;Float;False;Row;2;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;65;-1178.882,-630.4652;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;2;-1370.368,-794.4563;Float;False;Row;1;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VectorFromMatrixNode;10;-1368.801,-467.7983;Float;False;Row;0;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;15;-1787.924,984.8723;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;20;-1461.528,1036.306;Float;False;Column;1;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;64;-1170.299,-784.9708;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;66;-1181.028,-475.9598;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;62;-966.6111,-625.8416;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;19;-1461.528,858.1814;Float;False;Column;0;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VectorFromMatrixNode;21;-1461.528,1204.715;Float;False;Column;2;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;63;-953.9084,-462.5226;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;52;-1277.994,1053.877;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;53;-1280.495,1229.373;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;51;-1292.198,866.5786;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;58;-776.6007,-641.5273;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;61;-952.0939,-789.1607;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;6;-636.2474,-639.0283;Float;False;forwardCamVec;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;5;-739.053,-788.2123;Float;False;upCamVec;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LengthOpNode;30;-1072.456,1221.408;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;23;-1262.059,676.5109;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LengthOpNode;28;-1067.875,870.9829;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;29;-1065.585,1074.825;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;14;-1400.918,-23.60678;Float;False;6;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;12;-1391.888,-211.7355;Float;False;7;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;13;-1388.877,-122.9388;Float;False;5;0;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;49;-1376.491,59.19522;Float;False;Constant;_Vector0;Vector 0;1;0;Create;True;0;0;False;0;0,0,0,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;7;-768.9755,-465.3979;Float;False;rightCamVec;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.MatrixFromVectors;11;-1154.067,-124.4438;Float;False;FLOAT4x4;4;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-861.7429,1230.569;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;22;-1456.845,1386.391;Float;False;Column;3;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-875.4851,861.8215;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-875.4851,1083.986;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-917.3701,-116.9824;Float;False;rotationCamMatrix;-1;True;1;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4x4;0
Node;AmplifyShaderEditor.ComponentMaskNode;69;-1270.109,1391.677;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;35;-690.7482,1167.975;Float;False;8;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.DynamicAppendNode;36;-676.2239,1010.049;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-1378.339,519.4186;Float;False;8;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.DynamicAppendNode;68;-539.0007,1391.676;Float;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalVertexDataNode;24;-1355.199,342.9735;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-447.188,980.2744;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1124.903,461.291;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-291.444,1076.469;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldToObjectMatrix;50;-334.1142,900.2332;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-57.82758,1063.243;Float;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalizeNode;57;-966.0925,462.9774;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;116.2396,1070.114;Float;False;vertexPos;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;70;-1283.2,1670.537;Float;False;Property;_Color;Color;0;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-807.6168,447.7119;Float;False;vertexNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-1298.094,1915.272;Float;False;42;0;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-1300.138,2020.569;Float;False;27;0;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-1018.217,1658.034;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/Farl/Amplify/AmplifyBillboard;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Spherical;False;Absolute;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;9;0;1;0
WireConnection;65;0;9;0
WireConnection;2;0;1;0
WireConnection;10;0;1;0
WireConnection;20;0;15;0
WireConnection;64;0;2;0
WireConnection;66;0;10;0
WireConnection;62;0;65;0
WireConnection;19;0;15;0
WireConnection;21;0;15;0
WireConnection;63;0;66;0
WireConnection;52;0;20;0
WireConnection;53;0;21;0
WireConnection;51;0;19;0
WireConnection;58;0;62;0
WireConnection;61;0;64;0
WireConnection;6;0;58;0
WireConnection;5;0;61;0
WireConnection;30;0;53;0
WireConnection;28;0;51;0
WireConnection;29;0;52;0
WireConnection;7;0;63;0
WireConnection;11;0;12;0
WireConnection;11;1;13;0
WireConnection;11;2;14;0
WireConnection;11;3;49;0
WireConnection;33;0;23;3
WireConnection;33;1;30;0
WireConnection;22;0;15;0
WireConnection;31;0;23;1
WireConnection;31;1;28;0
WireConnection;32;0;23;2
WireConnection;32;1;29;0
WireConnection;8;0;11;0
WireConnection;69;0;22;0
WireConnection;36;0;31;0
WireConnection;36;1;32;0
WireConnection;36;2;33;0
WireConnection;68;0;69;0
WireConnection;34;0;36;0
WireConnection;34;1;35;0
WireConnection;25;0;24;0
WireConnection;25;1;26;0
WireConnection;37;0;34;0
WireConnection;37;1;68;0
WireConnection;40;0;50;0
WireConnection;40;1;37;0
WireConnection;57;0;25;0
WireConnection;42;0;40;0
WireConnection;27;0;57;0
WireConnection;0;0;70;0
WireConnection;0;11;44;0
WireConnection;0;12;43;0
ASEEND*/
//CHKSM=772C43782C91F2868F7BE931CFD5EC1BB0B1EE55