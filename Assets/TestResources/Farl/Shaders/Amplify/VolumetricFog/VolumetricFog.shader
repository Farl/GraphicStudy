// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/VolumetricFog"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		[Header(VolumetricNoiseShadow)]
		_Noise("Noise", 3D) = "white" {}
		_DepthStep("Depth Step", Float) = 0.01
		_DensityBiasScalePower("Density (Bias, Scale, Power)", Vector) = (0,1,1,0)
		_SunDir("Sun Dir", Vector) = (0,-1,0,0)
		_Scale("Scale", Float) = 1
		[Header(VolumetricNoise)]
		_LightStep("Light Step", Float) = 0.1
		_Center("Center", Vector) = (0,0,0,0)
		_ShadowInt("Shadow Int", Range( 0 , 1)) = 0.5
		_Radius("Radius", Float) = 5
		_RadiusFalloff("Radius Falloff", Float) = 1
		_WindDir("Wind Dir", Vector) = (0.2,0,0,0)
		_CurlScale("Curl Scale", Float) = 0.1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float3 viewDir;
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

		uniform float _Radius;
		uniform float3 _Center;
		uniform float _DepthStep;
		uniform float _RadiusFalloff;
		uniform sampler3D _Noise;
		uniform float _Scale;
		uniform float3 _WindDir;
		uniform float _CurlScale;
		uniform float3 _DensityBiasScalePower;
		uniform float3 _SunDir;
		uniform float _LightStep;
		uniform float _ShadowInt;
		uniform float4 _Color;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float3 pos14 = ase_worldPos;
			float3 normalizeResult10 = normalize( -i.viewDir );
			float3 offset17 = ( normalizeResult10 * _DepthStep );
			float3 temp_output_8_0_g1259 = ( pos14 + ( offset17 * 3 ) );
			float3 temp_output_2_0_g1264 = temp_output_8_0_g1259;
			float mulTime10_g1264 = _Time.y * 1;
			float3 temp_output_9_0_g1264 = ( ( temp_output_2_0_g1264 * _Scale ) + ( mulTime10_g1264 * _WindDir ) );
			float temp_output_40_0_g1259 = saturate( ( saturate( ( ( _Radius - distance( _Center , temp_output_2_0_g1264 ) ) / ( _RadiusFalloff + 1E-09 ) ) ) * ( pow( ( tex3D( _Noise, ( temp_output_9_0_g1264 + ( (tex3D( _Noise, temp_output_9_0_g1264 )).rgb * _CurlScale ) ) ).r * _DensityBiasScalePower.y ) , _DensityBiasScalePower.z ) + _DensityBiasScalePower.x ) ) );
			float temp_output_464_0 = temp_output_40_0_g1259;
			float3 temp_output_8_0_g1265 = ( pos14 + ( offset17 * 2 ) );
			float3 temp_output_2_0_g1270 = temp_output_8_0_g1265;
			float mulTime10_g1270 = _Time.y * 1;
			float3 temp_output_9_0_g1270 = ( ( temp_output_2_0_g1270 * _Scale ) + ( mulTime10_g1270 * _WindDir ) );
			float temp_output_40_0_g1265 = saturate( ( saturate( ( ( _Radius - distance( _Center , temp_output_2_0_g1270 ) ) / ( _RadiusFalloff + 1E-09 ) ) ) * ( pow( ( tex3D( _Noise, ( temp_output_9_0_g1270 + ( (tex3D( _Noise, temp_output_9_0_g1270 )).rgb * _CurlScale ) ) ).r * _DensityBiasScalePower.y ) , _DensityBiasScalePower.z ) + _DensityBiasScalePower.x ) ) );
			float temp_output_465_0 = temp_output_40_0_g1265;
			float3 temp_output_8_0_g1283 = ( pos14 + ( offset17 * 0 ) );
			float3 temp_output_2_0_g1288 = temp_output_8_0_g1283;
			float mulTime10_g1288 = _Time.y * 1;
			float3 temp_output_9_0_g1288 = ( ( temp_output_2_0_g1288 * _Scale ) + ( mulTime10_g1288 * _WindDir ) );
			float temp_output_40_0_g1283 = saturate( ( saturate( ( ( _Radius - distance( _Center , temp_output_2_0_g1288 ) ) / ( _RadiusFalloff + 1E-09 ) ) ) * ( pow( ( tex3D( _Noise, ( temp_output_9_0_g1288 + ( (tex3D( _Noise, temp_output_9_0_g1288 )).rgb * _CurlScale ) ) ).r * _DensityBiasScalePower.y ) , _DensityBiasScalePower.z ) + _DensityBiasScalePower.x ) ) );
			float temp_output_466_0 = temp_output_40_0_g1283;
			float3 temp_output_8_0_g1289 = ( pos14 + ( offset17 * 0 ) );
			float3 temp_output_2_0_g1294 = temp_output_8_0_g1289;
			float mulTime10_g1294 = _Time.y * 1;
			float3 temp_output_9_0_g1294 = ( ( temp_output_2_0_g1294 * _Scale ) + ( mulTime10_g1294 * _WindDir ) );
			float temp_output_40_0_g1289 = saturate( ( saturate( ( ( _Radius - distance( _Center , temp_output_2_0_g1294 ) ) / ( _RadiusFalloff + 1E-09 ) ) ) * ( pow( ( tex3D( _Noise, ( temp_output_9_0_g1294 + ( (tex3D( _Noise, temp_output_9_0_g1294 )).rgb * _CurlScale ) ) ).r * _DensityBiasScalePower.y ) , _DensityBiasScalePower.z ) + _DensityBiasScalePower.x ) ) );
			float temp_output_467_0 = temp_output_40_0_g1289;
			float3 temp_output_16_0_g1260 = temp_output_8_0_g1259;
			float3 normalizeResult52 = normalize( _SunDir );
			float3 litOffset55 = -( normalizeResult52 * _LightStep );
			float3 temp_output_18_0_g1260 = litOffset55;
			float3 temp_output_2_0_g1263 = ( temp_output_16_0_g1260 + ( temp_output_18_0_g1260 * 1 ) );
			float mulTime10_g1263 = _Time.y * 1;
			float3 temp_output_9_0_g1263 = ( ( temp_output_2_0_g1263 * _Scale ) + ( mulTime10_g1263 * _WindDir ) );
			float3 temp_output_2_0_g1262 = ( temp_output_16_0_g1260 + ( temp_output_18_0_g1260 * 2 ) );
			float mulTime10_g1262 = _Time.y * 1;
			float3 temp_output_9_0_g1262 = ( ( temp_output_2_0_g1262 * _Scale ) + ( mulTime10_g1262 * _WindDir ) );
			float3 temp_output_2_0_g1261 = ( temp_output_16_0_g1260 + ( temp_output_18_0_g1260 * 3 ) );
			float mulTime10_g1261 = _Time.y * 1;
			float3 temp_output_9_0_g1261 = ( ( temp_output_2_0_g1261 * _Scale ) + ( mulTime10_g1261 * _WindDir ) );
			float lerpResult38_g1259 = lerp( ( 1.0 - saturate( ( ( ( saturate( ( saturate( ( ( _Radius - distance( _Center , temp_output_2_0_g1263 ) ) / ( _RadiusFalloff + 1E-09 ) ) ) * ( pow( ( tex3D( _Noise, ( temp_output_9_0_g1263 + ( (tex3D( _Noise, temp_output_9_0_g1263 )).rgb * _CurlScale ) ) ).r * _DensityBiasScalePower.y ) , _DensityBiasScalePower.z ) + _DensityBiasScalePower.x ) ) ) * 0.6 ) + ( saturate( ( saturate( ( ( _Radius - distance( _Center , temp_output_2_0_g1262 ) ) / ( _RadiusFalloff + 1E-09 ) ) ) * ( pow( ( tex3D( _Noise, ( temp_output_9_0_g1262 + ( (tex3D( _Noise, temp_output_9_0_g1262 )).rgb * _CurlScale ) ) ).r * _DensityBiasScalePower.y ) , _DensityBiasScalePower.z ) + _DensityBiasScalePower.x ) ) ) * 0.3 ) + ( saturate( ( saturate( ( ( _Radius - distance( _Center , temp_output_2_0_g1261 ) ) / ( _RadiusFalloff + 1E-09 ) ) ) * ( pow( ( tex3D( _Noise, ( temp_output_9_0_g1261 + ( (tex3D( _Noise, temp_output_9_0_g1261 )).rgb * _CurlScale ) ) ).r * _DensityBiasScalePower.y ) , _DensityBiasScalePower.z ) + _DensityBiasScalePower.x ) ) ) * 0.1 ) ) * _ShadowInt ) ) ) , 1.0 , step( temp_output_40_0_g1259 , 1E-05 ));
			float temp_output_464_9 = lerpResult38_g1259;
			float3 temp_output_16_0_g1266 = temp_output_8_0_g1265;
			float3 temp_output_18_0_g1266 = litOffset55;
			float3 temp_output_2_0_g1269 = ( temp_output_16_0_g1266 + ( temp_output_18_0_g1266 * 1 ) );
			float mulTime10_g1269 = _Time.y * 1;
			float3 temp_output_9_0_g1269 = ( ( temp_output_2_0_g1269 * _Scale ) + ( mulTime10_g1269 * _WindDir ) );
			float3 temp_output_2_0_g1268 = ( temp_output_16_0_g1266 + ( temp_output_18_0_g1266 * 2 ) );
			float mulTime10_g1268 = _Time.y * 1;
			float3 temp_output_9_0_g1268 = ( ( temp_output_2_0_g1268 * _Scale ) + ( mulTime10_g1268 * _WindDir ) );
			float3 temp_output_2_0_g1267 = ( temp_output_16_0_g1266 + ( temp_output_18_0_g1266 * 3 ) );
			float mulTime10_g1267 = _Time.y * 1;
			float3 temp_output_9_0_g1267 = ( ( temp_output_2_0_g1267 * _Scale ) + ( mulTime10_g1267 * _WindDir ) );
			float lerpResult38_g1265 = lerp( ( 1.0 - saturate( ( ( ( saturate( ( saturate( ( ( _Radius - distance( _Center , temp_output_2_0_g1269 ) ) / ( _RadiusFalloff + 1E-09 ) ) ) * ( pow( ( tex3D( _Noise, ( temp_output_9_0_g1269 + ( (tex3D( _Noise, temp_output_9_0_g1269 )).rgb * _CurlScale ) ) ).r * _DensityBiasScalePower.y ) , _DensityBiasScalePower.z ) + _DensityBiasScalePower.x ) ) ) * 0.6 ) + ( saturate( ( saturate( ( ( _Radius - distance( _Center , temp_output_2_0_g1268 ) ) / ( _RadiusFalloff + 1E-09 ) ) ) * ( pow( ( tex3D( _Noise, ( temp_output_9_0_g1268 + ( (tex3D( _Noise, temp_output_9_0_g1268 )).rgb * _CurlScale ) ) ).r * _DensityBiasScalePower.y ) , _DensityBiasScalePower.z ) + _DensityBiasScalePower.x ) ) ) * 0.3 ) + ( saturate( ( saturate( ( ( _Radius - distance( _Center , temp_output_2_0_g1267 ) ) / ( _RadiusFalloff + 1E-09 ) ) ) * ( pow( ( tex3D( _Noise, ( temp_output_9_0_g1267 + ( (tex3D( _Noise, temp_output_9_0_g1267 )).rgb * _CurlScale ) ) ).r * _DensityBiasScalePower.y ) , _DensityBiasScalePower.z ) + _DensityBiasScalePower.x ) ) ) * 0.1 ) ) * _ShadowInt ) ) ) , 1.0 , step( temp_output_40_0_g1265 , 1E-05 ));
			float temp_output_465_9 = lerpResult38_g1265;
			float3 temp_output_16_0_g1284 = temp_output_8_0_g1283;
			float3 temp_output_18_0_g1284 = litOffset55;
			float3 temp_output_2_0_g1287 = ( temp_output_16_0_g1284 + ( temp_output_18_0_g1284 * 1 ) );
			float mulTime10_g1287 = _Time.y * 1;
			float3 temp_output_9_0_g1287 = ( ( temp_output_2_0_g1287 * _Scale ) + ( mulTime10_g1287 * _WindDir ) );
			float3 temp_output_2_0_g1286 = ( temp_output_16_0_g1284 + ( temp_output_18_0_g1284 * 2 ) );
			float mulTime10_g1286 = _Time.y * 1;
			float3 temp_output_9_0_g1286 = ( ( temp_output_2_0_g1286 * _Scale ) + ( mulTime10_g1286 * _WindDir ) );
			float3 temp_output_2_0_g1285 = ( temp_output_16_0_g1284 + ( temp_output_18_0_g1284 * 3 ) );
			float mulTime10_g1285 = _Time.y * 1;
			float3 temp_output_9_0_g1285 = ( ( temp_output_2_0_g1285 * _Scale ) + ( mulTime10_g1285 * _WindDir ) );
			float lerpResult38_g1283 = lerp( ( 1.0 - saturate( ( ( ( saturate( ( saturate( ( ( _Radius - distance( _Center , temp_output_2_0_g1287 ) ) / ( _RadiusFalloff + 1E-09 ) ) ) * ( pow( ( tex3D( _Noise, ( temp_output_9_0_g1287 + ( (tex3D( _Noise, temp_output_9_0_g1287 )).rgb * _CurlScale ) ) ).r * _DensityBiasScalePower.y ) , _DensityBiasScalePower.z ) + _DensityBiasScalePower.x ) ) ) * 0.6 ) + ( saturate( ( saturate( ( ( _Radius - distance( _Center , temp_output_2_0_g1286 ) ) / ( _RadiusFalloff + 1E-09 ) ) ) * ( pow( ( tex3D( _Noise, ( temp_output_9_0_g1286 + ( (tex3D( _Noise, temp_output_9_0_g1286 )).rgb * _CurlScale ) ) ).r * _DensityBiasScalePower.y ) , _DensityBiasScalePower.z ) + _DensityBiasScalePower.x ) ) ) * 0.3 ) + ( saturate( ( saturate( ( ( _Radius - distance( _Center , temp_output_2_0_g1285 ) ) / ( _RadiusFalloff + 1E-09 ) ) ) * ( pow( ( tex3D( _Noise, ( temp_output_9_0_g1285 + ( (tex3D( _Noise, temp_output_9_0_g1285 )).rgb * _CurlScale ) ) ).r * _DensityBiasScalePower.y ) , _DensityBiasScalePower.z ) + _DensityBiasScalePower.x ) ) ) * 0.1 ) ) * _ShadowInt ) ) ) , 1.0 , step( temp_output_40_0_g1283 , 1E-05 ));
			float temp_output_466_9 = lerpResult38_g1283;
			float3 temp_output_16_0_g1290 = temp_output_8_0_g1289;
			float3 temp_output_18_0_g1290 = litOffset55;
			float3 temp_output_2_0_g1293 = ( temp_output_16_0_g1290 + ( temp_output_18_0_g1290 * 1 ) );
			float mulTime10_g1293 = _Time.y * 1;
			float3 temp_output_9_0_g1293 = ( ( temp_output_2_0_g1293 * _Scale ) + ( mulTime10_g1293 * _WindDir ) );
			float3 temp_output_2_0_g1292 = ( temp_output_16_0_g1290 + ( temp_output_18_0_g1290 * 2 ) );
			float mulTime10_g1292 = _Time.y * 1;
			float3 temp_output_9_0_g1292 = ( ( temp_output_2_0_g1292 * _Scale ) + ( mulTime10_g1292 * _WindDir ) );
			float3 temp_output_2_0_g1291 = ( temp_output_16_0_g1290 + ( temp_output_18_0_g1290 * 3 ) );
			float mulTime10_g1291 = _Time.y * 1;
			float3 temp_output_9_0_g1291 = ( ( temp_output_2_0_g1291 * _Scale ) + ( mulTime10_g1291 * _WindDir ) );
			float lerpResult38_g1289 = lerp( ( 1.0 - saturate( ( ( ( saturate( ( saturate( ( ( _Radius - distance( _Center , temp_output_2_0_g1293 ) ) / ( _RadiusFalloff + 1E-09 ) ) ) * ( pow( ( tex3D( _Noise, ( temp_output_9_0_g1293 + ( (tex3D( _Noise, temp_output_9_0_g1293 )).rgb * _CurlScale ) ) ).r * _DensityBiasScalePower.y ) , _DensityBiasScalePower.z ) + _DensityBiasScalePower.x ) ) ) * 0.6 ) + ( saturate( ( saturate( ( ( _Radius - distance( _Center , temp_output_2_0_g1292 ) ) / ( _RadiusFalloff + 1E-09 ) ) ) * ( pow( ( tex3D( _Noise, ( temp_output_9_0_g1292 + ( (tex3D( _Noise, temp_output_9_0_g1292 )).rgb * _CurlScale ) ) ).r * _DensityBiasScalePower.y ) , _DensityBiasScalePower.z ) + _DensityBiasScalePower.x ) ) ) * 0.3 ) + ( saturate( ( saturate( ( ( _Radius - distance( _Center , temp_output_2_0_g1291 ) ) / ( _RadiusFalloff + 1E-09 ) ) ) * ( pow( ( tex3D( _Noise, ( temp_output_9_0_g1291 + ( (tex3D( _Noise, temp_output_9_0_g1291 )).rgb * _CurlScale ) ) ).r * _DensityBiasScalePower.y ) , _DensityBiasScalePower.z ) + _DensityBiasScalePower.x ) ) ) * 0.1 ) ) * _ShadowInt ) ) ) , 1.0 , step( temp_output_40_0_g1289 , 1E-05 ));
			float temp_output_467_9 = lerpResult38_g1289;
			c.rgb = ( ( ( temp_output_464_0 * temp_output_464_9 ) + ( temp_output_465_0 * temp_output_465_9 ) + ( temp_output_466_0 * temp_output_466_9 ) + ( temp_output_467_9 * temp_output_467_0 ) ) * _Color ).rgb;
			c.a = max( max( temp_output_464_0 , temp_output_465_0 ) , max( temp_output_466_0 , temp_output_467_0 ) );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha fullforwardshadows 

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
				float3 worldPos : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldPos = worldPos;
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
				float3 worldPos = IN.worldPos;
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
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
31;161;962;700;917.4014;-137.1519;1.529777;True;False
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;7;-1877.93,-739.6066;Float;False;World;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;37;-1851.363,-458.1121;Float;False;Property;_SunDir;Sun Dir;2;0;Create;True;0;0;False;0;0,-1,0;0,-1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;8;-1685.861,-733.1652;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-1615.87,-347.8434;Float;False;Property;_LightStep;Light Step;3;0;Create;True;0;0;False;0;0.1;0.34;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;52;-1625.063,-452.1693;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1546.663,-611.0595;Float;False;Property;_DepthStep;Depth Step;1;0;Create;True;0;0;False;0;0.01;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;10;-1554.145,-733.3923;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-1442.146,-430.0088;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-1376.299,-681.6525;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;28;-1883.527,-900.5871;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;451;-1269.125,-431.9251;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;15;-949.4629,113.2009;Float;False;14;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;252;-944.6812,547.5339;Float;False;55;0;1;FLOAT3;0
Node;AmplifyShaderEditor.IntNode;414;-929.6524,208.6323;Float;False;Constant;_2;2;228;0;Create;True;0;0;False;0;2;0;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;415;-912.9323,438.5332;Float;False;Constant;_1;1;228;0;Create;True;0;0;False;0;0;0;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;468;-909.6272,681.7525;Float;False;Constant;_0;0;228;0;Create;True;0;0;False;0;0;0;0;1;INT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;55;-1093.356,-440.8458;Float;False;litOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;16;-945.5991,298.2758;Float;False;17;0;1;FLOAT3;0
Node;AmplifyShaderEditor.IntNode;413;-931.7423,-12.90862;Float;False;Constant;_3;3;228;0;Create;True;0;0;False;0;3;0;0;1;INT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-1696.735,-893.1288;Float;False;pos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;-1227.583,-632.2375;Float;False;offset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;465;-659.5068,159.1662;Float;False;VolumetricNoiseGet;-1;;1265;f3f8f7835811a41e1a8d1065d7fcff4b;0;4;1;FLOAT3;0,0,0;False;5;INT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;2;FLOAT;0;FLOAT;9
Node;AmplifyShaderEditor.FunctionNode;467;-664.6871,626.1937;Float;False;VolumetricNoiseGet;-1;;1289;f3f8f7835811a41e1a8d1065d7fcff4b;0;4;1;FLOAT3;0,0,0;False;5;INT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;2;FLOAT;0;FLOAT;9
Node;AmplifyShaderEditor.FunctionNode;464;-666.0171,-32.71223;Float;False;VolumetricNoiseGet;-1;;1259;f3f8f7835811a41e1a8d1065d7fcff4b;0;4;1;FLOAT3;0,0,0;False;5;INT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;2;FLOAT;0;FLOAT;9
Node;AmplifyShaderEditor.FunctionNode;466;-666.687,393.4769;Float;False;VolumetricNoiseGet;-1;;1283;f3f8f7835811a41e1a8d1065d7fcff4b;0;4;1;FLOAT3;0,0,0;False;5;INT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;2;FLOAT;0;FLOAT;9
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;472;-332.9012,917.3381;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;470;-339.0204,1009.125;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;471;-318.6631,726.116;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;473;-329.8417,824.0217;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;261;-372.0324,61.52543;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;262;-289.9322,493.8058;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;284;70.06265,98.61256;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;474;-91.19653,788.8369;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;271;124.2805,735.9604;Float;False;Property;_Color;Color;0;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;285;169.1727,467.0028;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;268;-18.36549,324.9872;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;270;-315.7328,-59.46479;Float;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;264;-179.1926,146.2155;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;426;461.821,798.3246;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;269;136.4079,541.6061;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;263;264.7583,209.1056;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;583.6812,34.57027;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Custom/Farl/Amplify/VolumetricFog;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;SrcAlpha;OneMinusSrcAlpha;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;8;0;7;0
WireConnection;52;0;37;0
WireConnection;10;0;8;0
WireConnection;53;0;52;0
WireConnection;53;1;54;0
WireConnection;12;0;10;0
WireConnection;12;1;13;0
WireConnection;451;0;53;0
WireConnection;55;0;451;0
WireConnection;14;0;28;0
WireConnection;17;0;12;0
WireConnection;465;1;15;0
WireConnection;465;5;414;0
WireConnection;465;2;16;0
WireConnection;465;3;252;0
WireConnection;467;1;15;0
WireConnection;467;5;468;0
WireConnection;467;2;16;0
WireConnection;467;3;252;0
WireConnection;464;1;15;0
WireConnection;464;5;413;0
WireConnection;464;2;16;0
WireConnection;464;3;252;0
WireConnection;466;1;15;0
WireConnection;466;5;415;0
WireConnection;466;2;16;0
WireConnection;466;3;252;0
WireConnection;472;0;466;0
WireConnection;472;1;466;9
WireConnection;470;0;467;9
WireConnection;470;1;467;0
WireConnection;471;0;464;0
WireConnection;471;1;464;9
WireConnection;473;0;465;0
WireConnection;473;1;465;9
WireConnection;261;0;464;0
WireConnection;261;1;465;0
WireConnection;262;0;466;0
WireConnection;262;1;467;0
WireConnection;284;0;261;0
WireConnection;474;0;471;0
WireConnection;474;1;473;0
WireConnection;474;2;472;0
WireConnection;474;3;470;0
WireConnection;285;0;262;0
WireConnection;268;0;264;0
WireConnection;268;1;466;9
WireConnection;268;2;466;0
WireConnection;270;1;464;9
WireConnection;270;2;464;0
WireConnection;264;0;270;0
WireConnection;264;1;465;9
WireConnection;264;2;465;0
WireConnection;426;0;474;0
WireConnection;426;1;271;0
WireConnection;269;0;268;0
WireConnection;269;1;467;9
WireConnection;269;2;467;0
WireConnection;263;0;284;0
WireConnection;263;1;285;0
WireConnection;0;9;263;0
WireConnection;0;13;426;0
ASEEND*/
//CHKSM=E90F815F32ECBA6BEC29089883C4939C9BD9BDD6