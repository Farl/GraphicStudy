// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifyGrass"
{
	Properties
	{
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

		uniform float3 PlayerPos;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 transform16 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float2 temp_output_15_0 = (( transform16 - float4( PlayerPos , 0.0 ) )).xz;
			float2 normalizeResult11 = normalize( temp_output_15_0 );
			float dotResult17 = dot( temp_output_15_0 , temp_output_15_0 );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 appendResult18 = (float3(( mul( unity_WorldToObject, float4( normalizeResult11, 0.0 , 0.0 ) ).xy * ( 1.0 - saturate( dotResult17 ) ) * saturate( ase_worldPos.y ) ).x , 0 , ( mul( unity_WorldToObject, float4( normalizeResult11, 0.0 , 0.0 ) ).xy * ( 1.0 - saturate( dotResult17 ) ) * saturate( ase_worldPos.y ) ).y));
			v.vertex.xyz += appendResult18;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
366;517;940;435;385.1156;-27.30914;1.370585;True;False
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;16;-749.7567,-35.51804;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;1;-702.7346,208.8833;Float;False;Global;PlayerPos;PlayerPos;0;0;Create;True;0;0;False;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-482.6768,90.9795;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;15;-335.3284,71.74405;Float;False;FLOAT2;0;2;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;17;-228.312,221.0547;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;12;-104.7047,399.9041;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;10;-65.73794,261.8174;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectMatrix;8;-105.7203,2.712997;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.NormalizeNode;11;-114.1968,108.2208;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;13;86.02824,435.2183;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;115.5079,129.173;Float;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;14;89.8866,243.1295;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;272.6369,175.4328;Float;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;19;408.5263,296.1578;Float;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;18;662.4597,290.8523;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;830.4476,23.7092;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/Farl/Amplify/AmplifyGrass;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;16;0
WireConnection;4;1;1;0
WireConnection;15;0;4;0
WireConnection;17;0;15;0
WireConnection;17;1;15;0
WireConnection;10;0;17;0
WireConnection;11;0;15;0
WireConnection;13;0;12;2
WireConnection;6;0;8;0
WireConnection;6;1;11;0
WireConnection;14;0;10;0
WireConnection;9;0;6;0
WireConnection;9;1;14;0
WireConnection;9;2;13;0
WireConnection;19;0;9;0
WireConnection;18;0;19;0
WireConnection;18;2;19;1
WireConnection;0;11;18;0
ASEEND*/
//CHKSM=989C8DD888A69DAB802B99E1DC5B16C74D6957E4