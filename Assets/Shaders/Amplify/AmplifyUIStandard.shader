// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifyUIStandard"
{
	Properties
	{
		_Mode("Mode", Float) = 1
		_Cutoff("Alpha Cutoff", Range( 0 , 1)) = 0.5
		[NoScaleOffset]_MainTex("Albedo", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		[Toggle(_HASMETALLICGLOSSMAP_ON)] _HasMetallicGlossMap("Has Metallic Gloss Map", Float) = 0
		[NoScaleOffset]_MetallicGlossMap("Metallic Gloss Map", 2D) = "black" {}
		_Metallic("Metallic", Range( 0 , 1)) = 1
		_GlossMapScale("Gloss Map Scale", Float) = 1
		_Glossiness("Glossiness", Float) = 1
		[NoScaleOffset]_BumpMap("Normal", 2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1
		[NoScaleOffset]_ParallaxMap("Parallax Map", 2D) = "gray" {}
		_Parallax("Parallax", Range( 0.005 , 0.08)) = 1
		[NoScaleOffset]_OcclusionMap("Occlusion Map", 2D) = "white" {}
		_OcclusionStrength("OcclusionStrength", Range( 0 , 1)) = 0
		[Toggle(_EMISSION_ON)] _Emission("Emission", Float) = 0
		[HDR]_EmissionMap("Emission Map", 2D) = "black" {}
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		_Float2("UVSec", Float) = 1
		_SpecularHighlights("SpecularHighlights", Float) = 1
		_GlossyReflections("GlossyReflections", Float) = 1
		_SrcBlend("SrcBlend", Float) = 1
		_DstBlend("DstBlend", Float) = 1
		_ZWrite("ZWrite", Float) = 1
		[KeywordEnum(MetallicAlpha,AlbedoAlpha)] _SmoothnessTextureChannel("Smoothness Texture Channel", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _EMISSION_ON
		#pragma shader_feature _HASMETALLICGLOSSMAP_ON
		#pragma shader_feature _SMOOTHNESSTEXTURECHANNEL_METALLICALPHA _SMOOTHNESSTEXTURECHANNEL_ALBEDOALPHA
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
			float3 viewDir;
			INTERNAL_DATA
			float4 vertexColor : COLOR;
		};

		uniform float _GlossyReflections;
		uniform float _BumpScale;
		uniform sampler2D _BumpMap;
		uniform float4 _BumpMap_ST;
		uniform sampler2D _ParallaxMap;
		uniform float _Parallax;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _Color;
		uniform sampler2D _EmissionMap;
		uniform float4 _EmissionMap_ST;
		uniform float4 _EmissionColor;
		uniform float _Metallic;
		uniform sampler2D _MetallicGlossMap;
		uniform float _Glossiness;
		uniform float _GlossMapScale;
		uniform sampler2D _OcclusionMap;
		uniform float _OcclusionStrength;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 transform133 = mul(unity_ObjectToWorld,float3(0,0,1));
			v.normal = transform133.xyz;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			float2 uv_ParallaxMap8 = i.uv_texcoord;
			float2 paralaxOffset89 = ParallaxOffset( 0 , ( -( tex2D( _ParallaxMap, uv_ParallaxMap8 ).r - 0 ) * _Parallax ) , i.viewDir );
			float2 ParallaxUV82 = paralaxOffset89;
			float3 Normal37 = UnpackScaleNormal( tex2D( _BumpMap, ( uv_BumpMap + ParallaxUV82 ) ) ,_BumpScale );
			o.Normal = Normal37;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, ( uv_MainTex + ParallaxUV82 ) );
			float4 temp_output_43_0 = ( tex2DNode1 * _Color * i.vertexColor );
			float4 Albedo28 = temp_output_43_0;
			o.Albedo = Albedo28.rgb;
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			#ifdef _EMISSION_ON
				float4 staticSwitch123 = ( tex2D( _EmissionMap, uv_EmissionMap ) * _EmissionColor );
			#else
				float4 staticSwitch123 = float4(0,0,0,0);
			#endif
			float4 Emission38 = staticSwitch123;
			o.Emission = Emission38.rgb;
			float4 temp_cast_2 = (_Metallic).xxxx;
			float2 uv_MetallicGlossMap6 = i.uv_texcoord;
			float4 tex2DNode6 = tex2D( _MetallicGlossMap, uv_MetallicGlossMap6 );
			#ifdef _HASMETALLICGLOSSMAP_ON
				float staticSwitch112 = 1.0;
			#else
				float staticSwitch112 = 0.0;
			#endif
			float MetallicGlossMap114 = staticSwitch112;
			float4 lerpResult120 = lerp( temp_cast_2 , tex2DNode6 , MetallicGlossMap114);
			float4 Metallic39 = lerpResult120;
			o.Metallic = Metallic39.r;
			float MetallicAlpha61 = tex2DNode6.a;
			float AlbedoAlpha67 = temp_output_43_0.a;
			#if defined(_SMOOTHNESSTEXTURECHANNEL_METALLICALPHA)
				float staticSwitch127 = 0.0;
			#elif defined(_SMOOTHNESSTEXTURECHANNEL_ALBEDOALPHA)
				float staticSwitch127 = 1.0;
			#else
				float staticSwitch127 = 0.0;
			#endif
			float lerpResult65 = lerp( ( MetallicAlpha61 * _GlossMapScale ) , ( AlbedoAlpha67 * 1 ) , staticSwitch127);
			float lerpResult121 = lerp( _Glossiness , lerpResult65 , MetallicGlossMap114);
			float Smoothness40 = lerpResult121;
			o.Smoothness = Smoothness40;
			float2 uv_OcclusionMap7 = i.uv_texcoord;
			float4 lerpResult99 = lerp( float4(1,1,1,1) , tex2D( _OcclusionMap, uv_OcclusionMap7 ) , _OcclusionStrength);
			float4 AmbientOcclusion41 = lerpResult99;
			o.Occlusion = AmbientOcclusion41.r;
			float Opacity42 = ( temp_output_43_0.a * tex2DNode1.a * i.vertexColor.a * _Color.a );
			o.Alpha = Opacity42;
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
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				fixed4 color : COLOR0;
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
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
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
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
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
454;383;707;491;337.4759;-95.64072;1.235084;True;False
Node;AmplifyShaderEditor.CommentaryNode;50;-880.891,-1680.424;Float;False;1237.57;469.7847;;8;8;82;20;85;89;90;93;98;Parallax;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;8;-833.7531,-1616.764;Float;True;Property;_ParallaxMap;Parallax Map;11;1;[NoScaleOffset];Create;False;0;0;False;0;None;7500c8a43fbd6b344affb592fa314394;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;98;-531.2642,-1625.27;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;93;-387.1882,-1622.335;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-516.8972,-1503.663;Float;False;Property;_Parallax;Parallax;12;0;Create;False;0;0;False;0;1;0.08;0.005;0.08;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-252.2789,-1618.64;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;85;-409.0375,-1393.553;Float;False;Tangent;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ParallaxOffsetHlpNode;89;-93.86723,-1600.717;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;44;-1050.927,-1019.02;Float;False;1482.545;480.7142;;12;28;42;67;45;43;26;1;84;86;87;135;136;Albedo & Opacity;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;82;113.303,-1591.585;Float;False;ParallaxUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;84;-990.4164,-825.1627;Float;False;82;0;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;86;-1032.647,-959.7826;Float;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;87;-797.0096,-940.9317;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-659.2927,-969.0198;Float;True;Property;_MainTex;Albedo;2;1;[NoScaleOffset];Create;False;0;0;False;0;None;cb38422b66a8def4e88f1d06cb13180e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;135;-766.5732,-767.2047;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;26;-563.0273,-743.0333;Float;False;Property;_Color;Color;3;0;Create;False;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-282.9712,-898.9728;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;55;-1281.38,924.7206;Float;False;1094.494;589.1334;;9;39;17;120;114;112;119;115;61;6;Metallic;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;60;-1277.512,296.1731;Float;False;1228.228;513.2042;;12;40;121;122;65;15;64;69;68;62;14;127;128;Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.BreakToComponentsNode;45;-106.7953,-802.3801;Float;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SamplerNode;6;-1254.204,1066.211;Float;True;Property;_MetallicGlossMap;Metallic Gloss Map;5;1;[NoScaleOffset];Create;False;0;0;True;0;None;380d8cba402d8d4449e8f6e04c1183a9;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;61;-931.7568,1157.228;Float;False;MetallicAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;62;-1227.393,437.6006;Float;False;61;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;-1267.368,1392.333;Float;False;Constant;_Float1;Float 1;31;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;199.0589,-862.1171;Float;False;AlbedoAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;128;-1294.926,669.9597;Float;False;Constant;_Float3;Float 3;31;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-1304.926,741.9597;Float;False;Constant;_Float4;Float 4;31;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-1258.742,1294.492;Float;False;Constant;_Float0;Float 0;31;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;53;-1669.314,-435.0999;Float;False;937.506;603.1374;;6;38;123;52;27;5;124;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;46;622.4144,-283.0332;Float;False;1090.461;403.16;;6;37;2;10;95;96;97;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;-1222.576,619.1287;Float;False;67;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1227.302,515.1903;Float;False;Property;_GlossMapScale;Gloss Map Scale;7;0;Create;False;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-1027.23,607.5209;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;49;40.85056,1031.036;Float;False;791.7454;502.2503;;5;7;101;99;41;19;Ambient Occlusion;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-968.0209,457.2864;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;27;-1576.02,-186.7477;Float;False;Property;_EmissionColor;EmissionColor;17;1;[HDR];Create;False;0;0;False;0;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-1619.314,-385.0999;Float;True;Property;_EmissionMap;Emission Map;16;1;[HDR];Create;False;0;0;False;0;None;80ab37a9e4f49c842903bb43bdd7bcd2;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;95;703.6544,-112.858;Float;False;82;0;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;127;-1116.314,706.342;Float;False;Property;_SmoothnessTextureChannel;Smoothness Texture Channel;30;0;Create;False;0;0;False;0;0;0;0;True;;KeywordEnum;2;MetallicAlpha;AlbedoAlpha;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;96;661.4238,-247.4779;Float;False;0;2;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;112;-1088.367,1306.26;Float;False;Property;_HasMetallicGlossMap;Has Metallic Gloss Map;4;0;Create;False;0;0;False;0;0;0;1;True;_METALLICGLOSSMAP;Toggle;2;_MetallicGlossMap;;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-1304.967,-247.1772;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;897.0612,-228.627;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;-795.0143,1277.318;Float;True;MetallicGlossMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1155.178,972.7701;Float;False;Property;_Metallic;Metallic;6;0;Create;False;0;0;True;0;1;0.03;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;410.0298,1265.038;Float;False;Property;_OcclusionStrength;OcclusionStrength;14;0;Create;False;0;0;False;0;0;0.37;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-746.6805,342.3386;Float;False;Property;_Glossiness;Glossiness;8;0;Create;False;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;698.7727,-6.743895;Float;False;Property;_BumpScale;Bump Scale;10;0;Create;False;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;101;111.2603,1069.219;Float;False;Constant;_white;white;28;0;Create;True;0;0;False;0;1,1,1,1;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;65;-775.4706,445.5318;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;122;-713.6334,601.0677;Float;False;114;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;124;-1187.66,-377.2935;Float;False;Constant;_black;black;30;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;77.94289,1250.173;Float;True;Property;_OcclusionMap;Occlusion Map;13;1;[NoScaleOffset];Create;False;0;0;False;0;None;ecd84d608ef693546b70a9f04f88ff0a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;1058.138,-134.5464;Float;True;Property;_BumpMap;Normal;9;1;[NoScaleOffset];Create;False;0;0;False;0;None;dcca21e48675b2f4a94837d3a378637d;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;99;445.0753,1111.704;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;120;-679.807,998.8303;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;123;-1124.948,-128.8734;Float;False;Property;_Emission;Emission;15;0;Create;False;0;0;False;0;0;0;1;True;_EMISSION;Toggle;2;Key0;Key1;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;103;-673.9293,-168.0791;Float;False;552.7657;400.8043;;4;16;22;106;126;Forward Render Options;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;121;-448.5645,497.5378;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;58;-1763.15,-1151.867;Float;False;587.5201;502.3067;;3;3;4;57;Detail;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;59;616.7995,-891.3312;Float;False;532.9725;373.8254;;3;9;12;56;Detail Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;108.7352,-670.3033;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;134;-16.64594,560.0456;Float;False;Constant;_Vector0;Vector 0;31;0;Create;True;0;0;False;0;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;34;-11.02539,192.1791;Float;False;40;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1602.458,831.9981;Float;False;Property;_ZWrite;ZWrite;27;0;Fetch;False;0;0;True;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-28.32863,-3.506989;Float;False;38;0;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1559.863,546.4857;Float;False;Property;_SrcBlend;SrcBlend;25;0;Fetch;False;0;0;True;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-281.2829,495.8479;Float;True;Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;9;666.7995,-841.3312;Float;True;Property;_DetailNormalMap;Detail Normal Map;20;0;Create;False;0;0;False;0;None;None;True;0;False;bump;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;35;-14.11073,275.4815;Float;False;41;0;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;-31.90241,91.2393;Float;False;39;0;1;COLOR;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;133;144.3541,558.0456;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;221.185,-770.9454;Float;False;Opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-940.0946,-229.9573;Float;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1746.016,402.564;Float;False;Property;_Mode;Mode;0;0;Fetch;False;0;0;True;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-485.7013,1025.993;Float;True;Metallic;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1649.099,680.6092;Float;False;Property;_Float2;UVSec;22;0;Fetch;False;0;0;True;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;126;-394.1336,-95.75736;Float;False;Property;_SpecularHighlights;Specular Highlights;28;0;Create;False;0;0;False;0;0;1;0;True;_GLOSSYREFLECTIONS_OFF;ToggleOff;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;106;-417.9165,55.20769;Float;False;Property;_GlossyReflections;Refelctions;29;0;Create;False;0;0;False;0;0;1;0;True;_GLOSSYREFLECTIONS_OFF;ToggleOff;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-1702.769,-1092.54;Float;True;Property;_DetailMask;Detail Mask;18;0;Create;False;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;36;18.2661,373.2939;Float;False;42;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;589.5958,1095.481;Float;False;AmbientOcclusion;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1561.95,467.4839;Float;False;Property;_DstBlend;DstBlend;26;0;Fetch;False;0;0;True;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;5.090897,-211.1887;Float;False;28;0;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1807.447,179.3266;Float;False;Property;_Cutoff;Alpha Cutoff;1;0;Fetch;False;0;0;True;0;0.5;0.32;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-624.9294,64.77027;Float;False;Property;_GlossyReflections;GlossyReflections;24;0;Create;False;0;0;True;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-625.4588,-105.1171;Float;False;Property;_SpecularHighlights;SpecularHighlights;23;0;Fetch;False;0;0;True;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;720.5576,-632.5057;Float;False;Property;_DetailNormalMapScale;Detail Normal Map Scale;21;0;Create;False;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-1713.15,-879.5603;Float;True;Property;_DetailAlbedoMap;Detail Albedo Map;19;0;Create;False;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-98.5932,-887.192;Float;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-18.15156,-97.31354;Float;False;37;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;982.7723,-762.9676;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-1342.63,-907.1706;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;1441.089,-206.0957;Float;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;281.2414,39.87728;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/Farl/Amplify/AmplifyUIStandard;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;SrcAlpha;OneMinusSrcAlpha;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;98;0;8;1
WireConnection;93;0;98;0
WireConnection;90;0;93;0
WireConnection;90;1;20;0
WireConnection;89;1;90;0
WireConnection;89;2;85;0
WireConnection;82;0;89;0
WireConnection;87;0;86;0
WireConnection;87;1;84;0
WireConnection;1;1;87;0
WireConnection;43;0;1;0
WireConnection;43;1;26;0
WireConnection;43;2;135;0
WireConnection;45;0;43;0
WireConnection;61;0;6;4
WireConnection;67;0;45;3
WireConnection;69;0;68;0
WireConnection;64;0;62;0
WireConnection;64;1;14;0
WireConnection;127;1;128;0
WireConnection;127;0;129;0
WireConnection;112;1;115;0
WireConnection;112;0;119;0
WireConnection;52;0;5;0
WireConnection;52;1;27;0
WireConnection;97;0;96;0
WireConnection;97;1;95;0
WireConnection;114;0;112;0
WireConnection;65;0;64;0
WireConnection;65;1;69;0
WireConnection;65;2;127;0
WireConnection;2;1;97;0
WireConnection;2;5;10;0
WireConnection;99;0;101;0
WireConnection;99;1;7;0
WireConnection;99;2;19;0
WireConnection;120;0;17;0
WireConnection;120;1;6;0
WireConnection;120;2;114;0
WireConnection;123;1;124;0
WireConnection;123;0;52;0
WireConnection;121;0;15;0
WireConnection;121;1;65;0
WireConnection;121;2;122;0
WireConnection;136;0;45;3
WireConnection;136;1;1;4
WireConnection;136;2;135;4
WireConnection;136;3;26;4
WireConnection;40;0;121;0
WireConnection;133;0;134;0
WireConnection;42;0;136;0
WireConnection;38;0;123;0
WireConnection;39;0;120;0
WireConnection;126;1;22;0
WireConnection;126;0;22;0
WireConnection;106;1;16;0
WireConnection;106;0;16;0
WireConnection;41;0;99;0
WireConnection;28;0;43;0
WireConnection;56;0;9;0
WireConnection;56;1;12;0
WireConnection;57;0;4;0
WireConnection;57;1;3;0
WireConnection;37;0;2;0
WireConnection;0;0;30;0
WireConnection;0;1;31;0
WireConnection;0;2;32;0
WireConnection;0;3;33;0
WireConnection;0;4;34;0
WireConnection;0;5;35;0
WireConnection;0;9;36;0
WireConnection;0;12;133;0
ASEEND*/
//CHKSM=871C870313BA64709FFCF63377096A2CA3EA07A4