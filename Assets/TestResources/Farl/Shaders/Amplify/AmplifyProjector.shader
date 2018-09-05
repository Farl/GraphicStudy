// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifyProjector"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
		_Color("Color", Color) = (0,0,0,0)
		_Falloff("Falloff", 2D) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "ForceNoShadowCasting" = "True" "IsEmissive" = "true"  }
		Cull Back
		ZWrite Off
		Offset  -1 , -1
		Blend One One
		ColorMask RGB
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma surface surf Unlit keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nometa noforwardadd vertex:vertexDataFunc 
		struct Input
		{
			float4 vertexToFrag47;
			float4 vertexToFrag56;
		};

		uniform float4 _Color;
		uniform sampler2D _MainTex;
		float4x4 unity_Projector;
		uniform sampler2D _Falloff;
		float4x4 unity_ProjectorClip;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 ase_vertex4Pos = v.vertex;
			float4 uvShadow48 = mul( unity_Projector, ase_vertex4Pos );
			o.vertexToFrag47 = uvShadow48;
			float4 uvFalloff49 = mul( unity_ProjectorClip, ase_vertex4Pos );
			o.vertexToFrag56 = uvFalloff49;
		}

		inline fixed4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return fixed4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 texS33 = tex2D( _MainTex, ( (i.vertexToFrag47).xy / (i.vertexToFrag47).w ) );
			float4 appendResult31 = (float4(( _Color * float4( (texS33).rgb , 0.0 ) ).rgb , ( 1.0 - (texS33).a )));
			float4 texS_New65 = appendResult31;
			float4 texF32 = tex2D( _Falloff, ( (i.vertexToFrag56).xy / (i.vertexToFrag56).w ) );
			o.Emission = ( texS_New65 * (texF32).a ).xyz;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
1687;29;1010;692;1074.527;699.4359;1.752351;True;False
Node;AmplifyShaderEditor.CommentaryNode;70;-2386.181,-459.2101;Float;False;1012.695;965.868;Vertex Program;2;68;69;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;68;-2325.573,-409.2101;Float;False;880.2999;432.6976;Projector Matrix;4;12;1;9;48;;1,1,1,1;0;0
Node;AmplifyShaderEditor.UnityProjectorMatrixNode;1;-2186.846,-359.21;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.PosVertexDataNode;12;-2275.573,-178.5123;Float;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-1902.943,-271.2252;Float;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;69;-2336.181,60.01894;Float;False;915.6841;409.0379;Projector Clip Matrix;4;17;15;16;49;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;59;-1126.894,-416.55;Float;False;999.9445;432.6636;tex2Dproj (_Sample, UNITY_PROJ_COORD(input));5;37;24;47;4;38;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-1317.002,-248.4168;Float;False;48;0;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-1688.274,-252.3429;Float;False;uvShadow;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.UnityProjectorClipMatrixNode;17;-2148.028,110.019;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.VertexToFragmentNode;47;-1072.177,-247.6353;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PosVertexDataNode;15;-2286.181,267.057;Float;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;37;-826.0663,-212.009;Float;False;FLOAT;3;1;2;2;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-1840.913,237.7231;Float;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;24;-819.3719,-294.0453;Float;False;FLOAT2;0;1;2;2;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-1663.496,232.9841;Float;False;uvFalloff;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;38;-632.0898,-282.1245;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;67;-1090.019,92.81191;Float;False;999.9445;432.6636;tex2Dproj (_Sample, UNITY_PROJ_COORD(input));5;21;40;25;39;56;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-1333.096,358.0112;Float;False;49;0;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;71;282.479,-474.9847;Float;False;1086.022;562.5277;Color;8;53;26;52;29;61;31;65;64;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;4;-412.0807,-285.3939;Float;True;Property;_MainTex;Main Tex;1;0;Create;True;0;0;False;0;None;80ab37a9e4f49c842903bb43bdd7bcd2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexToFragmentNode;56;-1025.057,388.0418;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;39;-753.5728,399.3404;Float;False;FLOAT;3;1;2;2;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;25;-747.2135,298.6684;Float;False;FLOAT2;0;1;2;2;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;332.479,-100.9466;Float;False;33;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-83.27258,-279.5151;Float;False;texS;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;40;-600.2495,345.9379;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;52;588.7325,-231.0181;Float;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;53;610.4232,-27.45699;Float;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;26;385.6852,-424.9847;Float;False;Property;_Color;Color;2;0;Create;True;0;0;False;0;0,0,0,0;0,1,0.9558823,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;21;-391.9265,214.7661;Float;True;Property;_Falloff;Falloff;3;0;Create;True;0;0;False;0;None;23740055e2b119e40a939138ab8070f8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;72;367.2246,221.7435;Float;False;642.7552;298.9351;Result;4;54;34;55;30;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;815.9542,-279.728;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;29;757.2576,-32.69991;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;957.2963,-127.6962;Float;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-56.23859,223.3399;Float;False;texF;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;432.4277,405.6786;Float;False;32;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;1125.502,-98.06413;Float;False;texS_New;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;417.2246,271.7435;Float;False;65;0;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;34;661.7678,389.8287;Float;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;840.9798,298.8293;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1050.856,246.3879;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;Custom/Farl/Amplify/AmplifyProjector;False;False;False;False;True;True;True;True;True;False;True;True;False;False;False;True;True;False;False;Back;2;False;-1;0;False;-1;True;-1;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;4;One;One;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;9;0;1;0
WireConnection;9;1;12;0
WireConnection;48;0;9;0
WireConnection;47;0;50;0
WireConnection;37;0;47;0
WireConnection;16;0;17;0
WireConnection;16;1;15;0
WireConnection;24;0;47;0
WireConnection;49;0;16;0
WireConnection;38;0;24;0
WireConnection;38;1;37;0
WireConnection;4;1;38;0
WireConnection;56;0;51;0
WireConnection;39;0;56;0
WireConnection;25;0;56;0
WireConnection;33;0;4;0
WireConnection;40;0;25;0
WireConnection;40;1;39;0
WireConnection;52;0;64;0
WireConnection;53;0;64;0
WireConnection;21;1;40;0
WireConnection;61;0;26;0
WireConnection;61;1;52;0
WireConnection;29;0;53;0
WireConnection;31;0;61;0
WireConnection;31;3;29;0
WireConnection;32;0;21;0
WireConnection;65;0;31;0
WireConnection;34;0;54;0
WireConnection;30;0;55;0
WireConnection;30;1;34;0
WireConnection;0;2;30;0
ASEEND*/
//CHKSM=C044A1E38AB05E650C74A85528C3EEBDD0EE0C90