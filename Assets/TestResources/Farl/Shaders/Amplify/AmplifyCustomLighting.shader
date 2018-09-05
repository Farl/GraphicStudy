// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifyCustomLighting"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_LightDirection("Light Direction", Vector) = (1,0,0,0)
		_TextureSample1("Texture Sample 1", 2D) = "bump" {}
		_PixelNormalFactor("Pixel Normal Factor", Range( 0 , 1)) = 0
		_CustomLightFactor("Custom Light Factor", Range( 0 , 1)) = 1
		[HDR]_CustomLightColor("Custom Light Color", Color) = (1,0.7242647,0.625,1)
		_Power("Power", Range( 1 , 10)) = 3.129599
		_Add("Add", Range( 0 , 1)) = 0.3555833
		_RimPower("Rim Power", Range( 1 , 10)) = 3
		_RimScale("Rim Scale", Range( 0 , 1)) = 0.74874
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_FresnelColor("Fresnel Color", Color) = (1,1,1,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
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
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
		};

		uniform sampler2D _TextureSample1;
		uniform float4 _TextureSample1_ST;
		uniform sampler2D _TextureSample0;
		uniform float4 _TextureSample0_ST;
		uniform float4 _CustomLightColor;
		uniform float _PixelNormalFactor;
		uniform float3 _LightDirection;
		uniform float _Add;
		uniform float _Power;
		uniform float _CustomLightFactor;
		uniform float4 _FresnelColor;
		uniform float _RimScale;
		uniform float _RimPower;
		uniform float _Metallic;
		uniform float _Smoothness;


		float3x3 Inverse3x3(float3x3 input)
		{
			float3 a = input._11_21_31;
			float3 b = input._12_22_32;
			float3 c = input._13_23_33;
			return float3x3(cross(b,c), cross(c,a), cross(a,b)) * (1.0 / dot(a,cross(b,c)));
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_TextureSample1 = i.uv_texcoord * _TextureSample1_ST.xy + _TextureSample1_ST.zw;
			o.Normal = UnpackNormal( tex2D( _TextureSample1, uv_TextureSample1 ) );
			float2 uv_TextureSample0 = i.uv_texcoord * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
			o.Albedo = tex2D( _TextureSample0, uv_TextureSample0 ).rgb;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3x3 invertVal73 = Inverse3x3( ase_worldToTangent );
			float3 lerpResult43 = lerp( ase_vertexNormal , mul( invertVal73, UnpackNormal( tex2D( _TextureSample1, uv_TextureSample1 ) ) ) , _PixelNormalFactor);
			float3 normal69 = lerpResult43;
			float3 normalizeResult22 = normalize( _LightDirection );
			float dotResult17 = dot( normal69 , normalizeResult22 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNDotV56 = dot( normal69, ase_worldViewDir );
			float fresnelNode56 = ( 0 + _RimScale * pow( 1.0 - fresnelNDotV56, _RimPower ) );
			o.Emission = ( ( _CustomLightColor * tex2D( _TextureSample0, uv_TextureSample0 ) * pow( saturate( ( dotResult17 + _Add ) ) , _Power ) * _CustomLightFactor ) + ( _FresnelColor * max( fresnelNode56 , 0 ) ) ).rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
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
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
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
523;184;1010;692;4057.291;2927.931;6.341365;True;False
Node;AmplifyShaderEditor.CommentaryNode;71;-1794.127,-2091.272;Float;False;1512.918;520.2563;;8;30;65;31;42;44;43;69;73;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldToTangentMatrix;30;-1760.42,-1980.32;Float;False;0;1;FLOAT3x3;0
Node;AmplifyShaderEditor.SamplerNode;65;-1744.127,-1801.016;Float;True;Property;_TextureSample3;Texture Sample 3;2;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Instance;28;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.InverseOpNode;73;-1510.227,-1995.029;Float;False;1;0;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1113.902,-1794.745;Float;False;Property;_PixelNormalFactor;Pixel Normal Factor;3;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;42;-1095.854,-2029.491;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;76;-1990.036,-1381.472;Float;False;1918.98;810.8716;;13;55;17;53;52;23;49;47;51;64;46;70;22;16;Fake Fresnel Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-1379.42,-1890.033;Float;True;2;2;0;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;16;-1940.036,-1001.565;Float;True;Property;_LightDirection;Light Direction;1;0;Create;True;0;0;False;0;1,0,0;0,0,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;43;-752.8152,-1928.671;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-1768.351,-1098.409;Float;False;69;0;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;22;-1718.356,-1002.315;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;-524.2083,-1958.456;Float;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1564.582,-793.4145;Float;False;Property;_Add;Add;7;0;Create;True;0;0;False;0;0.3555833;0.3548508;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;67;-853.1313,-342.4012;Float;False;944.3637;495.7;;7;68;56;57;72;58;74;75;Fresnel Effect;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;17;-1497.973,-1085.741;Float;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-1212.385,-1033.286;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-802.0217,-112.5752;Float;False;Property;_RimScale;Rim Scale;9;0;Create;True;0;0;False;0;0.74874;0.4443767;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;-758.4131,-250.8768;Float;False;69;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-825.2476,4.820799;Float;False;Property;_RimPower;Rim Power;8;0;Create;True;0;0;False;0;3;2.985274;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;23;-977.6963,-1027.953;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1111.122,-769.8444;Float;False;Property;_Power;Power;6;0;Create;True;0;0;False;0;3.129599;1.967661;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;56;-459.5072,-67.19706;Float;False;Tangent;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;51;-770.649,-926.3138;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-813.5229,-685.6007;Float;False;Property;_CustomLightFactor;Custom Light Factor;4;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;49;-733.5537,-1331.472;Float;False;Property;_CustomLightColor;Custom Light Color;5;1;[HDR];Create;True;0;0;False;0;1,0.7242647,0.625,1;0.09279413,0.3850956,1.262,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;64;-805.47,-1160.786;Float;True;Property;_TextureSample2;Texture Sample 2;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;5;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;68;-228.8535,-32.75402;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;74;-464.4322,-251.6598;Float;False;Property;_FresnelColor;Fresnel Color;12;0;Create;True;0;0;False;0;1,1,1,0;1,0.704801,0.2279412,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-307.0561,-838.9959;Float;True;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-54.34301,-155.378;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;59;383.0319,-942.649;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;5;545.0764,-1904.459;Float;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;None;7130c16fd8005b546b111d341310a9a4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;28;520.5025,-1619.102;Float;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;False;0;None;302951faffe230848aa0d3df7bb70faa;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;61;621.5673,-709.1593;Float;False;Property;_Smoothness;Smoothness;11;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;66;835.8276,-881.3416;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;60;621.3971,-797.749;Float;False;Property;_Metallic;Metallic;10;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1203.284,-1193.028;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/Farl/Amplify/AmplifyCustomLighting;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;73;0;30;0
WireConnection;31;0;73;0
WireConnection;31;1;65;0
WireConnection;43;0;42;0
WireConnection;43;1;31;0
WireConnection;43;2;44;0
WireConnection;22;0;16;0
WireConnection;69;0;43;0
WireConnection;17;0;70;0
WireConnection;17;1;22;0
WireConnection;53;0;17;0
WireConnection;53;1;55;0
WireConnection;23;0;53;0
WireConnection;56;0;72;0
WireConnection;56;2;57;0
WireConnection;56;3;58;0
WireConnection;51;0;23;0
WireConnection;51;1;52;0
WireConnection;68;0;56;0
WireConnection;46;0;49;0
WireConnection;46;1;64;0
WireConnection;46;2;51;0
WireConnection;46;3;47;0
WireConnection;75;0;74;0
WireConnection;75;1;68;0
WireConnection;59;0;46;0
WireConnection;59;1;75;0
WireConnection;66;0;59;0
WireConnection;0;0;5;0
WireConnection;0;1;28;0
WireConnection;0;2;66;0
WireConnection;0;3;60;0
WireConnection;0;4;61;0
ASEEND*/
//CHKSM=929AE2B004BD76F56F74D3E13977161763CD364D