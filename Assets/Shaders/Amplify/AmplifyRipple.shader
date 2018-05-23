// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/AmplifyRipple"
{
	Properties
	{
		[Header(AmplifyRipple)]
		_WorldPosition("World Position", Vector) = (0,0,0,0)
		_Color("Color", Color) = (1,1,1,1)
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_MetallicValue("Metallic Value", Range( 0 , 1)) = 0
		_MaxDistance("Max Distance", Float) = 0.2
		_Timescale("Timescale", Float) = 0
		_Debug("Debug", Range( 0 , 1)) = 0
		_SmoothFactor("Smooth Factor", Range( 0 , 1)) = 0
		_Test("Test", Range( 0 , 1)) = 0
		_FrequencyMutiplier("Frequency Mutiplier", Float) = 0
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
		#pragma target 4.5
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
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
		};

		uniform float _FrequencyMutiplier;
		uniform float _Timescale;
		uniform float3 _WorldPosition;
		uniform fixed _MaxDistance;
		uniform float _SmoothFactor;
		uniform fixed _Test;
		uniform float4 _Color;
		uniform float _MetallicValue;
		uniform fixed _Debug;
		uniform float _Smoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float temp_output_29_0_g57 = _FrequencyMutiplier;
			float mulTime4_g57 = _Time.y * _Timescale;
			float3 WorldPosition92 = _WorldPosition;
			float3 ase_worldPos = i.worldPos;
			float temp_output_5_0_g57 = distance( WorldPosition92 , ase_worldPos );
			float temp_output_7_0_g57 = ( mulTime4_g57 + temp_output_5_0_g57 );
			float temp_output_30_0_g57 = ( temp_output_29_0_g57 * ( ( 2 * UNITY_PI ) * temp_output_7_0_g57 ) );
			float Cos176 = cos( temp_output_30_0_g57 );
			float3 UpVec242 = float3(0,1,0);
			float3 normalizeResult68 = normalize( ( ase_worldPos - WorldPosition92 ) );
			float DistanceFactor196 = ( 1.0 - saturate( ( temp_output_5_0_g57 / _MaxDistance ) ) );
			float3 lerpResult197 = lerp( UpVec242 , normalizeResult68 , DistanceFactor196);
			float3 OutDir127 = lerpResult197;
			float3 lerpResult240 = lerp( OutDir127 , UpVec242 , _SmoothFactor);
			float Sin124 = sin( temp_output_30_0_g57 );
			float Sin275213 = sin( ( ( 2.0 * ( temp_output_7_0_g57 * ( 2 * UNITY_PI ) ) * temp_output_29_0_g57 ) - ( 0.5 * UNITY_PI ) ) );
			float lerpResult252 = lerp( abs( Sin124 ) , (0 + (Sin275213 - -1) * (1 - 0) / (1 - -1)) , _Test);
			float3 lerpResult168 = lerp( ( lerpResult240 * float3( -1,1,-1 ) ) , UpVec242 , lerpResult252);
			float3 lerpResult204 = lerp( lerpResult240 , UpVec242 , lerpResult252);
			float3 ifLocalVar190 = 0;
			if( Cos176 <= 0 )
				ifLocalVar190 = lerpResult204;
			else
				ifLocalVar190 = lerpResult168;
			float3 RippleNormal1270 = mul( ase_worldToTangent, ifLocalVar190 );
			o.Normal = RippleNormal1270;
			o.Albedo = _Color.rgb;
			float lerpResult217 = lerp( _MetallicValue , 0 , _Debug);
			o.Metallic = lerpResult217;
			float lerpResult218 = lerp( _Smoothness , 0 , _Debug);
			o.Smoothness = lerpResult218;
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
			#pragma target 4.5
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
				float4 tSpace0 : TEXCOORD1;
				float4 tSpace1 : TEXCOORD2;
				float4 tSpace2 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal( v.normal );
				fixed3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
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
0;45;1440;851;711.29;100.1879;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;268;-896.6531,178.6645;Float;False;511.3744;222.5382;World Position;2;92;24;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;118;-626.4263,691.0861;Float;False;1011.413;397.306;Tangent;8;127;197;198;68;67;93;66;275;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;24;-846.6531,228.6645;Float;False;Property;_WorldPosition;World Position;2;0;Create;True;0;0;False;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;212;-311.3215,-17.53191;Float;False;1316.482;536.6207;Comment;8;196;124;176;145;100;98;213;267;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-602.4263,886.0862;Float;False;92;0;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;66;-593.7192,730.0053;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;267;-195.1669,342.5984;Float;False;92;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;92;-618.1896,256.2642;Float;False;WorldPosition;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;274;-903.7785,430.0128;Float;False;511.267;234;UpDir;2;242;164;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-280.3015,152.2475;Float;False;Property;_Timescale;Timescale;7;0;Create;True;0;0;False;0;0;-0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-87.86341,126.6435;Float;False;Property;_FrequencyMutiplier;Frequency Mutiplier;11;0;Create;True;0;0;False;0;0;2.12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-125.6654,231.9222;Fixed;False;Property;_MaxDistance;Max Distance;6;0;Create;True;0;0;False;0;0.2;3.83;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;164;-853.7785,480.0128;Float;False;Constant;_UpDir;UpDir;8;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;67;-380.7703,802.2024;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;276;311.1231,131.3179;Float;False;AmplifyRipple;0;;57;7cb683cb2363f4525a04b582f72a0459;0;4;29;FLOAT;1;False;25;FLOAT;1;False;22;FLOAT;5;False;17;FLOAT3;0,0,0;False;4;FLOAT;59;FLOAT;34;FLOAT;33;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;68;-234.0785,901.6786;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;196;725.8981,138.5971;Float;False;DistanceFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;-322.3513,996.4163;Float;False;196;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;242;-626.5115,525.2563;Float;False;UpVec;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;275;-228.7803,778.5615;Float;False;242;0;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;197;-22.18839,875.8272;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;273;-1195.176,-1117.399;Float;False;2148.185;976.0728;Comment;20;270;88;252;246;237;250;245;244;236;225;190;87;204;168;191;208;243;240;165;256;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;213;710.7719,35.21394;Float;False;Sin275;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;236;-1040.991,-603.3983;Float;False;124;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;127;129.1505,757.8755;Float;False;OutDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;165;-1024.991,-1019.399;Float;False;127;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;245;-1136.991,-859.3983;Float;False;Property;_SmoothFactor;Smooth Factor;9;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;244;-1040.991,-939.3984;Float;False;242;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;124;761.2851,348.502;Float;False;Sin;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;225;-1104.991,-475.3982;Float;False;213;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;237;-832.9911,-603.3983;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;250;-880.9911,-523.3982;Float;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;256;-926.7582,-256.1058;Fixed;False;Property;_Test;Test;10;0;Create;True;0;0;False;0;0;0.8360178;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;240;-752.9911,-1067.399;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;246;-528.9914,-619.3983;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;208;-464.9914,-1051.399;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;-1,1,-1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;252;-656.9913,-603.3983;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;243;-496.9914,-875.3983;Float;False;242;0;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;204;-192.9916,-651.3982;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;168;-192.9916,-939.3984;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;191;-112.9916,-763.3981;Float;False;176;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;176;771.162,243.9151;Float;False;Cos;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;190;191.0083,-779.3981;Float;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldToTangentMatrix;87;111.0085,-875.3983;Float;False;0;1;FLOAT3x3;0
Node;AmplifyShaderEditor.RangedFloatNode;95;1178.251,326.5325;Float;False;Property;_Smoothness;Smoothness;4;0;Create;True;0;0;False;0;0;0.77;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;219;1199.149,431.1822;Fixed;False;Property;_Debug;Debug;8;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;96;1196.132,220.1205;Float;False;Property;_MetallicValue;Metallic Value;5;0;Create;True;0;0;False;0;0;0.82;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;463.0077,-806.5651;Float;True;2;2;0;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;270;719.0081,-822.5651;Float;False;RippleNormal1;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;91;1519.323,-299.8164;Float;False;Property;_Color;Color;3;0;Create;True;0;0;False;0;1,1,1,1;0.5661764,0.7307302,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;218;1550.826,329.493;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;217;1542.278,174.2019;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;271;1208.588,-116.3497;Float;False;270;0;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1784.641,-78.65508;Float;False;True;5;Float;ASEMaterialInspector;0;0;Standard;Custom/Farl/AmplifyRipple;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;3;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;27.8;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;92;0;24;0
WireConnection;67;0;66;0
WireConnection;67;1;93;0
WireConnection;276;29;100;0
WireConnection;276;25;145;0
WireConnection;276;22;98;0
WireConnection;276;17;267;0
WireConnection;68;0;67;0
WireConnection;196;0;276;34
WireConnection;242;0;164;0
WireConnection;197;0;275;0
WireConnection;197;1;68;0
WireConnection;197;2;198;0
WireConnection;213;0;276;59
WireConnection;127;0;197;0
WireConnection;124;0;276;0
WireConnection;237;0;236;0
WireConnection;250;0;225;0
WireConnection;240;0;165;0
WireConnection;240;1;244;0
WireConnection;240;2;245;0
WireConnection;246;0;240;0
WireConnection;208;0;240;0
WireConnection;252;0;237;0
WireConnection;252;1;250;0
WireConnection;252;2;256;0
WireConnection;204;0;246;0
WireConnection;204;1;243;0
WireConnection;204;2;252;0
WireConnection;168;0;208;0
WireConnection;168;1;243;0
WireConnection;168;2;252;0
WireConnection;176;0;276;33
WireConnection;190;0;191;0
WireConnection;190;2;168;0
WireConnection;190;3;204;0
WireConnection;190;4;204;0
WireConnection;88;0;87;0
WireConnection;88;1;190;0
WireConnection;270;0;88;0
WireConnection;218;0;95;0
WireConnection;218;2;219;0
WireConnection;217;0;96;0
WireConnection;217;2;219;0
WireConnection;0;0;91;0
WireConnection;0;1;271;0
WireConnection;0;3;217;0
WireConnection;0;4;218;0
ASEEND*/
//CHKSM=2928CD351237593DB1BF4CE8A8E2322E1098A852