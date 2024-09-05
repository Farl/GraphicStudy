// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify GGX"
{
	Properties
	{
		_Color("Color", Color) = (0.5,0.5,0.5,1)
		_roughness("roughness", Range( 0 , 1)) = 0.5
		_F0("F0", Range( 0 , 1)) = 0
		_BumpTex("Normal", 2D) = "bump" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
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
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float4 _Color;
		uniform sampler2D _BumpTex;
		uniform float4 _BumpTex_ST;
		uniform float _roughness;
		uniform float _F0;


		float LightingFuncGGX_D15( float dotNH , float roughness )
		{
			//float LightingFuncGGX_D(float dotNH, float roughness)
			//{
				float alpha = roughness * roughness;
				float alphaSqr = alpha * alpha;
				float pi = 3.1415926f;
				float denom = dotNH *dotNH * (alphaSqr - 1.0f) + 1.0f;
				
				float D = alphaSqr / (pi * denom * denom);
				return D;
			//}
		}


		float2 LightingFuncGGX_FV3( float dotLH , float roughness )
		{
			//float2 LightingFuncGGX_FV(float dotLH, float roughness)
			//{
				float alpha = roughness * roughness;
				// F
				float F_a, F_b;
				float dotLH5 = pow(1.0f - dotLH, 5);
				F_a = 1.0f;
				F_b = dotLH5;
				// V
				float vis;
				float k = alpha / 2.0f;
				float k2 = k * k;
				float invK2 = 1.0f - k2;
				vis = rcp(dotLH * dotLH * invK2 + k2);	// rcp(a) = 1 / a
				return float2(F_a * vis, F_b * vis);
			//}
		}


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_BumpTex = i.uv_texcoord * _BumpTex_ST.xy + _BumpTex_ST.zw;
			float3 normal42 = UnpackNormal( tex2D( _BumpTex, uv_BumpTex ) );
			float3 newWorldNormal6 = normalize( (WorldNormalVector( i , normal42 )) );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult28 = dot( newWorldNormal6 , ase_worldlightDir );
			float dotNL29 = saturate( dotResult28 );
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 normalizeResult37 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float3 H9 = normalizeResult37;
			float dotResult17 = dot( newWorldNormal6 , H9 );
			float dotNH16 = saturate( dotResult17 );
			float dotNH15 = dotNH16;
			float roughness15 = _roughness;
			float localLightingFuncGGX_D15 = LightingFuncGGX_D15( dotNH15 , roughness15 );
			float D19 = localLightingFuncGGX_D15;
			float dotResult10 = dot( ase_worldlightDir , H9 );
			float dotLH12 = saturate( dotResult10 );
			float dotLH3 = dotLH12;
			float roughness3 = _roughness;
			float2 localLightingFuncGGX_FV3 = LightingFuncGGX_FV3( dotLH3 , roughness3 );
			float2 break20 = localLightingFuncGGX_FV3;
			float lerpResult48 = lerp( break20.y , break20.x , _F0);
			float FV26 = lerpResult48;
			c.rgb = ( ( _Color * dotNL29 ) + ( dotNL29 * D19 * FV26 ) ).rgb;
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
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
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
Version=18301
8;81;1107;636;3208.516;1062.827;4.564229;True;False
Node;AmplifyShaderEditor.CommentaryNode;45;-1307.221,32.0069;Inherit;False;1009.154;759.6834;;17;4;5;7;37;9;11;10;43;34;12;6;17;36;16;28;35;29;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;5;-1105.905,301.0154;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;4;-1056.298,115.4737;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;7;-842.0878,199.8266;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;37;-695.9577,204.8452;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;44;-1298.851,-312.9938;Inherit;False;617.0591;280;;2;41;42;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-525.1986,199.0791;Inherit;False;H;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;41;-1248.851,-262.9938;Inherit;True;Property;_BumpTex;Normal;3;0;Create;False;0;0;False;0;False;-1;None;24e31ecbf813d9e49bf7a1e0d4034916;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;11;-1068.974,484.3967;Inherit;False;9;H;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;-905.7899,-258.1618;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-1275.241,603.5872;Inherit;False;42;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;10;-805.9033,343.743;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;6;-1085.209,606.116;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;34;-678.2667,341.8054;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;-530.5073,337.4874;Inherit;False;dotLH;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;17;-801.252,596.4308;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;46;-1304.944,888.207;Inherit;False;1260.024;437.5679;;10;26;48;19;15;18;20;3;21;14;13;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1254.944,1154.569;Inherit;False;Property;_roughness;roughness;1;0;Create;True;0;0;False;0;False;0.5;0.39;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;14;-1145.507,1043.773;Inherit;False;12;dotLH;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;36;-678.1793,598.7371;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;3;-947.2318,1077.714;Inherit;False;//float2 LightingFuncGGX_FV(float dotLH, float roughness)$//{$	float alpha = roughness * roughness@$$	// F$	float F_a, F_b@$	float dotLH5 = pow(1.0f - dotLH, 5)@$	F_a = 1.0f@$	F_b = dotLH5@$$	// V$	float vis@$	float k = alpha / 2.0f@$	float k2 = k * k@$	float invK2 = 1.0f - k2@$	vis = rcp(dotLH * dotLH * invK2 + k2)@	// rcp(a) = 1 / a$$	return float2(F_a * vis, F_b * vis)@$//};2;False;2;True;dotLH;FLOAT;0;In;;Inherit;False;True;roughness;FLOAT;0;In;;Inherit;False;LightingFuncGGX_FV;True;False;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-533.7668,593.8525;Inherit;False;dotNH;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;28;-800.9143,474.852;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-1144.691,941.3641;Inherit;False;16;dotNH;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-770.2679,1196.975;Inherit;False;Property;_F0;F0;2;0;Create;True;0;0;False;0;False;0;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;20;-716.3896,1081.13;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LerpOp;48;-447.1843,1101.09;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;35;-678.1244,475.433;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;15;-949.8482,946.4003;Inherit;False;//float LightingFuncGGX_D(float dotNH, float roughness)$//{$	float alpha = roughness * roughness@$	float alphaSqr = alpha * alpha@$	float pi = 3.1415926f@$	float denom = dotNH *dotNH * (alphaSqr - 1.0f) + 1.0f@$	$	float D = alphaSqr / (pi * denom * denom)@$	return D@$//};1;False;2;True;dotNH;FLOAT;0;In;;Inherit;False;True;roughness;FLOAT;0;In;;Inherit;False;LightingFuncGGX_D;True;False;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-537.6532,469.7803;Inherit;False;dotNL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;-272.8198,1107.561;Inherit;False;FV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;-719.0671,938.207;Inherit;False;D;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-16.54511,471.5795;Inherit;False;19;D;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-7.545115,565.5796;Inherit;False;26;FV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-29.8972,383.0835;Inherit;False;29;dotNL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;128.9783,155.6403;Inherit;False;Property;_Color;Color;0;0;Create;True;0;0;False;0;False;0.5,0.5,0.5,1;0.215735,0.45283,0.4462054,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;359.3138,284.5847;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;244.4548,456.5795;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;492.8086,383.821;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;635.3287,169.5194;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Custom/Farl/Amplify GGX;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;47;-1307.859,-486.9187;Inherit;False;751.2999;100;http://filmicworlds.com/blog/optimizing-ggx-shaders-with-dotlh/;0;Optimized GGX;1,1,1,1;0;0
WireConnection;7;0;4;0
WireConnection;7;1;5;0
WireConnection;37;0;7;0
WireConnection;9;0;37;0
WireConnection;42;0;41;0
WireConnection;10;0;5;0
WireConnection;10;1;11;0
WireConnection;6;0;43;0
WireConnection;34;0;10;0
WireConnection;12;0;34;0
WireConnection;17;0;6;0
WireConnection;17;1;11;0
WireConnection;36;0;17;0
WireConnection;3;0;14;0
WireConnection;3;1;13;0
WireConnection;16;0;36;0
WireConnection;28;0;6;0
WireConnection;28;1;5;0
WireConnection;20;0;3;0
WireConnection;48;0;20;1
WireConnection;48;1;20;0
WireConnection;48;2;21;0
WireConnection;35;0;28;0
WireConnection;15;0;18;0
WireConnection;15;1;13;0
WireConnection;29;0;35;0
WireConnection;26;0;48;0
WireConnection;19;0;15;0
WireConnection;39;0;2;0
WireConnection;39;1;27;0
WireConnection;30;0;27;0
WireConnection;30;1;31;0
WireConnection;30;2;32;0
WireConnection;40;0;39;0
WireConnection;40;1;30;0
WireConnection;0;13;40;0
ASEEND*/
//CHKSM=B277287843CFAE99B5F8E7A6530AE254C9C69CF5