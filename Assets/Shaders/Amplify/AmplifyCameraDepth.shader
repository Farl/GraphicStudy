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
		[NoScaleOffset]_TextureSample0("Texture Sample 0", 2D) = "bump" {}
		_Metaillic("Metaillic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPos;
		};

		uniform float _Tiling;
		uniform sampler2D _TextureSample0;
		uniform float4 _Color0;
		uniform sampler2D _MainTex;
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
			float2 panner48 = ( uv_TexCoord49 + 1 * _Time.y * float2( 0.1,0.1 ));
			o.Normal = UnpackScaleNormal( tex2D( _TextureSample0, panner48 ) ,_Tiling );
			float4 clampResult47 = clamp( tex2D( _MainTex, panner48 ) , float4( 0.7068965,0.7068965,0.7068965,0 ) , float4( 1,1,1,1 ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth22 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(ase_screenPos))));
			float distanceDepth22 = abs( ( screenDepth22 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _Distance ) );
			float eyeDepth39 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(ase_screenPos))));
			float lerpResult41 = lerp( distanceDepth22 , ( eyeDepth39 - ase_screenPos.w ) , _FadeMethod);
			float temp_output_50_0 = saturate( lerpResult41 );
			float4 lerpResult51 = lerp( ( _Color0 * clampResult47 ) , ( _Color * clampResult47 ) , temp_output_50_0);
			o.Albedo = lerpResult51.rgb;
			o.Emission = lerpResult51.rgb;
			o.Metallic = _Metaillic;
			o.Smoothness = _Smoothness;
			o.Alpha = temp_output_50_0;
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
1687;29;1010;692;1757.652;1062.439;2.22772;True;False
Node;AmplifyShaderEditor.RangedFloatNode;54;-1630.918,-180.8753;Float;False;Property;_Tiling;Tiling;5;0;Create;True;0;0;False;0;0;3.1;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;38;-597.2244,109.2188;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;49;-1177.396,-262.7946;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;23;-710.9195,-26.94588;Float;False;Property;_Distance;Distance;0;0;Create;True;0;0;False;0;1;1.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;39;-395.2423,33.03946;Float;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;48;-900.7558,-241.3077;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-24.89185,209.5968;Float;False;Property;_FadeMethod;Fade Method;4;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;40;-268.4241,142.6519;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;24;-661.5537,-283.7228;Float;True;Property;_MainTex;Main Texture;1;1;[NoScaleOffset];Create;False;0;0;False;0;None;9fbef4b79ca3b784ba023cb1331520d5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;22;-414.046,-68.48949;Float;False;True;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;53;-511.3072,-742.2162;Float;False;Property;_Color0;Color 0;2;0;Create;False;0;0;False;0;0,0,0,0;0.6764706,1,0.8858132,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;47;-308.5272,-317.8543;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0.7068965,0.7068965,0.7068965,0;False;2;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;26;-645.9229,-516.5225;Float;False;Property;_Color;Color;3;0;Create;False;0;0;False;0;0,0,0,0;0.1838742,0.4863397,0.8931034,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;41;-63.96637,-89.97411;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-96.00657,-384.7775;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;50;127.9223,-4.952534;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-31.88404,-637.4683;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;56;295.3485,-274.0864;Float;False;Property;_Metaillic;Metaillic;7;0;Create;True;0;0;False;0;0;0.614;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;292.9741,-196.6863;Float;False;Property;_Smoothness;Smoothness;8;0;Create;True;0;0;False;0;0;0.645;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;51;234.0128,-423.9443;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;55;204.0296,-647.6362;Float;True;Property;_TextureSample0;Texture Sample 0;6;1;[NoScaleOffset];Create;True;0;0;False;0;None;bac772f6b98f2df438d2e27aaa3aa158;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;37;535.2303,-418.9472;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/Farl/Amplify/AmplifyCameraDepth;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Transparent;0.5;True;True;0;True;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;SrcAlpha;OneMinusSrcAlpha;2;SrcAlpha;OneMinusSrcAlpha;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;49;0;54;0
WireConnection;39;0;38;0
WireConnection;48;0;49;0
WireConnection;40;0;39;0
WireConnection;40;1;38;4
WireConnection;24;1;48;0
WireConnection;22;0;23;0
WireConnection;47;0;24;0
WireConnection;41;0;22;0
WireConnection;41;1;40;0
WireConnection;41;2;42;0
WireConnection;25;0;26;0
WireConnection;25;1;47;0
WireConnection;50;0;41;0
WireConnection;52;0;53;0
WireConnection;52;1;47;0
WireConnection;51;0;52;0
WireConnection;51;1;25;0
WireConnection;51;2;50;0
WireConnection;55;1;48;0
WireConnection;55;5;54;0
WireConnection;37;0;51;0
WireConnection;37;1;55;0
WireConnection;37;2;51;0
WireConnection;37;3;56;0
WireConnection;37;4;57;0
WireConnection;37;9;50;0
ASEEND*/
//CHKSM=D6E8777490946E0ADB7FE1B9BCE38A63748CD562