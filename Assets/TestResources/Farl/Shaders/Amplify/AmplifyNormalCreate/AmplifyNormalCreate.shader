// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifyNormalCreate"
{
	Properties
	{
		_Height("Height", 2D) = "white" {}
		_DiffY("Diff Y", Range( -1 , 1)) = 0.01
		_DiffX("Diff X", Range( -1 , 1)) = 0.01
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.5
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_PhaseLength("Phase Length", Range( 0 , 0.1)) = 8
		_TimeScale("Time Scale", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _Height;
		uniform float4 _Height_ST;
		uniform float _DiffX;
		uniform float _PhaseLength;
		uniform float _TimeScale;
		uniform float _DiffY;
		uniform float4 _Color;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _Metallic;
		uniform float _Smoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Height = i.uv_texcoord * _Height_ST.xy + _Height_ST.zw;
			float4 appendResult7 = (float4(_DiffX , 0.0 , 0 , 0));
			float2 appendResult70 = (float2(_PhaseLength , _TimeScale));
			float2 waveParam68 = appendResult70;
			float mulTime8_g6 = _Time.y * waveParam68.y;
			float mulTime8_g5 = _Time.y * waveParam68.y;
			float heigh16 = (0 + (sin( ( ( ( tex2D( _Height, uv_Height ).r / 6.28318548202515 ) / ( abs( waveParam68.x ) + 1E-09 ) ) + mulTime8_g5 ) ) - -1) * (1 - 0) / (1 - -1));
			float temp_output_18_0 = ( (0 + (sin( ( ( ( tex2D( _Height, ( float4( uv_Height, 0.0 , 0.0 ) + appendResult7 ).xy ).r / 6.28318548202515 ) / ( abs( waveParam68.x ) + 1E-09 ) ) + mulTime8_g6 ) ) - -1) * (1 - 0) / (1 - -1)) - heigh16 );
			float4 appendResult12 = (float4(0.0 , _DiffY , 0 , 0));
			float mulTime8_g7 = _Time.y * waveParam68.y;
			float temp_output_19_0 = ( (0 + (sin( ( ( ( tex2D( _Height, ( appendResult12 + float4( uv_Height, 0.0 , 0.0 ) ).xy ).r / 6.28318548202515 ) / ( abs( waveParam68.x ) + 1E-09 ) ) + mulTime8_g7 ) ) - -1) * (1 - 0) / (1 - -1)) - heigh16 );
			float4 appendResult21 = (float4(-temp_output_18_0 , -temp_output_19_0 , ( temp_output_19_0 * temp_output_18_0 ) , 0));
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float4 normalizeResult31 = normalize( ( appendResult21 + float4( mul( ase_worldToTangent, mul( unity_ObjectToWorld, float4( ase_vertexNormal , 0.0 ) ).xyz ) , 0.0 ) ) );
			float4 normal25 = normalizeResult31;
			o.Normal = normal25.xyz;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			o.Albedo = ( _Color * tex2D( _MainTex, uv_MainTex ) ).rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal( v.normal );
				fixed3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			fixed4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
201;45;1107;850;3410.648;413.9796;2.689559;True;False
Node;AmplifyShaderEditor.CommentaryNode;80;-1409.853,-776.4993;Float;False;717.5741;241.4204;Comment;4;68;70;61;54;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-1364.853,-717.4993;Float;False;Property;_PhaseLength;Phase Length;7;0;Create;True;0;0;False;0;8;0.004;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-1242.285,-646.0789;Float;False;Property;_TimeScale;Time Scale;8;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;38;-2633.358,118.3;Float;False;2412.031;809.7936;Comment;23;21;23;24;22;18;19;84;17;20;83;14;3;75;15;76;5;12;7;4;13;11;9;8;DiffX x DiffY = normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;70;-1072.28,-700.7203;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-2386.37,467.9336;Float;False;Constant;_zero;zero;1;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;81;-1981.209,-427.9759;Float;False;1480.679;367.9742;Comment;5;2;1;69;72;16;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-2587.913,360.5623;Float;False;Property;_DiffX;Diff X;2;0;Create;True;0;0;False;0;0.01;-0.002;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-2585.71,589.3935;Float;False;Property;_DiffY;Diff Y;1;0;Create;True;0;0;False;0;0.01;0.002;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;-926.28,-703.7203;Float;False;waveParam;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;12;-2223.96,536.6039;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;-1535.892,-177.0017;Float;False;68;0;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-1931.209,-353.3789;Float;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;13;-2380.255,770.4474;Float;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-2382.561,178.6707;Float;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;7;-2230.5,375.2831;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;72;-1353.892,-193.0017;Float;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-2066.052,610.2411;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;-1961.698,462.0823;Float;False;68;0;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;5;-2085.27,271.3794;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;1;-1669.192,-377.9759;Float;True;Property;_Height;Height;0;0;Create;True;0;0;False;0;80ab37a9e4f49c842903bb43bdd7bcd2;9789d23040cb1fb45ad60392430c3c15;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;14;-1913.451,579.7592;Float;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-1923.805,241.2552;Float;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;82;-1049.243,-353.8181;Float;False;ApplySineWave;-1;;5;b44bb5233fa3e416b9c1cf85891f604d;0;3;1;FLOAT;0;False;13;FLOAT;0;False;14;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;75;-1749.422,455.1744;Float;False;FLOAT;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;17;-987.8694,325.9866;Float;False;16;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;84;-1409.743,587.3574;Float;False;ApplySineWave;-1;;7;b44bb5233fa3e416b9c1cf85891f604d;0;3;1;FLOAT;0;False;13;FLOAT;0;False;14;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;83;-1437.69,249.4844;Float;False;ApplySineWave;-1;;6;b44bb5233fa3e416b9c1cf85891f604d;0;3;1;FLOAT;0;False;13;FLOAT;0;False;14;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-734.5299,-340.376;Float;False;heigh;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-988.2903,632.577;Float;False;16;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;43;-750.49,1177.041;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;18;-798.0379,233.6772;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;19;-804.5956,497.3102;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;45;-757.4564,1086.499;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.WorldToTangentMatrix;46;-538.4565,1079.499;Float;False;0;1;FLOAT3x3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-522.0885,1186.257;Float;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;22;-597.4778,502.9843;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-616.4427,367.6568;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;23;-578.3368,244.0905;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-329.4562,1184.499;Float;False;2;2;0;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;-388.3271,327.8918;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-95.7817,632.647;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;32;131.0531,-549.4317;Float;False;Property;_Color;Color;3;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;31;53.11715,632.6472;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;39;48.90842,-357.0923;Float;True;Property;_MainTex;Main Tex;4;0;Create;True;0;0;False;0;None;a9f953c7353804247b8c3ed6e1c46a2e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;26;335.3718,-60.08846;Float;False;25;0;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;49;221.834,172.0395;Float;False;Property;_Smoothness;Smoothness;5;0;Create;True;0;0;False;0;0.5;0.34;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;200.834,43.03949;Float;False;Property;_Metallic;Metallic;6;0;Create;True;0;0;False;0;0;0.23;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;231.3764,627.6575;Float;False;normal;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;398.9496,-397.9341;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;672.0959,-79.45084;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/Farl/Amplify/AmplifyNormalCreate;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;70;0;54;0
WireConnection;70;1;61;0
WireConnection;68;0;70;0
WireConnection;12;0;11;0
WireConnection;12;1;9;0
WireConnection;7;0;8;0
WireConnection;7;1;11;0
WireConnection;72;0;69;0
WireConnection;15;0;12;0
WireConnection;15;1;13;0
WireConnection;5;0;4;0
WireConnection;5;1;7;0
WireConnection;1;1;2;0
WireConnection;14;1;15;0
WireConnection;3;1;5;0
WireConnection;82;1;1;1
WireConnection;82;13;72;0
WireConnection;82;14;72;1
WireConnection;75;0;76;0
WireConnection;84;1;14;1
WireConnection;84;13;75;0
WireConnection;84;14;75;1
WireConnection;83;1;3;1
WireConnection;83;13;75;0
WireConnection;83;14;75;1
WireConnection;16;0;82;0
WireConnection;18;0;83;0
WireConnection;18;1;17;0
WireConnection;19;0;84;0
WireConnection;19;1;20;0
WireConnection;42;0;45;0
WireConnection;42;1;43;0
WireConnection;22;0;19;0
WireConnection;24;0;19;0
WireConnection;24;1;18;0
WireConnection;23;0;18;0
WireConnection;47;0;46;0
WireConnection;47;1;42;0
WireConnection;21;0;23;0
WireConnection;21;1;22;0
WireConnection;21;2;24;0
WireConnection;29;0;21;0
WireConnection;29;1;47;0
WireConnection;31;0;29;0
WireConnection;25;0;31;0
WireConnection;40;0;32;0
WireConnection;40;1;39;0
WireConnection;0;0;40;0
WireConnection;0;1;26;0
WireConnection;0;3;48;0
WireConnection;0;4;49;0
ASEEND*/
//CHKSM=1A4F57933A197B2F8B4CDC86ADDCB02D7891C3BD