// Made with Amplify Shader Editor
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
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Off
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _BumpScale;
		uniform sampler2D _BumpTex;
		uniform float4 _BumpTex_ST;
		uniform sampler2D _MainTex;
		uniform float4 _MainColor;
		uniform float _AngleY;
		uniform float3 _RotateXPivot;
		uniform float _AngleX;
		uniform float _AngleZ;


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
			float temp_output_45_0 = radians( _AngleY );
			float temp_output_28_0 = radians( _AngleX );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float4 transform6 = mul(unity_WorldToObject,float4( ase_worldPos , 0.0 ));
			float temp_output_27_0 = radians( _AngleZ );
			float temp_output_16_0 =  ( transform6.x - 0 > 0 ? temp_output_27_0 : transform6.x - 0 <= 0 && transform6.x + 0 >= 0 ? 0.0 : -temp_output_27_0 ) ;
			float3 rotatedValue19 = RotateAroundAxis( _RotateXPivot, transform6.xyz, float3( 0,0,1 ), temp_output_16_0 );
			float3 rotatedValue54 = RotateAroundAxis( _RotateXPivot, rotatedValue19, float3( 1,0,0 ), temp_output_28_0 );
			float3 rotatedValue23 = RotateAroundAxis( _RotateXPivot, rotatedValue54, float3( 0,1,0 ), temp_output_45_0 );
			v.vertex.xyz += ( float4( rotatedValue23 , 0.0 ) - transform6 ).xyz;
			float3 ase_vertexNormal = v.normal.xyz;
			float3 rotatedValue58 = RotateAroundAxis( _RotateXPivot, ase_vertexNormal, float3( 1,0,0 ), temp_output_16_0 );
			float3 rotatedValue59 = RotateAroundAxis( _RotateXPivot, rotatedValue58, float3( 1,0,0 ), temp_output_28_0 );
			float3 rotatedValue60 = RotateAroundAxis( _RotateXPivot, rotatedValue59, float3( 0,1,0 ), temp_output_45_0 );
			v.normal = rotatedValue60;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BumpTex = i.uv_texcoord * _BumpTex_ST.xy + _BumpTex_ST.zw;
			o.Normal = UnpackScaleNormal( tex2D( _BumpTex, uv_BumpTex ) ,_BumpScale );
			float2 uv_MainTex21 = i.uv_texcoord;
			float4 tex2DNode21 = tex2D( _MainTex, uv_MainTex21 );
			o.Albedo = ( tex2DNode21 * _MainColor ).rgb;
			o.Alpha = tex2DNode21.a;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
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
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
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
				float3 worldPos = IN.worldPos;
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
0;534;1440;362;2639.47;-183.4286;2.513865;True;False
Node;AmplifyShaderEditor.CommentaryNode;48;-3950.607,527.8707;Float;False;807.8062;358.2594;-45 ~ -90;5;27;18;17;16;15;Angle Z;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-3939.443,613.6071;Float;False;Property;_AngleZ;Angle Z;7;0;Create;True;0;0;False;0;0;0;-180;180;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;7;-4123.935,250.8881;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RadiansOpNode;27;-3670.49,619.337;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;6;-3883.936,254.8881;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;17;-3529.593,699.5233;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-3528.155,771.1301;Float;False;Constant;_zero;zero;4;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCIf;16;-3400.801,577.8707;Float;False;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;26;-2760.698,731.9913;Float;False;Property;_RotateXPivot;Rotate X Pivot;4;0;Create;True;0;0;False;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;24;-2760.722,363.369;Float;False;Property;_AngleX;Angle X;5;0;Create;True;0;0;False;0;45;0;0;90;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;56;-3667.844,1000.46;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;44;-1837.07,349.2716;Float;False;Property;_AngleY;Angle Y;6;0;Create;True;0;0;False;0;0;0;-180;180;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;19;-3122.445,530.2715;Float;False;False;4;0;FLOAT3;0,0,1;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RadiansOpNode;28;-2476.539,368.6782;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;58;-3127.552,938.1964;Float;False;False;4;0;FLOAT3;1,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;54;-2307.628,337.6537;Float;False;False;4;0;FLOAT3;1,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RadiansOpNode;45;-1553.594,366.4892;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;23;-1401.435,342.7375;Float;False;False;4;0;FLOAT3;0,1,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;59;-2234.058,920.6941;Float;False;False;4;0;FLOAT3;1,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-732.153,57.8932;Float;False;Property;_BumpScale;Bump Scale;3;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-784,-73.5;Float;False;0;2;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;21;-634.153,-318.1068;Float;True;Property;_MainTex;Main Tex;0;1;[NoScaleOffset];Create;True;0;0;False;0;None;80ab37a9e4f49c842903bb43bdd7bcd2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;3;-314,-308.5;Float;False;Property;_MainColor;Main Color;1;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RotateAboutAxisNode;60;-1493.647,908.0206;Float;False;False;4;0;FLOAT3;0,1,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;20;-947.9673,215.4577;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-19.82092,-244.651;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;2;-521,-67.5;Float;True;Property;_BumpTex;Bump Tex;2;0;Create;True;0;0;False;0;None;bac772f6b98f2df438d2e27aaa3aa158;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/Farl/Amplify/AmplifyFold;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;0;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;SrcAlpha;OneMinusSrcAlpha;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;27;0;15;0
WireConnection;6;0;7;0
WireConnection;17;0;27;0
WireConnection;16;0;6;1
WireConnection;16;2;27;0
WireConnection;16;3;18;0
WireConnection;16;4;17;0
WireConnection;19;1;16;0
WireConnection;19;2;26;0
WireConnection;19;3;6;0
WireConnection;28;0;24;0
WireConnection;58;1;16;0
WireConnection;58;2;26;0
WireConnection;58;3;56;0
WireConnection;54;1;28;0
WireConnection;54;2;26;0
WireConnection;54;3;19;0
WireConnection;45;0;44;0
WireConnection;23;1;45;0
WireConnection;23;2;26;0
WireConnection;23;3;54;0
WireConnection;59;1;28;0
WireConnection;59;2;26;0
WireConnection;59;3;58;0
WireConnection;60;1;45;0
WireConnection;60;2;26;0
WireConnection;60;3;59;0
WireConnection;20;0;23;0
WireConnection;20;1;6;0
WireConnection;22;0;21;0
WireConnection;22;1;3;0
WireConnection;2;1;4;0
WireConnection;2;5;13;0
WireConnection;0;0;22;0
WireConnection;0;1;2;0
WireConnection;0;9;21;4
WireConnection;0;11;20;0
WireConnection;0;12;60;0
ASEEND*/
//CHKSM=71DA5EEE326697FCD8F8679ADABE110FD23AA324