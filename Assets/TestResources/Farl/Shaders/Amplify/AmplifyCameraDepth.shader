// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifyCameraDepth"
{
	Properties
	{
		_Distance("Distance", Float) = 1
		[NoScaleOffset]_MainTex("Main Texture", 2D) = "white" {}
		_Color0("Color 0", Color) = (0,0,0,0)
		_Color("Color", Color) = (0,0,0,0)
		_FadeMethod("Fade Method", Range( 0 , 1)) = 0
		_Tiling("Tiling", Range( 1 , 10)) = 0
		[NoScaleOffset]_BumpMap("Bump Map", 2D) = "bump" {}
		_Metaillic("Metaillic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_BumpScale("BumpScale", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPos;
		};

		uniform sampler2D _BumpMap;
		uniform float _Tiling;
		uniform float4 _Color0;
		uniform sampler2D _MainTex;
		uniform float _BumpScale;
		uniform float4 _Color;
		uniform sampler2D _CameraDepthTexture;
		uniform float _Distance;
		uniform float _FadeMethod;
		uniform float _Metaillic;
		uniform float _Smoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_cast_0 = (_Tiling).xx;
			float2 uv_TexCoord49 = i.uv_texcoord * temp_cast_0 + float2( 0,0 );
			float2 panner48 = ( uv_TexCoord49 + 1 * _Time.y * float2( 0,0.1 ));
			o.Normal = UnpackNormal( tex2D( _BumpMap, panner48 ) );
			float2 uv_BumpMap61 = i.uv_texcoord;
			float4 clampResult47 = clamp( tex2D( _MainTex, ( float3( panner48 ,  0.0 ) + UnpackScaleNormal( tex2D( _BumpMap, uv_BumpMap61 ) ,_BumpScale ) ).xy ) , float4( 0.3897059,0.3897059,0.3897059,0 ) , float4( 1,1,1,1 ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth22 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(ase_screenPos))));
			float distanceDepth22 = abs( ( screenDepth22 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _Distance ) );
			float eyeDepth39 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(ase_screenPos))));
			float lerpResult41 = lerp( distanceDepth22 , ( eyeDepth39 - ase_screenPos.w ) , _FadeMethod);
			float depthFade85 = saturate( lerpResult41 );
			float4 lerpResult51 = lerp( ( _Color0 * clampResult47 ) , ( _Color * clampResult47 ) , depthFade85);
			o.Albedo = lerpResult51.rgb;
			o.Metallic = _Metaillic;
			o.Smoothness = _Smoothness;
			o.Alpha = depthFade85;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows 

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
				float4 screenPos : TEXCOORD3;
				float4 tSpace0 : TEXCOORD4;
				float4 tSpace1 : TEXCOORD5;
				float4 tSpace2 : TEXCOORD6;
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
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
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
				surfIN.screenPos = IN.screenPos;
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
0;473;1440;409;310.1842;493.4181;1.23844;True;False
Node;AmplifyShaderEditor.CommentaryNode;83;-756.0225,187.751;Float;False;697.1133;260.1703;Depth Fade 1;3;38;40;39;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-1630.918,-180.8753;Float;False;Property;_Tiling;Tiling;5;0;Create;True;0;0;False;0;0;2.48;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;84;-752.2302,-5.739939;Float;False;441.034;170.7549;Depth Fade x;2;23;22;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;38;-706.0225,240.9213;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;49;-1230.808,-335.9466;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;63;-1529.418,-9.900622;Float;False;Property;_BumpScale;BumpScale;9;0;Create;True;0;0;False;0;0;0.149;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-702.2302,50.01493;Float;False;Property;_Distance;Distance;0;0;Create;True;0;0;False;0;1;-0.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;39;-443.915,237.751;Float;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;61;-1343.592,-73.1854;Float;True;Property;_TextureSample1;Texture Sample 1;6;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Instance;55;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;48;-971.5853,-463.0858;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;40;-226.9092,265.7651;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;22;-534.1962,44.26005;Float;False;True;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-24.89185,209.5968;Float;False;Property;_FadeMethod;Fade Method;4;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;-972.8013,-155.2186;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;41;-63.96637,-89.97411;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;24;-760.634,-244.0206;Float;True;Property;_MainTex;Main Texture;1;1;[NoScaleOffset];Create;False;0;0;False;0;None;61c0b9c0523734e0e91bc6043c72a490;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;53;-511.3072,-742.2162;Float;False;Property;_Color0;Color 0;2;0;Create;False;0;0;False;0;0,0,0,0;0.7426471,1,0.9361054,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;50;147.8546,-29.15596;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;47;-308.5272,-317.8543;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0.3897059,0.3897059,0.3897059,0;False;2;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;26;-645.9229,-516.5225;Float;False;Property;_Color;Color;3;0;Create;False;0;0;False;0;0,0,0,0;0.1242969,0.7313453,0.8897059,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;281.6455,-83.10352;Float;False;depthFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-96.00657,-384.7775;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-31.88404,-637.4683;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;9.669693,-265.7948;Float;False;85;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;55;-288.4859,-600.73;Float;True;Property;_BumpMap;Bump Map;6;1;[NoScaleOffset];Create;True;0;0;False;0;None;7ddcba51d9fc0894d98b4ba77fbdfbd7;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;57;292.9741,-196.6863;Float;False;Property;_Smoothness;Smoothness;8;0;Create;True;0;0;False;0;0;0.668;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;51;241.7121,-425.8691;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;56;295.3485,-274.0864;Float;False;Property;_Metaillic;Metaillic;7;0;Create;True;0;0;False;0;0;0.087;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;74;653.7904,-233.6063;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;73;642.338,-277.9843;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;76;573.6234,-383.9189;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;71;603.6865,-485.5589;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;37;911.5475,-424.1467;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/Farl/Amplify/AmplifyCameraDepth;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;SrcAlpha;OneMinusSrcAlpha;2;SrcAlpha;OneMinusSrcAlpha;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;49;0;54;0
WireConnection;39;0;38;0
WireConnection;61;5;63;0
WireConnection;48;0;49;0
WireConnection;40;0;39;0
WireConnection;40;1;38;4
WireConnection;22;0;23;0
WireConnection;62;0;48;0
WireConnection;62;1;61;0
WireConnection;41;0;22;0
WireConnection;41;1;40;0
WireConnection;41;2;42;0
WireConnection;24;1;62;0
WireConnection;50;0;41;0
WireConnection;47;0;24;0
WireConnection;85;0;50;0
WireConnection;25;0;26;0
WireConnection;25;1;47;0
WireConnection;52;0;53;0
WireConnection;52;1;47;0
WireConnection;55;1;48;0
WireConnection;51;0;52;0
WireConnection;51;1;25;0
WireConnection;51;2;86;0
WireConnection;74;0;57;0
WireConnection;73;0;56;0
WireConnection;76;0;55;0
WireConnection;71;0;51;0
WireConnection;37;0;71;0
WireConnection;37;1;76;0
WireConnection;37;3;73;0
WireConnection;37;4;74;0
WireConnection;37;9;85;0
ASEEND*/
//CHKSM=F4E7D7CEA30074B428662D3038B3F4BC6D233CDC