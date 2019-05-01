// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Standard Blend Expensive"
{
	Properties
	{
		_MainTex("Albedo", 2D) = "white" {}
		[NoScaleOffset]_MetallicGlossMap("Metallic", 2D) = "white" {}
		[NoScaleOffset]_BumpTex("Normal", 2D) = "bump" {}
		_MainTex2("Albedo 2", 2D) = "white" {}
		[NoScaleOffset]_MetallicGlossMap2("Metallic 2", 2D) = "white" {}
		[NoScaleOffset]_BumpTex2("Normal 2", 2D) = "bump" {}
		_3DNoise("3D Noise", 3D) = "white" {}
		_NoiseScale("Noise Scale", Vector) = (1,1,1,0)
		_NoiseBiasScalePower("Noise (Bias, Scale, Power)", Vector) = (0,1,1,0)
		_NoiseOffset("Noise Offset", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
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
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			fixed3 Albedo;
			fixed3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			fixed Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _BumpTex;
		uniform sampler2D _MetallicGlossMap;
		uniform sampler2D _MainTex2;
		uniform float4 _MainTex2_ST;
		uniform sampler2D _BumpTex2;
		uniform sampler2D _MetallicGlossMap2;
		uniform sampler3D _3DNoise;
		uniform float3 _NoiseScale;
		uniform float3 _NoiseOffset;
		uniform float3 _NoiseBiasScalePower;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			SurfaceOutputStandard s45 = (SurfaceOutputStandard ) 0;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			s45.Albedo = tex2D( _MainTex, uv_MainTex ).rgb;
			float2 uv_BumpTex3 = i.uv_texcoord;
			s45.Normal = WorldNormalVector( i , UnpackNormal( tex2D( _BumpTex, uv_BumpTex3 ) ) );
			s45.Emission = float3( 0,0,0 );
			float2 uv_MetallicGlossMap2 = i.uv_texcoord;
			float4 tex2DNode2 = tex2D( _MetallicGlossMap, uv_MetallicGlossMap2 );
			s45.Metallic = tex2DNode2.r;
			s45.Smoothness = tex2DNode2.a;
			s45.Occlusion = 1;

			data.light = gi.light;

			UnityGI gi45 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g45 = UnityGlossyEnvironmentSetup( s45.Smoothness, data.worldViewDir, s45.Normal, float3(0,0,0));
			gi45 = UnityGlobalIllumination( data, s45.Occlusion, s45.Normal, g45 );
			#endif

			float3 surfResult45 = LightingStandard ( s45, viewDir, gi45 ).rgb;
			surfResult45 += s45.Emission;

			SurfaceOutputStandard s48 = (SurfaceOutputStandard ) 0;
			float2 uv_MainTex2 = i.uv_texcoord * _MainTex2_ST.xy + _MainTex2_ST.zw;
			s48.Albedo = tex2D( _MainTex2, uv_MainTex2 ).rgb;
			float2 uv_BumpTex25 = i.uv_texcoord;
			s48.Normal = WorldNormalVector( i , UnpackNormal( tex2D( _BumpTex2, uv_BumpTex25 ) ) );
			s48.Emission = float3( 0,0,0 );
			float2 uv_MetallicGlossMap26 = i.uv_texcoord;
			float4 tex2DNode6 = tex2D( _MetallicGlossMap2, uv_MetallicGlossMap26 );
			s48.Metallic = tex2DNode6.r;
			s48.Smoothness = tex2DNode6.a;
			s48.Occlusion = 1;

			data.light = gi.light;

			UnityGI gi48 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g48 = UnityGlossyEnvironmentSetup( s48.Smoothness, data.worldViewDir, s48.Normal, float3(0,0,0));
			gi48 = UnityGlobalIllumination( data, s48.Occlusion, s48.Normal, g48 );
			#endif

			float3 surfResult48 = LightingStandard ( s48, viewDir, gi48 ).rgb;
			surfResult48 += s48.Emission;

			float3 ase_worldPos = i.worldPos;
			float blendMask30 = saturate( ( pow( ( tex3D( _3DNoise, ( ( ase_worldPos * _NoiseScale ) + _NoiseOffset ) ).r * _NoiseBiasScalePower.y ) , _NoiseBiasScalePower.z ) + _NoiseBiasScalePower.x ) );
			float3 lerpResult47 = lerp( surfResult45 , surfResult48 , blendMask30);
			c.rgb = lerpResult47;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

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
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
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
0;45;1440;855;1385.093;1193.718;1.900972;True;False
Node;AmplifyShaderEditor.Vector3Node;39;-1362.601,-1083.973;Float;False;Property;_NoiseScale;Noise Scale;7;0;Create;True;0;0;False;0;1,1,1;0.1,0.1,0.1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;28;-1335.311,-1248.64;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;43;-1140.858,-973.6808;Float;False;Property;_NoiseOffset;Noise Offset;9;0;Create;True;0;0;False;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-1118.4,-1221.036;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-977.3937,-1114.158;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;27;-837.7078,-1345.906;Float;True;Property;_3DNoise;3D Noise;6;0;Create;False;0;0;False;0;None;decce4e1072f54a0184d0c7ee5de69f5;True;0;False;white;LockedToTexture3D;False;Object;-1;Auto;Texture3D;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;34;-781.0672,-1154.18;Float;False;Property;_NoiseBiasScalePower;Noise (Bias, Scale, Power);8;0;Create;True;0;0;False;0;0,1,1;0.01,1.1,9.86;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-516.7988,-1280.982;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;36;-349.2338,-1198.329;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-195.8699,-1129.791;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-277.9457,-768.8246;Float;True;Property;_BumpTex;Normal;2;1;[NoScaleOffset];Create;False;0;0;False;0;None;d475e45a4ba1347f798449f5ed1b07a7;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-157.1929,-944.156;Float;True;Property;_MainTex;Albedo;0;0;Create;False;0;0;False;0;None;8bdf0b0b84b5d47718f0cae3028e6dc0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-295.7916,-310.5993;Float;True;Property;_MainTex2;Albedo 2;3;0;Create;False;0;0;False;0;None;c4bb46fe640f74770af97c4fa5a90170;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-364.5253,-574.2107;Float;True;Property;_MetallicGlossMap;Metallic;1;1;[NoScaleOffset];Create;False;0;0;False;0;None;7b0e928cf27ca4c27975908d747f7e04;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;29;-56.15111,-1080.876;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-278.1255,65.22437;Float;True;Property;_MetallicGlossMap2;Metallic 2;4;1;[NoScaleOffset];Create;False;0;0;False;0;None;7fe27d7da692e4c9796f8108663390ce;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-323.3127,-147.8569;Float;True;Property;_BumpTex2;Normal 2;5;1;[NoScaleOffset];Create;False;0;0;False;0;None;41ebe5ec07f3642eb8d89b6fcc389a95;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomStandardSurface;45;268.7525,-682.8323;Float;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;99.07677,-1073.775;Float;False;blendMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomStandardSurface;48;268.7525,-481.3292;Float;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;318.9514,-281.6988;Float;False;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-21.58863,1067.786;Float;False;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;47;636.7675,-591.614;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;836.134,-820.7768;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Custom/Farl/Standard Blend Expensive;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;40;0;28;0
WireConnection;40;1;39;0
WireConnection;42;0;40;0
WireConnection;42;1;43;0
WireConnection;27;1;42;0
WireConnection;35;0;27;1
WireConnection;35;1;34;2
WireConnection;36;0;35;0
WireConnection;36;1;34;3
WireConnection;37;0;36;0
WireConnection;37;1;34;1
WireConnection;29;0;37;0
WireConnection;45;0;1;0
WireConnection;45;1;3;0
WireConnection;45;3;2;1
WireConnection;45;4;2;4
WireConnection;30;0;29;0
WireConnection;48;0;4;0
WireConnection;48;1;5;0
WireConnection;48;3;6;1
WireConnection;48;4;6;4
WireConnection;47;0;45;0
WireConnection;47;1;48;0
WireConnection;47;2;46;0
WireConnection;0;13;47;0
ASEEND*/
//CHKSM=5989537363F639B4E00F4546656866D7359E35D8