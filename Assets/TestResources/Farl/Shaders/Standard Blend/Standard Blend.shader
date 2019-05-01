// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Standard Blend"
{
	Properties
	{
		_MainTex("Albedo", 2D) = "white" {}
		_MetallicGlossMap("Metallic", 2D) = "white" {}
		_BumpTex("Normal", 2D) = "bump" {}
		_MainTex2("Albedo 2", 2D) = "white" {}
		_MetallicGlossMap2("Metallic 2", 2D) = "white" {}
		_BumpTex2("Normal 2", 2D) = "bump" {}
		_3DNoise("3D Noise", 3D) = "white" {}
		_NoiseScale("Noise Scale", Vector) = (1,1,1,0)
		_NoiseBiasScalePower("Noise (Bias, Scale, Power)", Vector) = (0,1,1,0)
		_NoiseOffset("Noise Offset", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
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
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform sampler2D _BumpTex;
		uniform float4 _BumpTex_ST;
		uniform sampler2D _BumpTex2;
		uniform float4 _BumpTex2_ST;
		uniform sampler3D _3DNoise;
		uniform float3 _NoiseScale;
		uniform float3 _NoiseOffset;
		uniform float3 _NoiseBiasScalePower;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _MainTex2;
		uniform float4 _MainTex2_ST;
		uniform sampler2D _MetallicGlossMap;
		uniform float4 _MetallicGlossMap_ST;
		uniform sampler2D _MetallicGlossMap2;
		uniform float4 _MetallicGlossMap2_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BumpTex = i.uv_texcoord * _BumpTex_ST.xy + _BumpTex_ST.zw;
			float2 uv_BumpTex2 = i.uv_texcoord * _BumpTex2_ST.xy + _BumpTex2_ST.zw;
			float3 ase_worldPos = i.worldPos;
			float blendMask30 = saturate( ( pow( ( tex3D( _3DNoise, ( ( ase_worldPos * _NoiseScale ) + _NoiseOffset ) ).r * _NoiseBiasScalePower.y ) , _NoiseBiasScalePower.z ) + _NoiseBiasScalePower.x ) );
			float3 lerpResult19 = lerp( UnpackNormal( tex2D( _BumpTex, uv_BumpTex ) ) , UnpackNormal( tex2D( _BumpTex2, uv_BumpTex2 ) ) , blendMask30);
			float3 normal21 = lerpResult19;
			o.Normal = normal21;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 uv_MainTex2 = i.uv_texcoord * _MainTex2_ST.xy + _MainTex2_ST.zw;
			float4 lerpResult17 = lerp( tex2D( _MainTex, uv_MainTex ) , tex2D( _MainTex2, uv_MainTex2 ) , blendMask30);
			float4 albedo7 = lerpResult17;
			o.Albedo = albedo7.rgb;
			float2 uv_MetallicGlossMap = i.uv_texcoord * _MetallicGlossMap_ST.xy + _MetallicGlossMap_ST.zw;
			float2 uv_MetallicGlossMap2 = i.uv_texcoord * _MetallicGlossMap2_ST.xy + _MetallicGlossMap2_ST.zw;
			float4 lerpResult18 = lerp( tex2D( _MetallicGlossMap, uv_MetallicGlossMap ) , tex2D( _MetallicGlossMap2, uv_MetallicGlossMap2 ) , blendMask30);
			float metallic20 = lerpResult18.r;
			o.Metallic = metallic20;
			float smoothness24 = lerpResult18.a;
			o.Smoothness = smoothness24;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
59;486;990;855;1188.943;225.188;2.522154;True;False
Node;AmplifyShaderEditor.Vector3Node;39;-1198.661,-859.5018;Float;False;Property;_NoiseScale;Noise Scale;7;0;Create;True;0;0;False;0;1,1,1;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;28;-1171.371,-1024.169;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;43;-976.9183,-749.2091;Float;False;Property;_NoiseOffset;Noise Offset;9;0;Create;True;0;0;False;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-954.4603,-996.5646;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-813.4537,-889.6865;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;34;-617.1272,-929.7089;Float;False;Property;_NoiseBiasScalePower;Noise (Bias, Scale, Power);8;0;Create;True;0;0;False;0;0,1,1;0,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;27;-673.7678,-1121.435;Float;True;Property;_3DNoise;3D Noise;6;0;Create;False;0;0;False;0;None;decce4e1072f54a0184d0c7ee5de69f5;True;0;False;white;LockedToTexture3D;False;Object;-1;Auto;Texture3D;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-352.8588,-1056.511;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;36;-185.2937,-973.8573;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-31.92992,-905.3194;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;29;107.7889,-856.4047;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-478.5012,331.8612;Float;False;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-745.7646,162.1739;Float;True;Property;_MetallicGlossMap2;Metallic 2;4;0;Create;False;0;0;False;0;None;3235a723e33e54cd39147f4bb4f0b74d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-744.7196,-45.74041;Float;True;Property;_MetallicGlossMap;Metallic;1;0;Create;False;0;0;False;0;None;7b0e928cf27ca4c27975908d747f7e04;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;263.0168,-849.3033;Float;False;blendMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;-553.5012,866.8612;Float;False;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;18;-375.4294,23.00546;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-445.5012,-99.13879;Float;False;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-857.4858,675.2639;Float;True;Property;_BumpTex2;Normal 2;5;0;Create;False;0;0;False;0;None;41d82a074162d4fd6a4b228ddc43f582;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-729.2132,-299.1935;Float;True;Property;_MainTex2;Albedo 2;3;0;Create;False;0;0;False;0;None;5d49b6c4bf60d419481a5ff5400faf24;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-683.762,-647.6043;Float;True;Property;_MainTex;Albedo;0;0;Create;False;0;0;False;0;None;8bdf0b0b84b5d47718f0cae3028e6dc0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-831.1284,480.114;Float;True;Property;_BumpTex;Normal;2;0;Create;False;0;0;False;0;None;d475e45a4ba1347f798449f5ed1b07a7;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;23;-203.7098,200.9318;Float;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LerpOp;17;-344.3958,-334.9162;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;19;-449.9103,629.1966;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;10;208.0037,-1.270203;Float;False;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;7;-127.1601,-334.3649;Float;False;albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-61.8493,99.007;Float;False;metallic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-216.1233,693.3328;Float;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;12;201.7969,244.9304;Float;False;-1;0;1;OBJECT;0
Node;AmplifyShaderEditor.GetLocalVarNode;11;194.3834,77.86456;Float;False;24;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;13;203.8658,350.4448;Float;False;-1;0;1;OBJECT;0
Node;AmplifyShaderEditor.GetLocalVarNode;9;218.3481,-96.44012;Float;False;21;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-67.16174,368.5137;Float;False;smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-21.58863,1067.786;Float;False;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;8;216.2793,-197.8168;Float;False;7;0;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;417.9201,-41.37823;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/Farl/Standard Blend;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;40;0;28;0
WireConnection;40;1;39;0
WireConnection;42;0;40;0
WireConnection;42;1;43;0
WireConnection;27;1;42;0
WireConnection;35;0;27;1
WireConnection;35;1;34;2
WireConnection;36;0;35;0
WireConnection;36;1;34;3
WireConnection;37;0;36;0
WireConnection;37;1;34;1
WireConnection;29;0;37;0
WireConnection;30;0;29;0
WireConnection;18;0;2;0
WireConnection;18;1;6;0
WireConnection;18;2;32;0
WireConnection;23;0;18;0
WireConnection;17;0;1;0
WireConnection;17;1;4;0
WireConnection;17;2;31;0
WireConnection;19;0;3;0
WireConnection;19;1;5;0
WireConnection;19;2;33;0
WireConnection;7;0;17;0
WireConnection;20;0;23;0
WireConnection;21;0;19;0
WireConnection;24;0;23;3
WireConnection;0;0;8;0
WireConnection;0;1;9;0
WireConnection;0;3;10;0
WireConnection;0;4;11;0
ASEEND*/
//CHKSM=8B2707CFED49DA3806F13CBA49DBCDDDD45A166C