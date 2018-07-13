// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifyTest"
{
	Properties
	{
		_Mode("Mode", Float) = 1
		_Cutoff("Alpha Cutoff", Range( 0 , 1)) = 0.5
		[NoScaleOffset]_MainTex("Albedo", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		[NoScaleOffset]_MetallicGlossMap("Metallic Gloss Map", 2D) = "black" {}
		_Metallic("Metallic", Float) = 1
		_GlossMapScale("Gloss Map Scale", Float) = 1
		_SmoothnessTextureChannel("SmoothnessTextureChannel", Float) = 1
		[NoScaleOffset]_BumpMap("Normal", 2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1
		[NoScaleOffset]_ParallaxMap("Parallax Map", 2D) = "gray" {}
		_Parallax("Parallax", Range( 0.005 , 0.08)) = 1
		[NoScaleOffset]_OcclusionMap("Occlusion Map", 2D) = "white" {}
		_OcclusionStrength("OcclusionStrength", Range( 0 , 1)) = 0
		[Toggle]_Emission("Emission", Float) = 0
		[HDR]_EmissionMap("Emission Map", 2D) = "black" {}
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		_Float2("UVSec", Float) = 1
		_SpecularHighlights("SpecularHighlights", Float) = 1
		_GlossyReflections("GlossyReflections", Float) = 1
		_SrcBlend("SrcBlend", Float) = 1
		_DstBlend("DstBlend", Float) = 1
		_ZWrite("ZWrite", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
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
			#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 viewDir;
			INTERNAL_DATA
		};

		uniform float _BumpScale;
		uniform sampler2D _BumpMap;
		uniform float4 _BumpMap_ST;
		uniform sampler2D _ParallaxMap;
		uniform float _Parallax;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _Color;
		uniform float _Emission;
		uniform sampler2D _EmissionMap;
		uniform float4 _EmissionMap_ST;
		uniform float4 _EmissionColor;
		uniform sampler2D _MetallicGlossMap;
		uniform float _Metallic;
		uniform float _GlossMapScale;
		uniform float _SmoothnessTextureChannel;
		uniform sampler2D _OcclusionMap;
		uniform float _OcclusionStrength;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			float2 uv_ParallaxMap8 = i.uv_texcoord;
			float2 paralaxOffset89 = ParallaxOffset( 0 , ( -( tex2D( _ParallaxMap, uv_ParallaxMap8 ).r - 0 ) * _Parallax ) , i.viewDir );
			float2 ParallaxUV82 = paralaxOffset89;
			float3 Normal37 = UnpackScaleNormal( tex2D( _BumpMap, ( uv_BumpMap + ParallaxUV82 ) ) ,_BumpScale );
			o.Normal = Normal37;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 temp_output_43_0 = ( tex2D( _MainTex, ( uv_MainTex + ParallaxUV82 ) ) * _Color );
			float4 Albedo28 = temp_output_43_0;
			o.Albedo = Albedo28.rgb;
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			float4 Emission38 = lerp(float4( 0,0,0,0 ),( tex2D( _EmissionMap, uv_EmissionMap ) * _EmissionColor ),_Emission);
			o.Emission = Emission38.rgb;
			float2 uv_MetallicGlossMap6 = i.uv_texcoord;
			float4 tex2DNode6 = tex2D( _MetallicGlossMap, uv_MetallicGlossMap6 );
			float4 Metallic39 = ( tex2DNode6 * _Metallic );
			o.Metallic = Metallic39.r;
			float MetallicAlpha61 = tex2DNode6.a;
			float AlbedoAlpha67 = temp_output_43_0.a;
			float lerpResult65 = lerp( ( MetallicAlpha61 * _GlossMapScale ) , ( AlbedoAlpha67 * 1 ) , _SmoothnessTextureChannel);
			float Smoothness40 = lerpResult65;
			o.Smoothness = Smoothness40;
			float2 uv_OcclusionMap7 = i.uv_texcoord;
			float4 lerpResult99 = lerp( float4(1,1,1,1) , tex2D( _OcclusionMap, uv_OcclusionMap7 ) , _OcclusionStrength);
			float4 AmbientOcclusion41 = lerpResult99;
			o.Occlusion = AmbientOcclusion41.r;
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
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
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
350;368;811;364;1238.9;227.4731;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;50;-880.891,-1680.424;Float;False;1237.57;469.7847;;8;8;82;20;85;89;90;93;98;Parallax;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;8;-833.7531,-1616.764;Float;True;Property;_ParallaxMap;Parallax Map;11;1;[NoScaleOffset];Create;False;0;0;False;0;None;7500c8a43fbd6b344affb592fa314394;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;98;-531.2642,-1625.27;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;93;-387.1882,-1622.335;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-516.8972,-1503.663;Float;False;Property;_Parallax;Parallax;12;0;Create;False;0;0;False;0;1;0.08;0.005;0.08;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-252.2789,-1618.64;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;85;-409.0375,-1393.553;Float;False;Tangent;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ParallaxOffsetHlpNode;89;-93.86723,-1600.717;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;44;-1050.927,-1019.02;Float;False;1482.545;480.7142;;10;28;42;67;45;43;26;1;84;86;87;Albedo & Opacity;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;82;113.303,-1591.585;Float;False;ParallaxUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;84;-990.4164,-825.1627;Float;False;82;0;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;86;-1032.647,-959.7826;Float;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;87;-797.0096,-940.9317;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-659.2927,-969.0198;Float;True;Property;_MainTex;Albedo;2;1;[NoScaleOffset];Create;False;0;0;False;0;None;d5bc70618862cb04b8e4366956d3e13d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;26;-576.1939,-769.866;Float;False;Property;_Color;Color;3;0;Create;False;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;55;-875.7836,1138.481;Float;False;869.7719;528.842;;5;17;39;54;61;6;Metallic;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-282.9712,-898.9728;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;53;-1669.314,-435.0999;Float;False;830.0685;461.0429;;5;66;38;52;5;27;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;46;622.4144,-283.0332;Float;False;1090.461;403.16;;6;37;2;10;95;96;97;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;6;-854.5698,1186.562;Float;True;Property;_MetallicGlossMap;Metallic Gloss Map;4;1;[NoScaleOffset];Create;False;0;0;False;0;None;7500c8a43fbd6b344affb592fa314394;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;45;-132.0176,-760.9435;Float;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CommentaryNode;60;-1277.512,296.1731;Float;False;1102.703;519.9894;;9;40;21;14;15;62;64;65;68;69;Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;95;703.6544,-112.858;Float;False;82;0;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;62;-1151.819,407.086;Float;False;61;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;-1191.105,581.829;Float;False;67;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;49;40.85056,1031.036;Float;False;791.7454;502.2503;;5;7;101;99;41;19;Ambient Occlusion;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;27;-1576.02,-186.7477;Float;False;Property;_EmissionColor;EmissionColor;17;1;[HDR];Create;False;0;0;False;0;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-1619.314,-385.0999;Float;True;Property;_EmissionMap;Emission Map;16;1;[HDR];Create;False;0;0;False;0;None;80ab37a9e4f49c842903bb43bdd7bcd2;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;96;661.4238,-247.4779;Float;False;0;2;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;184.6461,-781.0455;Float;False;AlbedoAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;61;-503.8292,1401.187;Float;False;MetallicAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1151.728,484.6758;Float;False;Property;_GlossMapScale;Gloss Map Scale;6;0;Create;False;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-857.9731,684.1594;Float;False;Property;_SmoothnessTextureChannel;SmoothnessTextureChannel;8;0;Create;False;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-892.4474,426.7719;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-513.8146,1315.82;Float;False;Property;_Metallic;Metallic;5;0;Create;False;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;698.7727,-6.743895;Float;False;Property;_BumpScale;Bump Scale;10;0;Create;False;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;77.94289,1250.173;Float;True;Property;_OcclusionMap;Occlusion Map;13;1;[NoScaleOffset];Create;False;0;0;False;0;None;ecd84d608ef693546b70a9f04f88ff0a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;101;111.2603,1069.219;Float;False;Constant;_white;white;28;0;Create;True;0;0;False;0;1,1,1,1;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;97;897.0612,-228.627;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;19;410.0298,1265.038;Float;False;Property;_OcclusionStrength;OcclusionStrength;14;0;Create;False;0;0;False;0;0;0.37;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-978.7964,573.6138;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-1304.967,-247.1772;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;59;616.7995,-891.3312;Float;False;532.9725;373.8254;;3;9;12;56;Detail Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.ToggleSwitchNode;66;-1206.951,-118.6806;Float;False;Property;_Emission;Emission;15;0;Create;False;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;103;-618.9743,-126.8629;Float;False;310.0483;278.6823;;2;22;16;Forward Render Options;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;2;1058.138,-134.5464;Float;True;Property;_BumpMap;Normal;9;1;[NoScaleOffset];Create;False;0;0;False;0;None;dcca21e48675b2f4a94837d3a378637d;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-374.8174,1190.345;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;65;-645.616,428.5875;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;58;-1763.15,-1151.867;Float;False;587.5201;502.3067;;3;3;4;57;Detail;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;99;445.0753,1111.704;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-468.5944,458.3003;Float;False;Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;720.5576,-632.5057;Float;False;Property;_DetailNormalMapScale;Detail Normal Map Scale;21;0;Create;False;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;1441.089,-206.0957;Float;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-3.933609,-34.34833;Float;False;37;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1807.447,179.3266;Float;False;Property;_Cutoff;Alpha Cutoff;1;0;Fetch;False;0;0;True;0;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-1074.893,-345.15;Float;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-1342.63,-907.1706;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1559.863,546.4857;Float;False;Property;_SrcBlend;SrcBlend;25;0;Fetch;False;0;0;True;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-548.926,-77.86291;Float;False;Property;_SpecularHighlights;SpecularHighlights;23;0;Fetch;False;0;0;True;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-569.9743,38.81936;Float;False;Property;_GlossyReflections;GlossyReflections;24;0;Fetch;False;0;0;True;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;589.5958,1095.481;Float;False;AmbientOcclusion;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;3;-1713.15,-879.5603;Float;True;Property;_DetailAlbedoMap;Detail Albedo Map;19;0;Create;False;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-194.8033,1216.179;Float;False;Metallic;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;34;-11.02539,192.1791;Float;False;40;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1602.458,831.9981;Float;False;Property;_ZWrite;ZWrite;27;0;Fetch;False;0;0;True;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1649.099,680.6092;Float;False;Property;_Float2;UVSec;22;0;Fetch;False;0;0;True;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;13.21544,-131.9745;Float;False;28;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-98.5932,-887.192;Float;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;-8.138666,351.408;Float;False;42;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1561.95,467.4839;Float;False;Property;_DstBlend;DstBlend;26;0;Fetch;False;0;0;True;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;203.0018,-692.1234;Float;False;Opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;982.7723,-762.9676;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;4;-1702.769,-1092.54;Float;True;Property;_DetailMask;Detail Mask;18;0;Create;False;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;35;-14.11073,275.4815;Float;False;41;0;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;9;666.7995,-841.3312;Float;True;Property;_DetailNormalMap;Detail Normal Map;20;0;Create;False;0;0;False;0;None;None;True;0;False;bump;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;18;-1746.016,402.564;Float;False;Property;_Mode;Mode;0;0;Fetch;False;0;0;True;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-989.8349,318.1591;Float;False;Property;_Glossiness;Glossiness;7;0;Create;False;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-14.11068,39.14686;Float;False;38;0;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;-15.65333,119.6752;Float;False;39;0;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;281.2414,39.87728;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/Farl/Amplify/AmplifyTest;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
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
WireConnection;45;0;43;0
WireConnection;67;0;45;3
WireConnection;61;0;6;4
WireConnection;64;0;62;0
WireConnection;64;1;14;0
WireConnection;97;0;96;0
WireConnection;97;1;95;0
WireConnection;69;0;68;0
WireConnection;52;0;5;0
WireConnection;52;1;27;0
WireConnection;66;1;52;0
WireConnection;2;1;97;0
WireConnection;2;5;10;0
WireConnection;54;0;6;0
WireConnection;54;1;17;0
WireConnection;65;0;64;0
WireConnection;65;1;69;0
WireConnection;65;2;21;0
WireConnection;99;0;101;0
WireConnection;99;1;7;0
WireConnection;99;2;19;0
WireConnection;40;0;65;0
WireConnection;37;0;2;0
WireConnection;38;0;66;0
WireConnection;57;0;4;0
WireConnection;57;1;3;0
WireConnection;41;0;99;0
WireConnection;39;0;54;0
WireConnection;28;0;43;0
WireConnection;42;0;45;3
WireConnection;56;0;9;0
WireConnection;56;1;12;0
WireConnection;0;0;30;0
WireConnection;0;1;31;0
WireConnection;0;2;32;0
WireConnection;0;3;33;0
WireConnection;0;4;34;0
WireConnection;0;5;35;0
ASEEND*/
//CHKSM=8B604FAD25651D4C3DF9CD676C38929C060CEA86