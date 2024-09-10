// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Standard Full Opaque"
{
	Properties
	{
		_MainTex("Albedo", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		[NoScaleOffset]_MetallicGlossMap("Metallic Smoothness", 2D) = "white" {}
		_GlossMapScale("Gloss Map Scale", Float) = 1
		[Enum(Metallic Alpha,0,Albedo Alpha,1)]_SmoothnessTextureChannel("Smoothness Texture Channel", Float) = 0
		[NoScaleOffset]_BumpMap("Normal", 2D) = "bump" {}
		_BumpScale("Normal Scale", Float) = 1
		[NoScaleOffset]_ParallaxMap("Height Map", 2D) = "gray" {}
		_Parallax("Height Map Height", Range( 0.005 , 0.08)) = 0.02
		[NoScaleOffset]_OcclusionMap("Ambient Occlusion", 2D) = "white" {}
		[NoScaleOffset]_DetailMask("Detail Mask", 2D) = "white" {}
		[HDR][NoScaleOffset]_EmissionMap("Emission", 2D) = "black" {}
		_EmissionColor("Emission Color", Color) = (0,0,0,0)
		_DetailAlbedoMap("Detail Albedo x 2", 2D) = "gray" {}
		[NoScaleOffset]_DetailNormalMap("Detail Normal", 2D) = "bump" {}
		_DetailNormalMapScale("Detail Normal Scale", Float) = 1
		[Enum(UV 1,0,UV 2,1)]_UVSec("Detail UV Set", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
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
			float2 uv2_texcoord2;
		};

		uniform float _BumpScale;
		uniform sampler2D _BumpMap;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _ParallaxMap;
		uniform float _Parallax;
		uniform float _DetailNormalMapScale;
		uniform sampler2D _DetailNormalMap;
		uniform float _UVSec;
		uniform sampler2D _DetailAlbedoMap;
		uniform float4 _DetailAlbedoMap_ST;
		uniform sampler2D _DetailMask;
		uniform float4 _Color;
		uniform float4 _EmissionColor;
		uniform sampler2D _EmissionMap;
		uniform sampler2D _MetallicGlossMap;
		uniform float _SmoothnessTextureChannel;
		uniform float _GlossMapScale;
		uniform sampler2D _OcclusionMap;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float3 normalizeResult43 = normalize( i.viewDir );
			float2 parallaxOffset49 = ( ( ( tex2D( _ParallaxMap, uv_MainTex ).g - 0.5 ) * _Parallax ) * ( (normalizeResult43).xy / ( (normalizeResult43).z + 0.42 ) ) );
			float2 parallaxUV87 = ( uv_MainTex + parallaxOffset49 );
			float3 tex2DNode4 = UnpackScaleNormal( tex2D( _BumpMap, parallaxUV87 ) ,_BumpScale );
			float2 uv2_DetailAlbedoMap = i.uv2_texcoord2 * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
			float2 uv_DetailAlbedoMap = i.uv_texcoord * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
			float2 ifLocalVar126 = 0;
			if( _UVSec <= 0 )
				ifLocalVar126 = uv_DetailAlbedoMap;
			else
				ifLocalVar126 = uv2_DetailAlbedoMap;
			float2 detailUV116 = ( ifLocalVar126 + parallaxOffset49 );
			float detailMask58 = tex2D( _DetailMask, parallaxUV87 ).a;
			float3 lerpResult72 = lerp( tex2DNode4 , BlendNormals( tex2DNode4 , UnpackScaleNormal( tex2D( _DetailNormalMap, detailUV116 ) ,_DetailNormalMapScale ) ) , detailMask58);
			float3 normal74 = lerpResult72;
			o.Normal = normal74;
			float4 tex2DNode2 = tex2D( _MainTex, parallaxUV87 );
			float4 lerpResult55 = lerp( float4(1,1,1,1) , ( tex2D( _DetailAlbedoMap, detailUV116 ) * float4(4.594794,4.594794,4.594794,2) ) , detailMask58);
			float4 albedo52 = ( _Color * tex2DNode2 * lerpResult55 );
			o.Albedo = albedo52.rgb;
			float4 emission53 = ( _EmissionColor * tex2D( _EmissionMap, parallaxUV87 ) );
			o.Emission = emission53.rgb;
			float4 tex2DNode6 = tex2D( _MetallicGlossMap, parallaxUV87 );
			float metaillic80 = (tex2DNode6.r).x;
			o.Metallic = metaillic80;
			float albedoAlpha131 = tex2DNode2.a;
			float lerpResult133 = lerp( tex2DNode6.a , albedoAlpha131 , _SmoothnessTextureChannel);
			float glossiness81 = ( lerpResult133 * _GlossMapScale );
			o.Smoothness = glossiness81;
			float4 ao91 = tex2D( _OcclusionMap, parallaxUV87 );
			o.Occlusion = ao91.r;
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
				float4 customPack1 : TEXCOORD1;
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
				o.customPack1.zw = customInputData.uv2_texcoord2;
				o.customPack1.zw = v.texcoord1;
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
				surfIN.uv2_texcoord2 = IN.customPack1.zw;
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
	CustomEditor "CustomStandardMaterialInspector"
}
/*ASEBEGIN
Version=15001
405;412;956;488;2054.214;3028.674;2.102873;True;False
Node;AmplifyShaderEditor.CommentaryNode;50;-2316.637,-3639.313;Float;False;1410.53;687.77;;15;41;43;42;111;44;46;47;49;48;40;38;25;8;39;124;Parallax Offset;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;41;-2155.072,-3217.906;Float;False;Tangent;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;124;-2229.773,-3566.591;Float;False;0;2;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;43;-1955.979,-3213.436;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-1856.418,-3397.385;Float;False;Constant;_pointfive;point five;23;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1834.115,-3046.614;Float;False;Constant;_pointfourtwo;point four two;23;0;Create;True;0;0;False;0;0.42;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;44;-1796.241,-3124.175;Float;False;FLOAT;2;1;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;8;-1989.039,-3589.313;Float;True;Property;_ParallaxMap;Height Map;8;1;[NoScaleOffset];Create;False;0;0;False;0;None;5fbdaf48b197ed344836d84221322837;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;-1976.079,-3306.73;Float;False;Property;_Parallax;Height Map Height;9;0;Create;False;0;0;False;0;0.02;0.005;0.005;0.08;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;46;-1672.558,-3224.067;Float;False;FLOAT2;0;1;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;111;-1639.158,-3126.317;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;38;-1681.228,-3478.773;Float;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;47;-1496.369,-3216.082;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-1515.895,-3478.824;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;117;-2622.694,-2810.281;Float;False;890.2375;438.0964;;7;116;118;119;126;29;129;130;Detail UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;104;-1394.692,-2773.632;Float;False;715.9779;337.6086;;4;86;85;88;87;UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-2587.875,-2742.985;Float;False;Property;_UVSec;Detail UV Set;17;1;[Enum];Create;False;2;UV 1;0;UV 2;1;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;130;-2584.317,-2492.631;Float;False;1;13;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;129;-2578.317,-2635.631;Float;False;0;13;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-1305.689,-3342.995;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ConditionalIfNode;126;-2254.315,-2718.094;Float;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;85;-1344.692,-2723.632;Float;False;0;2;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-1132.675,-3347.913;Float;False;parallaxOffset;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;-2288.665,-2490.011;Float;False;49;0;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;-1356.127,-2567.023;Float;False;49;0;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;118;-2061.348,-2582.985;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;102;-2002.938,-2210.597;Float;False;807.3475;280;;3;11;58;120;Detail Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;-1072.91,-2580.697;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;63;-2426.968,-1788.791;Float;False;1592.981;834.79;;14;52;33;94;2;31;59;57;55;60;61;62;122;13;131;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;75;-2287.906,-762.4507;Float;False;1343.706;511.4669;;10;74;73;72;110;107;121;12;4;21;16;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;116;-1942.356,-2588.047;Float;False;detailUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;-1972.561,-2122.949;Float;False;87;0;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;-1922.489,-1535.025;Float;False;87;0;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;82;-72.61226,-1740.103;Float;False;1634.239;440.2098;;11;23;132;133;6;89;26;80;81;24;78;76;Metaillic Glossiness;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;-917.7148,-2590.415;Float;False;parallaxUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;122;-2310.404,-1330.532;Float;False;116;0;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;54;-36.17406,-1200.815;Float;False;1129.358;449.4347;;5;53;34;32;15;92;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;13;-2117.81,-1353.688;Float;True;Property;_DetailAlbedoMap;Detail Albedo x 2;14;0;Create;False;0;0;False;0;None;d3a780a450cf8584793c374ad13bcaa4;True;1;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-1718.186,-1557.658;Float;True;Property;_MainTex;Albedo;0;0;Create;False;0;0;False;0;None;d5bc70618862cb04b8e4366956d3e13d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;62;-2106.475,-1148.922;Float;False;Constant;_ColorSpaceDoubleLinear;Color Space Double (Linear);23;0;Create;True;0;0;False;0;4.594794,4.594794,4.594794,2;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;11;-1736.349,-2139.859;Float;True;Property;_DetailMask;Detail Mask;11;1;[NoScaleOffset];Create;False;0;0;False;0;None;45ea98975d00f49d4a37af20347af491;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;121;-2231.313,-464.2622;Float;False;116;0;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;79.46164,-1686.559;Float;False;87;0;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-2213.544,-595.7537;Float;False;Property;_BumpScale;Normal Scale;7;0;Create;False;0;0;False;0;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;-2229.531,-699.3913;Float;False;87;0;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-2256.807,-356.6046;Float;False;Property;_DetailNormalMapScale;Detail Normal Scale;16;0;Create;False;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;12;-1962.612,-477.5663;Float;True;Property;_DetailNormalMap;Detail Normal;15;1;[NoScaleOffset];Create;False;0;0;False;0;None;8178c5ce4aa3d5341804ce7d0ff18428;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-1780.143,-1238.738;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;103;-29.7658,-560.1415;Float;False;807.3472;280;;3;90;10;91;Ambient Occlusion;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;79.48687,-932.3419;Float;False;87;0;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;-1410.074,-2048.79;Float;False;detailMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;308.8962,-1692.103;Float;True;Property;_MetallicGlossMap;Metallic Smoothness;2;1;[NoScaleOffset];Create;False;0;0;False;0;None;380d8cba402d8d4449e8f6e04c1183a9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;132;394.2551,-1495.049;Float;False;131;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-1963.633,-693.2722;Float;True;Property;_BumpMap;Normal;6;1;[NoScaleOffset];Create;False;0;0;False;0;None;dcca21e48675b2f4a94837d3a378637d;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;26;320.7464,-1399.361;Float;False;Property;_SmoothnessTextureChannel;Smoothness Texture Channel;4;1;[Enum];Create;False;2;Metallic Alpha;0;Albedo Alpha;1;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;57;-1627.927,-1361.809;Float;False;Constant;_white;white;23;0;Create;True;0;0;False;0;1,1,1,1;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;131;-1404.745,-1435.049;Float;False;albedoAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;59;-1628.082,-1164.604;Float;False;58;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;20.2342,-494.9357;Float;False;87;0;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;133;650.2551,-1578.049;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;55;-1400.56,-1263.571;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;31;-1630.543,-1735.807;Float;False;Property;_Color;Color;1;0;Create;False;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;15;320.0555,-969.6652;Float;True;Property;_EmissionMap;Emission;12;2;[HDR];[NoScaleOffset];Create;False;0;0;False;0;None;7500c8a43fbd6b344affb592fa314394;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;23;872.1564,-1447.084;Float;False;Property;_GlossMapScale;Gloss Map Scale;3;0;Create;False;0;0;False;0;1;0.57;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-1603.386,-440.1442;Float;False;58;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;32;397.5165,-1148.815;Float;False;Property;_EmissionColor;Emission Color;13;0;Create;False;0;0;False;0;0,0,0,0;0.2205879,0.2205879,0.2205879,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendNormalsNode;110;-1615.655,-544.0732;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;10;224.8636,-510.1415;Float;True;Property;_OcclusionMap;Ambient Occlusion;10;1;[NoScaleOffset];Create;False;0;0;False;0;None;ecd84d608ef693546b70a9f04f88ff0a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;1124.409,-1492.629;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;78;1160.85,-1600.689;Float;False;FLOAT;0;1;1;1;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;651.9631,-983.0614;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;72;-1373.462,-612.9913;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-1217.66,-1600.757;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;853.1836,-985.0754;Float;False;emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;116.7874,558.1895;Float;False;91;0;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;115.4455,199.8779;Float;False;74;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-1062.967,-1605.318;Float;False;albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;144.9693,113.9905;Float;False;52;0;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;111.4195,277.7134;Float;False;53;0;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;22;116.0681,822.6655;Float;False;Property;_DstBlend;Dst Blend;21;0;Fetch;False;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-42.5164,-1394.903;Float;False;Property;_Metallic;Metallic;5;0;Create;False;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;100.6835,399.8345;Float;False;80;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;81;1327.627,-1446.823;Float;False;glossiness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;74;-1187.352,-621.9869;Float;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;18;128.1438,730.0732;Float;False;Property;_Cutoff;Cutoff;19;0;Fetch;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;91;547.074,-507.198;Float;False;ao;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector4Node;61;-2400.142,-1145.576;Float;False;Constant;_ColorSpaceDoubleGamma;Color Space Double (Gamma);23;0;Create;True;0;0;False;0;2,2,2,2;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;28;115.1656,902.8947;Float;False;Property;_SrcBlend;Src Blend;20;0;Fetch;False;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;100;106.0514,472.3022;Float;False;81;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;120.4422,987.3215;Float;False;Property;_ZWrite;Z Write;22;0;Create;False;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;62.34557,1087.081;Float;False;Property;_SpecularHighlights;Specular Highlights;18;1;[Toggle];Create;False;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;1309.336,-1556.574;Float;False;metaillic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;439.2827,282.2789;Float;False;True;2;Float;CustomStandardMaterialInspector;0;0;Standard;Standard Full Opaque;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;30;0;False;-1;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;SrcAlpha;OneMinusSrcAlpha;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;43;0;41;0
WireConnection;44;0;43;0
WireConnection;8;1;124;0
WireConnection;46;0;43;0
WireConnection;111;0;44;0
WireConnection;111;1;42;0
WireConnection;38;0;8;2
WireConnection;38;1;39;0
WireConnection;47;0;46;0
WireConnection;47;1;111;0
WireConnection;40;0;38;0
WireConnection;40;1;25;0
WireConnection;48;0;40;0
WireConnection;48;1;47;0
WireConnection;126;0;29;0
WireConnection;126;2;130;0
WireConnection;126;3;129;0
WireConnection;126;4;129;0
WireConnection;49;0;48;0
WireConnection;118;0;126;0
WireConnection;118;1;119;0
WireConnection;88;0;85;0
WireConnection;88;1;86;0
WireConnection;116;0;118;0
WireConnection;87;0;88;0
WireConnection;13;1;122;0
WireConnection;2;1;94;0
WireConnection;11;1;120;0
WireConnection;12;1;121;0
WireConnection;12;5;21;0
WireConnection;60;0;13;0
WireConnection;60;1;62;0
WireConnection;58;0;11;4
WireConnection;6;1;89;0
WireConnection;4;1;107;0
WireConnection;4;5;16;0
WireConnection;131;0;2;4
WireConnection;133;0;6;4
WireConnection;133;1;132;0
WireConnection;133;2;26;0
WireConnection;55;0;57;0
WireConnection;55;1;60;0
WireConnection;55;2;59;0
WireConnection;15;1;92;0
WireConnection;110;0;4;0
WireConnection;110;1;12;0
WireConnection;10;1;90;0
WireConnection;76;0;133;0
WireConnection;76;1;23;0
WireConnection;78;0;6;1
WireConnection;34;0;32;0
WireConnection;34;1;15;0
WireConnection;72;0;4;0
WireConnection;72;1;110;0
WireConnection;72;2;73;0
WireConnection;33;0;31;0
WireConnection;33;1;2;0
WireConnection;33;2;55;0
WireConnection;53;0;34;0
WireConnection;52;0;33;0
WireConnection;81;0;76;0
WireConnection;74;0;72;0
WireConnection;91;0;10;0
WireConnection;80;0;78;0
WireConnection;0;0;96;0
WireConnection;0;1;97;0
WireConnection;0;2;98;0
WireConnection;0;3;99;0
WireConnection;0;4;100;0
WireConnection;0;5;101;0
ASEEND*/
//CHKSM=23519581F52746CF6DD584EEAFBB4853E00D7229