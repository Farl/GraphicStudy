// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifyGhost"
{
	Properties
	{
		_BumpMap("Bump Map", 2D) = "bump" {}
		_Color("Color", Color) = (0,0,0,0)
		FresnelParam("Fresnel (Bias, Scale, Power)", Vector) = (0,1,3,0)
		_NormalScale("Normal Scale", Float) = 0
		_Strength("Strength", Range( 0 , 1)) = 0
		_Speed("Speed", Float) = 0
		_FadeLength("Fade Length", Float) = 0
		_FadeOffset("Fade Offset", Float) = 0
		_Float0("Float 0", Float) = 0
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
			float2 uv_texcoord;
			float eyeDepth;
		};

		uniform float4 _Color;
		uniform float _NormalScale;
		uniform sampler2D _BumpMap;
		uniform float _Speed;
		uniform float3 FresnelParam;
		uniform float _Float0;
		uniform float _FadeLength;
		uniform float _FadeOffset;
		uniform float _Strength;


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
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float2 temp_cast_0 = (_Speed).xx;
			float2 uv_TexCoord18 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
			float2 panner21 = ( uv_TexCoord18 + 1 * _Time.y * temp_cast_0);
			v.vertex.xyz += ( ase_worldNormal * sin( UnpackNormal( tex2Dlod( _BumpMap, float4( panner21, 0, 0) ) ).g ) * _Strength );
		}

		inline fixed4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return fixed4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			o.Emission = _Color.rgb;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3x3 invertVal43 = Inverse3x3( ase_worldToTangent );
			float2 temp_cast_1 = (_Speed).xx;
			float2 uv_TexCoord18 = i.uv_texcoord * float2( 1,1 ) + float2( 0,0 );
			float2 panner21 = ( uv_TexCoord18 + 1 * _Time.y * temp_cast_1);
			float fresnelNDotV4 = dot( mul( invertVal43, UnpackScaleNormal( tex2D( _BumpMap, panner21 ) ,_NormalScale ) ), ase_worldViewDir );
			float fresnelNode4 = ( FresnelParam.x + FresnelParam.y * pow( 1.0 - fresnelNDotV4, FresnelParam.z ) );
			float smoothstepResult64 = smoothstep( 0 , 1 , saturate( fresnelNode4 ));
			float cameraDepthFade37 = (( i.eyeDepth -_ProjectionParams.y - _FadeOffset ) / _FadeLength);
			o.Alpha = saturate( ( ( 1.0 - smoothstepResult64 ) * _Float0 * ( 1.0 - cameraDepthFade37 ) ) );
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
				float3 customPack1 : TEXCOORD1;
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
				o.customPack1.z = customInputData.eyeDepth;
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
				surfIN.eyeDepth = IN.customPack1.z;
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
100;425;940;435;766.2692;-319.0938;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;22;-1816.593,313.0236;Float;False;Property;_Speed;Speed;5;0;Create;True;0;0;False;0;0;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;18;-1864.49,182.9615;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;21;-1549.359,196.0972;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;44;-1464.694,-294.1696;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1354.703,-301.3004;Float;False;Property;_NormalScale;Normal Scale;3;0;Create;True;0;0;False;0;0;0.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToTangentMatrix;12;-1210.961,-486.3891;Float;False;0;1;FLOAT3x3;0
Node;AmplifyShaderEditor.InverseOpNode;43;-953.6636,-486.1139;Float;False;1;0;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.SamplerNode;5;-1113.257,-365.1458;Float;True;Property;_BumpMap;Bump Map;0;0;Create;True;0;0;False;0;None;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;6;-898.4171,-171.3747;Float;False;Property;FresnelParam;Fresnel (Bias, Scale, Power);2;0;Create;False;0;0;False;0;0,1,3;0.71,0.83,3.39;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-730.1844,-368.7262;Float;False;2;2;0;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;46;-701.6498,179.8575;Float;False;738.5002;253.6797;;4;36;38;37;39;Camera Depth Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.FresnelNode;4;-571.3868,-222.4642;Float;True;World;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-658.0625,325.537;Float;False;Property;_FadeOffset;Fade Offset;7;0;Create;True;0;0;False;0;0;10.46;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-662.6498,229.147;Float;False;Property;_FadeLength;Fade Length;6;0;Create;True;0;0;False;0;0;7.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;49;-253.1498,-188.5065;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;45;-1118.296,496.862;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CameraDepthFade;37;-414.66,229.8575;Float;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;47;-708.5089,510.6187;Float;False;805.2367;321.3444;;4;20;32;16;17;Vertex Offset;1,1,1,1;0;0
Node;AmplifyShaderEditor.SmoothstepOpNode;64;-124.7966,-200.5444;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-76.64459,23.01825;Float;False;Property;_Float0;Float 0;8;0;Create;True;0;0;False;0;0;2.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;39;-150.1495,231.3864;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;53;-16.82159,-183.2683;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;20;-658.5089,601.9631;Float;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Instance;5;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;149.8639,-29.12756;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;32;-318.8385,581.2083;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-367.7649,713.7337;Float;False;Property;_Strength;Strength;4;0;Create;True;0;0;False;0;0;0.16;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;65;-308.7491,419.0378;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-72.27221,560.6186;Float;False;3;3;0;FLOAT3;1,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;63;309.5605,39.31384;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;10;250.0282,-250.3393;Float;False;Property;_Color;Color;1;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;29;630.6039,-38.94973;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;Custom/Farl/Amplify/AmplifyGhost;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;SrcAlpha;OneMinusSrcAlpha;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;21;0;18;0
WireConnection;21;2;22;0
WireConnection;44;0;21;0
WireConnection;43;0;12;0
WireConnection;5;1;44;0
WireConnection;5;5;11;0
WireConnection;13;0;43;0
WireConnection;13;1;5;0
WireConnection;4;0;13;0
WireConnection;4;1;6;1
WireConnection;4;2;6;2
WireConnection;4;3;6;3
WireConnection;49;0;4;0
WireConnection;45;0;21;0
WireConnection;37;0;36;0
WireConnection;37;1;38;0
WireConnection;64;0;49;0
WireConnection;39;0;37;0
WireConnection;53;0;64;0
WireConnection;20;1;45;0
WireConnection;61;0;53;0
WireConnection;61;1;62;0
WireConnection;61;2;39;0
WireConnection;32;0;20;2
WireConnection;16;0;65;0
WireConnection;16;1;32;0
WireConnection;16;2;17;0
WireConnection;63;0;61;0
WireConnection;29;2;10;0
WireConnection;29;9;63;0
WireConnection;29;11;16;0
ASEEND*/
//CHKSM=BE9D22EC9F02B68EB056D79825DBAE138B11CF95