// Made with Amplify Shader Editor v1.9.3.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifyFold"
{
	Properties
	{
		[NoScaleOffset]_MainTex("Main Tex", 2D) = "white" {}
		_MainColor("Main Color", Color) = (1,1,1,1)
		_BumpTex("Bump Tex", 2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1
		_RotateXPivot("Rotate X Pivot", Vector) = (0,0,0,0)
		_AngleX("Angle X", Range( 0 , 90)) = 45
		_AngleY("Angle Y", Range( -180 , 180)) = 0
		_AngleZ("Angle Z", Range( -180 , 180)) = 0
		_LowPoly("Low Poly", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" }
		Cull Off
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float _AngleY;
		uniform float3 _RotateXPivot;
		uniform float _AngleX;
		uniform float _AngleZ;
		uniform sampler2D _BumpTex;
		uniform float4 _BumpTex_ST;
		uniform float _BumpScale;
		uniform float _LowPoly;
		uniform sampler2D _MainTex;
		uniform float4 _MainColor;


		float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
		{
			original -= center;
			float C = cos( angle );
			float S = sin( angle );
			float t = 1 - C;
			float m00 = t * u.x * u.x + C;
			float m01 = t * u.x * u.y - S * u.z;
			float m02 = t * u.x * u.z + S * u.y;
			float m10 = t * u.x * u.y + S * u.z;
			float m11 = t * u.y * u.y + C;
			float m12 = t * u.y * u.z - S * u.x;
			float m20 = t * u.x * u.z - S * u.y;
			float m21 = t * u.y * u.z + S * u.x;
			float m22 = t * u.z * u.z + C;
			float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
			return mul( finalMatrix, original ) + center;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 localPos64 = ase_vertex3Pos;
			float pivotX72 = _RotateXPivot.x;
			float temp_output_27_0 = radians( _AngleZ );
			float3 rotatedValue19 = RotateAroundAxis( _RotateXPivot, localPos64, float3( 0,0,1 ),  ( localPos64.x - 0.0 > pivotX72 ? temp_output_27_0 : localPos64.x - 0.0 <= pivotX72 && localPos64.x + 0.0 >= pivotX72 ? 0.0 : -temp_output_27_0 )  );
			float3 rotatedValue54 = RotateAroundAxis( _RotateXPivot, rotatedValue19, float3( 1,0,0 ), radians( _AngleX ) );
			float3 rotatedValue23 = RotateAroundAxis( _RotateXPivot, rotatedValue54, float3( 0,1,0 ), radians( _AngleY ) );
			v.vertex.xyz += ( rotatedValue23 - localPos64 );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BumpTex = i.uv_texcoord * _BumpTex_ST.xy + _BumpTex_ST.zw;
			float3 ase_worldPos = i.worldPos;
			float3 normalizeResult85 = normalize( ( cross( ddx( ase_worldPos ) , ddy( ase_worldPos ) ) + float3( 1E-09,0,0 ) ) );
			o.Normal = ( UnpackScaleNormal( tex2D( _BumpTex, uv_BumpTex ), _BumpScale ) + ( normalizeResult85 * _LowPoly ) );
			float2 uv_MainTex21 = i.uv_texcoord;
			float4 tex2DNode21 = tex2D( _MainTex, uv_MainTex21 );
			o.Albedo = ( tex2DNode21 * _MainColor ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19303
Node;AmplifyShaderEditor.CommentaryNode;71;-4400.769,169.9882;Inherit;False;965.834;222.4935;Vertex Position;3;66;64;70;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;48;-4054.955,543.9894;Inherit;False;907.7586;355.8215;-45 ~ -90;6;16;17;73;18;27;15;Angle Z;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-3983.673,728.5732;Float;False;Property;_AngleZ;Angle Z;8;0;Create;True;0;0;0;False;0;False;0;-30;-180;180;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;70;-4368.826,225.8384;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;26;-2792.662,731.9913;Float;False;Property;_RotateXPivot;Rotate X Pivot;5;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-3913.396,219.9882;Float;False;localPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;81;-1045.816,451.0473;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RadiansOpNode;27;-3683.628,666.2525;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;72;-2579.827,775.2606;Float;False;pivotX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-3637.362,587.9543;Inherit;False;72;pivotX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DdyOpNode;82;-837.8161,531.0472;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DdxOpNode;86;-838.8161,435.0473;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;17;-3533.989,715.642;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;66;-3694.935,227.6808;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;18;-3532.551,787.2488;Float;False;Constant;_zero;zero;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2760.722,363.369;Float;False;Property;_AngleX;Angle X;6;0;Create;True;0;0;0;False;0;False;45;0;0;90;0;1;FLOAT;0
Node;AmplifyShaderEditor.CrossProductOpNode;83;-709.8161,467.0473;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCIf;16;-3405.197,593.9894;Inherit;False;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1837.07,349.2716;Float;False;Property;_AngleY;Angle Y;7;0;Create;True;0;0;0;False;0;False;0;0;-180;180;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;19;-3122.445,530.2715;Inherit;False;False;4;0;FLOAT3;0,0,1;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RadiansOpNode;28;-2476.539,368.6782;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;84;-541.8121,501.2961;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1E-09,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-732.153,57.8932;Float;False;Property;_BumpScale;Bump Scale;4;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-784,-73.5;Inherit;False;0;2;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;85;-405.8159,531.0472;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;54;-2307.628,337.6537;Inherit;False;False;4;0;FLOAT3;1,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-497.0965,384.7282;Float;False;Property;_LowPoly;Low Poly;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RadiansOpNode;45;-1553.594,366.4892;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-363.4819,416.5412;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;2;-521,-67.5;Inherit;True;Property;_BumpTex;Bump Tex;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;65;-1298.447,163.9687;Inherit;False;64;localPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;21;-634.153,-318.1068;Inherit;True;Property;_MainTex;Main Tex;1;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;3;-314,-308.5;Float;False;Property;_MainColor;Main Color;2;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RotateAboutAxisNode;23;-1401.435,342.7375;Inherit;False;False;4;0;FLOAT3;0,1,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;87;-217.1422,168.3999;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;20;-947.9673,215.4577;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-19.82092,-244.651;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalVertexDataNode;80;-132.9645,449.7727;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-5.739036,10.33026;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Custom/Farl/Amplify/AmplifyFold;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;True;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;0;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;64;0;70;0
WireConnection;27;0;15;0
WireConnection;72;0;26;1
WireConnection;82;0;81;0
WireConnection;86;0;81;0
WireConnection;17;0;27;0
WireConnection;66;0;64;0
WireConnection;83;0;86;0
WireConnection;83;1;82;0
WireConnection;16;0;66;0
WireConnection;16;1;73;0
WireConnection;16;2;27;0
WireConnection;16;3;18;0
WireConnection;16;4;17;0
WireConnection;19;1;16;0
WireConnection;19;2;26;0
WireConnection;19;3;64;0
WireConnection;28;0;24;0
WireConnection;84;0;83;0
WireConnection;85;0;84;0
WireConnection;54;1;28;0
WireConnection;54;2;26;0
WireConnection;54;3;19;0
WireConnection;45;0;44;0
WireConnection;88;0;85;0
WireConnection;88;1;89;0
WireConnection;2;1;4;0
WireConnection;2;5;13;0
WireConnection;23;1;45;0
WireConnection;23;2;26;0
WireConnection;23;3;54;0
WireConnection;87;0;2;0
WireConnection;87;1;88;0
WireConnection;20;0;23;0
WireConnection;20;1;65;0
WireConnection;22;0;21;0
WireConnection;22;1;3;0
WireConnection;0;0;22;0
WireConnection;0;1;87;0
WireConnection;0;11;20;0
ASEEND*/
//CHKSM=5817D70C0BDC27C6C5E1E833F5137083CECAED7C