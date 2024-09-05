// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Anisotropic/Ward"
{
	Properties
	{
		_TillingOffset("Tilling & Offset", Vector) = (1,1,0,0)
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Albedo("Albedo", 2D) = "white" {}
		_AlbedoTint("Albedo Tint", Color) = (1,1,1,1)
		_Specular("Specular", 2D) = "white" {}
		_SpecularTint("Specular Tint", Color) = (1,1,1,1)
		_NormalMap("Normal Map", 2D) = "bump" {}
		_NormalAmount("Normal Amount", Range( -2 , 2)) = 1
		_AnisotropyX("Anisotropy X", Range( 0 , 1)) = 1
		_AnisotropyY("Anisotropy Y", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
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
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _NormalMap;
		uniform float4 _TillingOffset;
		uniform float _NormalAmount;
		uniform sampler2D _Albedo;
		uniform float4 _AlbedoTint;
		uniform sampler2D _Specular;
		uniform float4 _SpecularTint;
		uniform float _AnisotropyX;
		uniform float _AnisotropyY;
		uniform float _Cutoff = 0.5;

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 appendResult85 = (float2(_TillingOffset.z , _TillingOffset.w));
			float2 uv_TexCoord82 = i.uv_texcoord * appendResult85;
			float3 tex2DNode25 = UnpackScaleNormal( tex2D( _NormalMap, uv_TexCoord82 ), _NormalAmount );
			o.Normal = tex2DNode25;
			float4 temp_output_60_0 = ( tex2D( _Albedo, uv_TexCoord82 ) * _AlbedoTint );
			o.Albedo = temp_output_60_0.rgb;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult11 = normalize( ase_worldlightDir );
			float3 LightDirection12 = normalizeResult11;
			float3 normalizeResult7 = normalize( ( _WorldSpaceCameraPos - ase_worldPos ) );
			float3 ViewDirection8 = normalizeResult7;
			float3 normalizeResult71 = normalize( ( LightDirection12 + ViewDirection8 ) );
			float3 HalfVector16 = normalizeResult71;
			float3 normalizeResult86 = normalize( (WorldNormalVector( i , tex2DNode25 )) );
			float3 NormalDirection56 = normalizeResult86;
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3 normalizeResult79 = normalize( cross( NormalDirection56 , ase_worldBitangent ) );
			float3 TangentDirection78 = normalizeResult79;
			float dotResult34 = dot( HalfVector16 , TangentDirection78 );
			float HX68 = ( dotResult34 / _AnisotropyX );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 normalizeResult76 = normalize( cross( NormalDirection56 , ase_worldTangent ) );
			float3 BinormalDirection22 = normalizeResult76;
			float dotResult35 = dot( HalfVector16 , BinormalDirection22 );
			float HY41 = ( dotResult35 / _AnisotropyY );
			float dotResult29 = dot( NormalDirection56 , HalfVector16 );
			float NdotH30 = dotResult29;
			float dotResult26 = dot( NormalDirection56 , LightDirection12 );
			float NdotL27 = dotResult26;
			o.Specular = ( ( tex2D( _Specular, uv_TexCoord82 ) * _SpecularTint ) * ( exp( ( ( ( ( HX68 * HX68 ) + ( HY41 * HY41 ) ) / ( NdotH30 + 1.0 ) ) * -2.0 ) ) * max( NdotL27 , 0.0 ) ) ).rgb;
			o.Alpha = 1;
			clip( temp_output_60_0.a - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardSpecular keepalpha fullforwardshadows 

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
				SurfaceOutputStandardSpecular o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardSpecular, o )
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
7;450;1262;504;4125.643;810.1382;3.120508;True;False
Node;AmplifyShaderEditor.Vector4Node;83;-4994.344,-997.9337;Float;False;Property;_TillingOffset;Tilling & Offset;0;0;Create;True;0;0;False;0;False;1,1,0,0;1,1,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;85;-4718.344,-901.9337;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;9;-3964.098,372.1005;Inherit;False;788.9999;291.2498;View Direction Vector;5;10;8;7;6;2;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-4537.899,-520.6264;Float;False;Property;_NormalAmount;Normal Amount;7;0;Create;True;0;0;False;0;False;1;1;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;82;-4465.042,-967.233;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;10;-3935.506,506.1996;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceCameraPos;2;-3936.903,426.5996;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;25;-4161.5,-542.8994;Inherit;True;Property;_NormalMap;Normal Map;6;0;Create;True;0;0;False;0;False;-1;None;e36807a1aeb234a45bae70c88ccd5fc8;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;57;-3717.104,-319.6251;Inherit;False;539.6206;242.5598;Normal Direction Vector;3;56;23;86;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;13;-4031.492,27.7998;Inherit;False;857;212;Light Direction Vector;4;12;11;4;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;23;-3696.396,-265.5013;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;6;-3672.7,451.3;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;4;-3788.991,109.8992;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;86;-3516.534,-229.9309;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;11;-3562.794,108.3003;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;21;-2691.003,-805.1019;Inherit;False;763.1089;244.5102;Tangent Direction Vector;4;78;79;80;81;;1,1,1,1;0;0
Node;AmplifyShaderEditor.NormalizeNode;7;-3526.398,451.4003;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;24;-2701.581,-418.403;Inherit;False;776.0801;271.7102;Binormal Direction Vector;4;76;19;22;77;;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexTangentNode;77;-2664.848,-301.4307;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.VertexBinormalNode;81;-2677.044,-708.9297;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;-3387.802,-238.2254;Float;False;NormalDirection;1;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-3387.309,447.1993;Float;False;ViewDirection;3;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;17;-2678.596,51.89973;Inherit;False;497.1003;157.5099;Halfway Vector;3;16;14;71;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;-3408.897,104.4997;Float;False;LightDirection;2;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-2651.296,93.50108;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CrossProductOpNode;80;-2461.048,-763.3286;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CrossProductOpNode;19;-2454.699,-372.1008;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;76;-2296.958,-333.5321;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;79;-2292.448,-737.9286;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;71;-2515.598,98.07848;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;78;-2146.048,-717.0287;Float;False;TangentDirection;4;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-2149.901,-309.2012;Float;False;BinormalDirection;5;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-2371.798,98.70107;Float;False;HalfVector;6;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;35;-1516.398,97.39842;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-1613.096,9.198168;Float;False;Property;_AnisotropyX;Anisotropy X;8;0;Create;True;0;0;False;0;False;1;0.719;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-1649.396,265.4982;Float;False;Property;_AnisotropyY;Anisotropy Y;9;0;Create;True;0;0;False;0;False;1;0.087;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;34;-1514.698,-119.2016;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;36;-1287.598,-96.40155;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;37;-1286.598,165.5984;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;-1090.196,-78.32366;Float;False;HX;10;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;-1096.196,160.9981;Float;False;HY;11;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;29;-1957.698,373.9995;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-795.595,-20.32379;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;-1810.798,388.1992;Float;False;NdotH;9;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-759.471,301.2322;Float;False;Constant;_Float0;Float 0;-1;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-794.1968,109.4969;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-604.3973,174.2962;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-606.1968,10.49689;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;47;-448.2962,70.19641;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-444.4962,206.0756;Float;False;Constant;_Float2;Float 2;-1;0;Create;True;0;0;False;0;False;-2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;26;-2647.595,579.4006;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;90;-172.2715,544.4333;Float;False;Constant;_Float1;Float 1;-1;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-2437.394,575.6001;Float;False;NdotL;8;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-293.1968,111.4969;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ExpOpNode;44;-108.2966,114.3969;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;236.7004,-798.4986;Inherit;True;Property;_Albedo;Albedo;2;0;Create;True;0;0;False;0;False;-1;None;61ee572e89ec0bb428a27ae25c12dd48;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;65;286.2042,-115.6257;Float;False;Property;_SpecularTint;Specular Tint;5;0;Create;True;0;0;False;0;False;1,1,1,1;1,0.9298851,0,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;88;-27.22814,457.0702;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;61;221.8039,-293.2251;Inherit;True;Property;_Specular;Specular;4;0;Create;True;0;0;False;0;False;-1;None;43a4069e5be635e42aacce6f0e64fb5a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;59;247.6634,-582.6548;Float;False;Property;_AlbedoTint;Albedo Tint;3;0;Create;True;0;0;False;0;False;1,1,1,1;0.4716981,0.4716981,0.4716981,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;631.3049,-159.126;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;312.5681,206.1701;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;610.2169,-671.7184;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-2447.304,312.1978;Float;False;NdotV;7;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;3;-4003.404,110.1996;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;84;-4719.344,-995.9337;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;32;-2649.809,306.5982;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;817.605,-69.02586;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;66;896.3063,-370.9246;Inherit;True;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1333.799,-451.6001;Float;False;True;-1;2;ASEMaterialInspector;0;0;StandardSpecular;Anisotropic/Ward;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;3;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;85;0;83;3
WireConnection;85;1;83;4
WireConnection;82;0;85;0
WireConnection;25;1;82;0
WireConnection;25;5;58;0
WireConnection;23;0;25;0
WireConnection;6;0;2;0
WireConnection;6;1;10;0
WireConnection;86;0;23;0
WireConnection;11;0;4;0
WireConnection;7;0;6;0
WireConnection;56;0;86;0
WireConnection;8;0;7;0
WireConnection;12;0;11;0
WireConnection;14;0;12;0
WireConnection;14;1;8;0
WireConnection;80;0;56;0
WireConnection;80;1;81;0
WireConnection;19;0;56;0
WireConnection;19;1;77;0
WireConnection;76;0;19;0
WireConnection;79;0;80;0
WireConnection;71;0;14;0
WireConnection;78;0;79;0
WireConnection;22;0;76;0
WireConnection;16;0;71;0
WireConnection;35;0;16;0
WireConnection;35;1;22;0
WireConnection;34;0;16;0
WireConnection;34;1;78;0
WireConnection;36;0;34;0
WireConnection;36;1;38;0
WireConnection;37;0;35;0
WireConnection;37;1;39;0
WireConnection;68;0;36;0
WireConnection;41;0;37;0
WireConnection;29;0;56;0
WireConnection;29;1;16;0
WireConnection;67;0;68;0
WireConnection;67;1;68;0
WireConnection;30;0;29;0
WireConnection;43;0;41;0
WireConnection;43;1;41;0
WireConnection;48;0;30;0
WireConnection;48;1;89;0
WireConnection;45;0;67;0
WireConnection;45;1;43;0
WireConnection;47;0;45;0
WireConnection;47;1;48;0
WireConnection;26;0;56;0
WireConnection;26;1;12;0
WireConnection;27;0;26;0
WireConnection;46;0;47;0
WireConnection;46;1;50;0
WireConnection;44;0;46;0
WireConnection;1;1;82;0
WireConnection;88;0;27;0
WireConnection;88;1;90;0
WireConnection;61;1;82;0
WireConnection;62;0;61;0
WireConnection;62;1;65;0
WireConnection;87;0;44;0
WireConnection;87;1;88;0
WireConnection;60;0;1;0
WireConnection;60;1;59;0
WireConnection;33;0;32;0
WireConnection;84;0;83;1
WireConnection;84;1;83;2
WireConnection;32;0;56;0
WireConnection;32;1;8;0
WireConnection;63;0;62;0
WireConnection;63;1;87;0
WireConnection;66;0;60;0
WireConnection;0;0;60;0
WireConnection;0;1;25;0
WireConnection;0;3;63;0
WireConnection;0;10;66;3
ASEEND*/
//CHKSM=8F463E0F6D813E1268FFAEA0F26AF00610618036