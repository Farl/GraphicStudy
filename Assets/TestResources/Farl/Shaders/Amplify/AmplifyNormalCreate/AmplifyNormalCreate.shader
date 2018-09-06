// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifyNormalCreate"
{
	Properties
	{
		_Height("Height", 2D) = "white" {}
		_DiffY("Diff Y", Float) = 0.01
		_DiffX("Diff X", Float) = 0.01
		_Color("Color", Color) = (1,1,1,1)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float3 vertexToFrag34;
		};

		uniform sampler2D _Height;
		uniform float4 _Height_ST;
		uniform float _DiffX;
		uniform float _DiffY;
		uniform float4 _Color;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			o.vertexToFrag34 = ase_vertexNormal;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Height = i.uv_texcoord * _Height_ST.xy + _Height_ST.zw;
			float4 appendResult7 = (float4(_DiffX , 0.0 , 0 , 0));
			float height16 = tex2D( _Height, uv_Height ).r;
			float temp_output_18_0 = ( tex2D( _Height, ( float4( uv_Height, 0.0 , 0.0 ) + appendResult7 ).xy ).r - height16 );
			float4 appendResult12 = (float4(0.0 , _DiffY , 0 , 0));
			float temp_output_19_0 = ( tex2D( _Height, ( appendResult12 + float4( uv_Height, 0.0 , 0.0 ) ).xy ).r - height16 );
			float4 appendResult21 = (float4(-temp_output_18_0 , -temp_output_19_0 , ( temp_output_19_0 * temp_output_18_0 ) , 0));
			float4 normalizeResult31 = normalize( ( appendResult21 + float4( i.vertexToFrag34 , 0.0 ) ) );
			float4 normal25 = normalizeResult31;
			o.Normal = (float4( 0,0,0,0 ) + (normal25 - float4( -1,-1,-1,0 )) * (float4( 1,1,1,0 ) - float4( 0,0,0,0 )) / (float4( 1,1,1,0 ) - float4( -1,-1,-1,0 ))).xyz;
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
442;455;788;607;489.6447;-175.6656;1.802323;False;False
Node;AmplifyShaderEditor.RangedFloatNode;11;-1027.264,352.8369;Float;False;Constant;_Float3;Float 3;1;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1023.994,248.1964;Float;False;Property;_DiffX;Diff X;3;0;Create;True;0;0;False;0;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1032.714,509.7977;Float;False;Property;_DiffY;Diff Y;2;0;Create;True;0;0;False;0;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;13;-1021.149,655.3509;Float;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-1023.455,63.57417;Float;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;12;-864.8533,421.5072;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;7;-871.3934,260.1864;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-744.4899,-130.5001;Float;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-746.5579,585.1775;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;1;-489.1766,-119.3417;Float;True;Property;_Height;Height;1;0;Create;True;0;0;False;0;80ab37a9e4f49c842903bb43bdd7bcd2;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;5;-726.163,156.2829;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-249.2761,221.2605;Float;False;16;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-249.697,527.8511;Float;False;16;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-171.4405,-157.7443;Float;False;height;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-564.698,126.1588;Float;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;14;-554.3436,464.6625;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;18;-59.44479,128.9514;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;19;-66.00259,392.584;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;123.2408,606.4196;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;33;29.42425,768.6299;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;23;113.3673,233.1426;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;22;123.6683,513.845;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;34;276.3425,829.9088;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;314.2813,491.4142;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;483.007,628.1775;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalizeNode;31;644.3439,651.9036;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;141.7566,-16.18731;Float;False;25;0;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;807.9137,631.1523;Float;False;normal;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TFHCRemapNode;27;380.1828,-57.2137;Float;False;5;0;FLOAT4;0,0,0,0;False;1;FLOAT4;-1,-1,-1,0;False;2;FLOAT4;1,1,1,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;1,1,1,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;32;374.8391,-255.1362;Float;False;Property;_Color;Color;4;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;672.0959,-79.45084;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/Farl/Amplify/AmplifyNormalCreate;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;12;0;11;0
WireConnection;12;1;9;0
WireConnection;7;0;8;0
WireConnection;7;1;11;0
WireConnection;15;0;12;0
WireConnection;15;1;13;0
WireConnection;1;1;2;0
WireConnection;5;0;4;0
WireConnection;5;1;7;0
WireConnection;16;0;1;1
WireConnection;3;1;5;0
WireConnection;14;1;15;0
WireConnection;18;0;3;1
WireConnection;18;1;17;0
WireConnection;19;0;14;1
WireConnection;19;1;20;0
WireConnection;24;0;19;0
WireConnection;24;1;18;0
WireConnection;23;0;18;0
WireConnection;22;0;19;0
WireConnection;34;0;33;0
WireConnection;21;0;23;0
WireConnection;21;1;22;0
WireConnection;21;2;24;0
WireConnection;29;0;21;0
WireConnection;29;1;34;0
WireConnection;31;0;29;0
WireConnection;25;0;31;0
WireConnection;27;0;26;0
WireConnection;0;0;32;0
WireConnection;0;1;27;0
ASEEND*/
//CHKSM=322133154A980BE49DDB2001D525DE7E2633E3DB