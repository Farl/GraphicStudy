// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Anisotropic/AmplifyAnisotropicHair"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
		_Color("Color", Color) = (0.5,0.5,0.5,1)
		_Normal("Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Float) = 1
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.5
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_Strength("Strength", Float) = 1
		_Power("Power", Range( 0 , 5)) = 1
		_ShiftTex("Shift Tex", 2D) = "white" {}
		_ShiftScale("Shift Scale", Float) = 1
		_RoughnessRatio("Roughness Ratio", Range( 0 , 1)) = 0.25
		_Occlusion("Occlusion", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float3 viewDir;
		};

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float _NormalScale;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _Color;
		uniform float4 _SpecularColor;
		uniform sampler2D _ShiftTex;
		uniform float4 _ShiftTex_ST;
		uniform float _ShiftScale;
		uniform float _RoughnessRatio;
		uniform float _Smoothness;
		uniform float _Power;
		uniform float _Strength;
		uniform float _Occlusion;


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


		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 tex2DNode21 = UnpackScaleNormal( tex2D( _Normal, uv_Normal ), _NormalScale );
			float3 normal44 = tex2DNode21;
			o.Normal = normal44;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 diffuse89 = ( tex2D( _MainTex, uv_MainTex ) * _Color );
			o.Albedo = diffuse89.rgb;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 tangentLightDir182 = mul( ase_worldToTangent, ase_worldlightDir );
			float3 normalizeResult7_g43 = normalize( ( tangentLightDir182 + i.viewDir ) );
			float3 H45_g43 = normalizeResult7_g43;
			float2 uv_ShiftTex = i.uv_texcoord * _ShiftTex_ST.xy + _ShiftTex_ST.zw;
			float3 normalizeResult30 = normalize( cross( tex2DNode21 , float3(1,0,0) ) );
			float3 tangent70 = normalizeResult30;
			float3 rotatedValue163 = RotateAroundAxis( float3( 0,0,0 ), tangent70, float3( 1,0,0 ), ( ( tex2D( _ShiftTex, uv_ShiftTex ).g * _ShiftScale ) * ( 2.0 * UNITY_PI ) ) );
			float3 normalizeResult75 = normalize( rotatedValue163 );
			float3 shiftTangent76 = normalizeResult75;
			float3 T49_g43 = shiftTangent76;
			float dotResult14_g43 = dot( H45_g43 , T49_g43 );
			float dotResult53_g43 = dot( ( H45_g43 - ( T49_g43 * dotResult14_g43 ) ) , H45_g43 );
			float2 appendResult221 = (float2(_RoughnessRatio , ( 1.0 - _RoughnessRatio )));
			float2 normalizeResult222 = normalize( appendResult221 );
			float smoothness216 = _Smoothness;
			float2 roughnessXY219 = ( normalizeResult222 * smoothness216 );
			float2 specExp230 = ( exp2( ( pow( ( 1.0 - roughnessXY219 ) , 1.5 ) * float2( 14,14 ) ) ) * _Power );
			float2 break223 = specExp230;
			float2 specScale231 = ( ( 1.0 - saturate( ( roughnessXY219 * float2( 0.5,0.5 ) ) ) ) * _Strength );
			float2 break228 = specScale231;
			float3 normalizeResult7_g42 = normalize( ( tangentLightDir182 + i.viewDir ) );
			float3 H45_g42 = normalizeResult7_g42;
			float3 T49_g42 = cross( shiftTangent76 , normal44 );
			float dotResult14_g42 = dot( H45_g42 , T49_g42 );
			float dotResult53_g42 = dot( ( H45_g42 - ( T49_g42 * dotResult14_g42 ) ) , H45_g42 );
			float specularTerm41 = ( ( pow( max( dotResult53_g43 , 0.0 ) , break223.x ) * break228.x ) * ( pow( max( dotResult53_g42 , 0.0 ) , break223.y ) * break228.y ) );
			o.Specular = ( _SpecularColor * specularTerm41 ).rgb;
			o.Smoothness = smoothness216;
			o.Occlusion = _Occlusion;
			o.Alpha = (diffuse89).a;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardSpecular alpha:fade keepalpha fullforwardshadows 

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
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
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
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
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
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandardSpecular o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardSpecular, o )
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
Version=18301
8;81;1107;636;5506.271;20.65016;1.959266;True;False
Node;AmplifyShaderEditor.CommentaryNode;234;-4376.106,377.4168;Inherit;False;2233.685;481.7872;;20;212;211;230;202;224;231;6;215;197;221;217;222;218;219;199;225;226;227;229;5;Anisotropic direction;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;197;-4326.106,541.1249;Inherit;False;Property;_RoughnessRatio;Roughness Ratio;10;0;Create;True;0;0;False;0;False;0.25;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;260.6555,375.4489;Inherit;False;Property;_Smoothness;Smoothness;4;0;Create;True;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;199;-4009.886,588.6075;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;87;-1883.381,-574.4534;Inherit;False;1138.571;452.5667;;7;21;44;17;19;30;70;23;Normal & Tangent;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;221;-3840.942,556.7894;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;216;546.5729,376.481;Inherit;False;smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;222;-3701.235,557.9657;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1833.381,-475.1198;Inherit;False;Property;_NormalScale;Normal Scale;3;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;217;-3780.943,657.5287;Inherit;False;216;smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;218;-3539.771,551.6326;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;21;-1655.563,-524.4534;Inherit;True;Property;_Normal;Normal;2;0;Create;True;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;17;-1521.815,-309.8867;Inherit;False;Constant;_bitangent;bitangent;2;0;Create;True;0;0;False;0;False;1,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;91;-1895.504,1163.975;Inherit;False;1449.885;371.7865;;9;164;167;72;166;165;69;163;75;76;Shift Tangent;1,1,1,1;0;0
Node;AmplifyShaderEditor.CrossProductOpNode;19;-1304.34,-379.3517;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;219;-3391.487,543.7139;Inherit;False;roughnessXY;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalizeNode;30;-1135.394,-379.5987;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;69;-1867.405,1232.749;Inherit;True;Property;_ShiftTex;Shift Tex;8;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;167;-1788.495,1437.995;Inherit;False;Property;_ShiftScale;Shift Scale;9;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;224;-3105.896,438.0374;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;70;-968.8094,-384.743;Inherit;False;tangent;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;212;-2946.593,430.3881;Inherit;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;225;-3073.242,645.599;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;166;-1509.73,1304.871;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;164;-1565.928,1441.441;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;-1328.862,1442.004;Inherit;False;70;tangent;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;226;-2911.442,650.7501;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;215;-2780.434,427.4168;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;14,14;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;165;-1310.414,1308.256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-2797.374,543.2891;Inherit;False;Property;_Power;Power;7;0;Create;True;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;190;-961.33,-1210.987;Inherit;False;678.5547;314.4684;;4;3;16;15;182;L;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2744.151,742.204;Inherit;False;Property;_Strength;Strength;6;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Exp2OpNode;211;-2641.038,437.9654;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;227;-2746.074,652.7501;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;163;-1109.79,1310.282;Inherit;False;False;4;0;FLOAT3;1,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;75;-807.7648,1319.659;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldToTangentMatrix;16;-891.3304,-1160.987;Inherit;False;0;1;FLOAT3x3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;202;-2501.508,435.9548;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;128;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;229;-2565.728,642.1367;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;128;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;3;-911.3303,-1079.518;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;231;-2409.993,637.8065;Inherit;False;specScale;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-658.3309,-1125.487;Inherit;False;2;2;0;FLOAT3x3;0,0,0,1,1,1,1,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;230;-2366.422,427.5492;Inherit;False;specExp;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;-1300.339,-519.1149;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;191;-1890.923,62.70024;Inherit;False;1294.4;805.9844;;13;232;223;41;195;207;4;206;181;189;209;233;228;235;Strand;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;76;-650.2409,1315.084;Inherit;False;shiftTangent;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;209;-1621.994,232.9665;Inherit;False;44;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;233;-1814.985,724.1077;Inherit;False;231;specScale;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;189;-1623.375,137.0652;Inherit;False;76;shiftTangent;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;232;-1818.263,581.3414;Inherit;False;230;specExp;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;182;-510.7755,-1124.086;Inherit;False;tangentLightDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;88;-1869.589,-1248.856;Inherit;False;744.5677;476.9775;;4;89;31;27;34;Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.CrossProductOpNode;206;-1434.429,226.1668;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;181;-1609.545,328.2461;Inherit;False;182;tangentLightDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;228;-1627.58,718.0888;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.WireNode;207;-1286.887,198.3719;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;4;-1591.858,411.843;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;223;-1635.615,587.4739;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ColorNode;27;-1750.002,-988.847;Inherit;False;Property;_Color;Color;1;0;Create;True;0;0;False;0;False;0.5,0.5,0.5,1;0.5,0.5,0.5,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;235;-1226.957,494.5458;Inherit;False;StrandSpecularComplex;-1;;42;b15fe69a60789ab4eb5a5f90d34cc812;0;5;1;FLOAT3;0,1,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;1;False;5;FLOAT;128;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;236;-1225.446,304.1268;Inherit;False;StrandSpecularComplex;-1;;43;b15fe69a60789ab4eb5a5f90d34cc812;0;5;1;FLOAT3;0,1,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;1;False;5;FLOAT;128;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;34;-1819.589,-1198.857;Inherit;True;Property;_MainTex;Main Tex;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-1488.257,-1031.21;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;195;-945.0032,408.662;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;-810.7841,415.9308;Inherit;False;specularTerm;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;89;-1326.172,-1036.694;Inherit;False;diffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;161;275.2934,265.1149;Inherit;False;41;specularTerm;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;237;412.5122,465.7251;Inherit;False;89;diffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;26;266.7256,93.69812;Inherit;False;Property;_SpecularColor;Specular Color;5;0;Create;True;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;240;495.6751,265.1069;Inherit;False;Property;_Occlusion;Occlusion;11;0;Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;486.1616,152.689;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;640.4705,97.55554;Inherit;False;44;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;239;586.9765,463.8502;Inherit;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;638.8998,6.25264;Inherit;False;89;diffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;866.8475,78.8116;Float;False;True;-1;2;ASEMaterialInspector;0;0;StandardSpecular;Custom/Farl/Anisotropic/AmplifyAnisotropicHair;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;199;0;197;0
WireConnection;221;0;197;0
WireConnection;221;1;199;0
WireConnection;216;0;52;0
WireConnection;222;0;221;0
WireConnection;218;0;222;0
WireConnection;218;1;217;0
WireConnection;21;5;23;0
WireConnection;19;0;21;0
WireConnection;19;1;17;0
WireConnection;219;0;218;0
WireConnection;30;0;19;0
WireConnection;224;0;219;0
WireConnection;70;0;30;0
WireConnection;212;0;224;0
WireConnection;225;0;219;0
WireConnection;166;0;69;2
WireConnection;166;1;167;0
WireConnection;226;0;225;0
WireConnection;215;0;212;0
WireConnection;165;0;166;0
WireConnection;165;1;164;0
WireConnection;211;0;215;0
WireConnection;227;0;226;0
WireConnection;163;1;165;0
WireConnection;163;3;72;0
WireConnection;75;0;163;0
WireConnection;202;0;211;0
WireConnection;202;1;6;0
WireConnection;229;0;227;0
WireConnection;229;1;5;0
WireConnection;231;0;229;0
WireConnection;15;0;16;0
WireConnection;15;1;3;0
WireConnection;230;0;202;0
WireConnection;44;0;21;0
WireConnection;76;0;75;0
WireConnection;182;0;15;0
WireConnection;206;0;189;0
WireConnection;206;1;209;0
WireConnection;228;0;233;0
WireConnection;207;0;189;0
WireConnection;223;0;232;0
WireConnection;235;1;206;0
WireConnection;235;2;181;0
WireConnection;235;3;4;0
WireConnection;235;4;228;1
WireConnection;235;5;223;1
WireConnection;236;1;207;0
WireConnection;236;2;181;0
WireConnection;236;3;4;0
WireConnection;236;4;228;0
WireConnection;236;5;223;0
WireConnection;31;0;34;0
WireConnection;31;1;27;0
WireConnection;195;0;236;0
WireConnection;195;1;235;0
WireConnection;41;0;195;0
WireConnection;89;0;31;0
WireConnection;29;0;26;0
WireConnection;29;1;161;0
WireConnection;239;0;237;0
WireConnection;0;0;90;0
WireConnection;0;1;53;0
WireConnection;0;3;29;0
WireConnection;0;4;216;0
WireConnection;0;5;240;0
WireConnection;0;9;239;0
ASEEND*/
//CHKSM=560F4DE12B24EADF0ADC01C1D64DE4A7B9C21CBC