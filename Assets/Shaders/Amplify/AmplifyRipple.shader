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
		uniform float4 _Color;
		uniform float _MetallicValue;
		uniform float _Smoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float mulTime4_g31 = _Time.y * _Timescale;
			float3 ase_worldPos = i.worldPos;
			float temp_output_5_0_g31 = distance( _WorldPosition , ase_worldPos );
			float temp_output_30_0_g31 = ( _FrequencyMutiplier * ( ( mulTime4_g31 + 0 ) + temp_output_5_0_g31 ) );
			float DeltaHeight2176 = cos( temp_output_30_0_g31 );
			float3 WorldPosition92 = _WorldPosition;
			float3 normalizeResult68 = normalize( ( ase_worldPos - WorldPosition92 ) );
			float DistanceFactor196 = ( 1.0 - saturate( ( temp_output_5_0_g31 / _MaxDistance ) ) );
			float3 lerpResult197 = lerp( float3(0,1,0) , normalizeResult68 , DistanceFactor196);
			float3 OutDir127 = lerpResult197;
			float DeltaHeight124 = sin( temp_output_30_0_g31 );
			float3 lerpResult168 = lerp( ( OutDir127 * float3( -1,1,-1 ) ) , float3(0,1,0) , abs( DeltaHeight124 ));
			float3 lerpResult204 = lerp( OutDir127 , float3(0,1,0) , abs( DeltaHeight124 ));
			float3 ifLocalVar190 = 0;
			if( DeltaHeight2176 <= 0 )
				ifLocalVar190 = lerpResult204;
			else
				ifLocalVar190 = lerpResult168;
			o.Normal = mul( ase_worldToTangent, (float3( 0,0,0 ) + (ifLocalVar190 - float3( -1,-1,-1 )) * (float3( 1,1,1 ) - float3( 0,0,0 )) / (float3( 1,1,1 ) - float3( -1,-1,-1 ))) );
			o.Albedo = _Color.rgb;
			o.Metallic = _MetallicValue;
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
6;429;1440;519;-385.7582;-403.4076;1.054559;True;True
Node;AmplifyShaderEditor.Vector3Node;24;2376.681,-1312.871;Float;False;Property;_WorldPosition;World Position;2;0;Create;True;0;0;False;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;118;369.6186,446.5211;Float;False;1011.413;397.306;Tangent;8;127;197;198;68;67;93;66;199;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;145;2293.824,-729.6863;Float;False;Property;_Timescale;Timescale;7;0;Create;True;0;0;False;0;0;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;2284.5,-804.4031;Float;False;Property;_FrequencyMutiplier;Frequency Mutiplier;8;0;Create;True;0;0;False;0;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;2244.043,-646.0293;Fixed;False;Property;_MaxDistance;Max Distance;6;0;Create;True;0;0;False;0;0.2;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;393.6186,641.5211;Float;False;92;0;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;66;402.3262,485.4402;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;92;2617.989,-1309.125;Float;False;WorldPosition;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;200;2869.073,-947.3703;Float;False;AmplifyRipple;0;;31;7cb683cb2363f4525a04b582f72a0459;0;5;29;FLOAT;1;False;25;FLOAT;1;False;22;FLOAT;5;False;17;FLOAT3;0,0,0;False;20;FLOAT;0;False;3;FLOAT;34;FLOAT;33;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;67;615.2748,557.6373;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;673.6938,751.8512;Float;False;196;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;196;3275.848,-779.0911;Float;False;DistanceFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;68;761.9664,657.1135;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;199;791.9603,504.3575;Float;False;Constant;_Vector1;Vector 1;8;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;197;973.856,631.2621;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;124;3252.698,-919.2202;Float;False;DeltaHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;1055.178,208.1435;Float;False;124;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;919.8727,-323.3589;Float;False;124;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;165;930.7267,-578.4193;Float;False;127;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;127;1125.196,513.3104;Float;False;OutDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;179;1062.317,-46.6948;Float;False;127;0;1;FLOAT3;0
Node;AmplifyShaderEditor.AbsOpNode;205;1243.75,160.4603;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;208;1141.915,-608.0538;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;-1,1,-1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;185;1069.159,30.82766;Float;False;Constant;_Vector2;Vector 2;8;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;164;1055.773,-489.5191;Float;False;Constant;_UpDir;UpDir;8;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.AbsOpNode;206;1105.926,-339.3409;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;204;1390.661,18.09263;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;176;3254.111,-994.7731;Float;False;DeltaHeight2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;168;1337.202,-380.951;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;191;1614.013,-143.0899;Float;False;176;0;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;190;1854.008,-96.00235;Float;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldToTangentMatrix;87;2186.654,-44.20704;Float;False;0;1;FLOAT3x3;0
Node;AmplifyShaderEditor.TFHCRemapNode;130;2213.133,107.1663;Float;False;5;0;FLOAT3;0,0,0;False;1;FLOAT3;-1,-1,-1;False;2;FLOAT3;1,1,1;False;3;FLOAT3;0,0,0;False;4;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;96;2848.905,-5.497518;Float;False;Property;_MetallicValue;Metallic Value;5;0;Create;True;0;0;False;0;0;0.28;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;91;3016.347,-276.8362;Float;False;Property;_Color;Color;3;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;95;2857.954,123.115;Float;False;Property;_Smoothness;Smoothness;4;0;Create;True;0;0;False;0;0;0.86;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;2455.145,-66.97266;Float;True;2;2;0;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3282.668,-129.2557;Float;False;True;5;Float;ASEMaterialInspector;0;0;Standard;Custom/Farl/AmplifyRipple;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;3;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;27.8;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;92;0;24;0
WireConnection;200;29;100;0
WireConnection;200;25;145;0
WireConnection;200;22;98;0
WireConnection;200;17;24;0
WireConnection;67;0;66;0
WireConnection;67;1;93;0
WireConnection;196;0;200;34
WireConnection;68;0;67;0
WireConnection;197;0;199;0
WireConnection;197;1;68;0
WireConnection;197;2;198;0
WireConnection;124;0;200;0
WireConnection;127;0;197;0
WireConnection;205;0;186;0
WireConnection;208;0;165;0
WireConnection;206;0;171;0
WireConnection;204;0;179;0
WireConnection;204;1;185;0
WireConnection;204;2;205;0
WireConnection;176;0;200;33
WireConnection;168;0;208;0
WireConnection;168;1;164;0
WireConnection;168;2;206;0
WireConnection;190;0;191;0
WireConnection;190;2;168;0
WireConnection;190;3;204;0
WireConnection;190;4;204;0
WireConnection;130;0;190;0
WireConnection;88;0;87;0
WireConnection;88;1;130;0
WireConnection;0;0;91;0
WireConnection;0;1;88;0
WireConnection;0;3;96;0
WireConnection;0;4;95;0
ASEEND*/
//CHKSM=879F7DA351E8EF16EA68AA044D714C3993C11863