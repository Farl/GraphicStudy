// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Aimee/Shader/Gost"
{
	Properties
	{
		_Scale("Scale", Float) = 1
		_Bias("Bias", Float) = 0
		_Power("Power", Float) = 5
		_BumpMap("Bump Map", 2D) = "bump" {}
		_Speed("Speed", Float) = 0
		_BumpScale("Bump Scale", Float) = 0
		_length("length", Range( 0 , 1)) = 0
		_frequency("frequency", Int) = 2
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
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
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform float _Bias;
		uniform float _Scale;
		uniform float _Power;
		uniform float _BumpScale;
		uniform sampler2D _BumpMap;
		uniform float _Speed;
		uniform float4 _BumpMap_ST;
		uniform int _frequency;
		uniform float _length;


		float3x3 Inverse3x3(float3x3 input)
		{
			float3 a = input._11_21_31;
			float3 b = input._12_22_32;
			float3 c = input._13_23_33;
			return float3x3(cross(b,c), cross(c,a), cross(a,b)) * (1.0 / dot(a,cross(b,c)));
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float3 ase_worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
			half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
			float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * tangentSign;
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3x3 invertVal33 = Inverse3x3( ase_worldToTangent );
			float2 temp_cast_0 = (_Speed).xx;
			float2 uv_BumpMap = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
			float2 panner23 = ( uv_BumpMap + 1 * _Time.y * temp_cast_0);
			v.vertex.xyz += ( mul( invertVal33, UnpackScaleNormal( tex2Dlod( _BumpMap, float4( panner23, 0, 0) ) ,_BumpScale ) ) * float3( ( sin( ( panner23 * ( _frequency * UNITY_PI ) ) ) * _length ) ,  0.0 ) );
		}

		inline fixed4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return fixed4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNDotV1 = dot( normalize( ase_worldNormal ), ase_worldViewDir );
			float fresnelNode1 = ( _Bias + _Scale * pow( 1.0 - fresnelNDotV1, _Power ) );
			o.Alpha = saturate( (( 1.0 - saturate( fresnelNode1 ) )*2.52 + -1.34) );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc 

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
			sampler3D _DitherMaskLOD;
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
				Input customInputData;
				vertexDataFunc( v, customInputData );
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
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
158;386;1229;493;1451.482;235.9282;1.651359;True;True
Node;AmplifyShaderEditor.CommentaryNode;12;-1532.814,-415.3164;Float;False;1006.111;490.2824;Fresnel;9;8;7;10;11;5;6;4;1;50;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.PiNode;46;-1702.791,633.8875;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;45;-1680.426,553.2556;Float;False;Property;_frequency;frequency;11;0;Create;True;0;0;False;0;2;7;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2240.402,327.9417;Float;False;Property;_Speed;Speed;6;0;Create;True;0;0;False;0;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;22;-2128.341,231.4637;Float;False;0;25;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;6;-1165.456,-43.41665;Float;False;Property;_Power;Power;2;0;Create;True;0;0;False;0;5;1.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1160.937,-124.7629;Float;False;Property;_Scale;Scale;0;0;Create;True;0;0;False;0;1;1.26;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1160.938,-203.0967;Float;False;Property;_Bias;Bias;1;0;Create;True;0;0;False;0;0;-0.22;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;23;-1855.081,308.7775;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-1394.116,566.7608;Float;False;2;2;0;INT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;1;-942.688,-162.6626;Float;True;Tangent;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToTangentMatrix;32;-1331.369,119.1972;Float;False;0;1;FLOAT3x3;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1694.646,403.8915;Float;False;Property;_BumpScale;Bump Scale;8;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-1188.439,461.6783;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;50;-664.1356,-146.2387;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.InverseOpNode;33;-1103.765,117.6799;Float;False;1;0;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.SamplerNode;25;-1341.641,237.3741;Float;True;Property;_BumpMap;Bump Map;5;0;Create;True;0;0;False;0;None;f53512d44b91e954dae7bf028209df1a;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;26;-975.6689,429.5795;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-1057.11,635.3602;Float;False;Property;_length;length;9;0;Create;True;0;0;False;0;0;0.101;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;20;-487.0558,-143.3676;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;51;-314.0222,-141.0962;Float;True;3;0;FLOAT;0;False;1;FLOAT;2.52;False;2;FLOAT;-1.34;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-941.4211,193.4019;Float;False;2;2;0;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-773.7937,435.2615;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldToTangentMatrix;8;-1476.187,-365.3164;Float;False;0;1;FLOAT3x3;0
Node;AmplifyShaderEditor.Vector3Node;21;97.56459,1492.538;Float;False;Property;_Vector0;Vector 0;4;0;Create;True;0;0;False;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;30;-457.4674,-381.5246;Float;True;Property;_Emission;Emission;7;0;Create;True;0;0;False;0;a08960dd6e8274e7f8fca616e09c48ed;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-622.4301,247.9258;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-1022.392,-321.6301;Float;False;2;2;0;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.InverseOpNode;10;-1192.617,-363.8099;Float;False;1;0;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.SamplerNode;7;-1482.814,-281.3899;Float;True;Property;_Normal;Normal;3;0;Create;True;0;0;False;0;a268ab862991c4743a9281c69bb2c36a;233518d21026a2e4397650a59649e438;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;52;-80.66284,138.1654;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;174.3976,81.38715;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;Custom/Aimee/Shader/Gost;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Transparent;0.5;True;True;0;True;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;SrcAlpha;OneMinusSrcAlpha;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;23;0;22;0
WireConnection;23;2;24;0
WireConnection;47;0;45;0
WireConnection;47;1;46;0
WireConnection;1;1;4;0
WireConnection;1;2;5;0
WireConnection;1;3;6;0
WireConnection;44;0;23;0
WireConnection;44;1;47;0
WireConnection;50;0;1;0
WireConnection;33;0;32;0
WireConnection;25;1;23;0
WireConnection;25;5;29;0
WireConnection;26;0;44;0
WireConnection;20;0;50;0
WireConnection;51;0;20;0
WireConnection;34;0;33;0
WireConnection;34;1;25;0
WireConnection;42;0;26;0
WireConnection;42;1;41;0
WireConnection;37;0;34;0
WireConnection;37;1;42;0
WireConnection;11;0;10;0
WireConnection;11;1;7;0
WireConnection;10;0;8;0
WireConnection;52;0;51;0
WireConnection;0;9;52;0
WireConnection;0;11;37;0
ASEEND*/
//CHKSM=929F34E63588CB1F26BD6A716A26DD3F3BBEE112