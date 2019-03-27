// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/VolumetricCloud"
{
	Properties
	{
		_MainTex("Albedo", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_BumpTex("Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Float) = 0
		_HeightScale("Height Scale", Float) = 0
		_FresnelBiasScalePower("Fresnel (Bias, Scale, Power)", Vector) = (0,1,5,0)
		_DepthStep("Depth Step", Float) = 0
		_NoiseScale("Noise Scale", Float) = 1
		_Color0("Color 0", Color) = (1,1,1,1)
		_Color1("Color 1", Color) = (1,1,1,1)
		_Color2("Color 2", Color) = (1,1,1,1)
		_DesityBiasScalePower("Desity (Bias, Scale, Power)", Vector) = (0,1,5,0)
		_Panner("Panner", Vector) = (0,-1,0,0)
		_CurlScale("Curl Scale", Float) = 0
		_CurlNoiseScale("Curl Noise Scale", Float) = 4
		_CurlPanner("Curl Panner", Vector) = (0,-1,0,0)
		_DepthFade("Depth Fade", Float) = 0
		_Smoothness("Smoothness", Float) = 0
		_Metallic("Metallic", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
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
			float2 uv_texcoord;
			float3 viewDir;
			INTERNAL_DATA
			float4 screenPos;
			float3 worldNormal;
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

		uniform float _CurlNoiseScale;
		uniform float3 _CurlPanner;
		uniform float _CurlScale;
		uniform float3 _Panner;
		uniform float _NoiseScale;
		uniform float3 _DesityBiasScalePower;
		uniform float4 _Color0;
		uniform float _DepthStep;
		uniform float4 _Color1;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _HeightScale;
		uniform float4 _Color2;
		uniform float4 _Color;
		uniform float _NormalScale;
		uniform sampler2D _BumpTex;
		uniform float4 _BumpTex_ST;
		uniform float3 _FresnelBiasScalePower;
		uniform sampler2D _CameraDepthTexture;
		uniform float _DepthFade;
		uniform float _Metallic;
		uniform float _Smoothness;


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}


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


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float curlNoiseScale100 = _CurlNoiseScale;
			float3 curlPanner104 = _CurlPanner;
			float mulTime1_g5 = _Time.y * 1;
			float3 worldPos105 = ase_worldPos;
			float simplePerlin3D15_g5 = snoise( ( curlNoiseScale100 * ( ( curlPanner104 * mulTime1_g5 ) + worldPos105 ) ) );
			float3 rotatedValue3_g5 = RotateAroundAxis( float3( 0,0,0 ), cross( UNITY_MATRIX_V[0].xyz , ase_worldViewDir ), normalize( ase_worldViewDir ), ( simplePerlin3D15_g5 * 3.1415 ) );
			float curlScale102 = _CurlScale;
			float3 panner101 = _Panner;
			float noiseScale103 = _NoiseScale;
			float simplePerlin3D26_g5 = snoise( ( ( rotatedValue3_g5 * (0 + (simplePerlin3D15_g5 - -1) * (1 - 0) / (1 - -1)) * curlScale102 ) + ( ( ( mulTime1_g5 * panner101 ) + worldPos105 ) * noiseScale103 ) ) );
			float3 density99 = _DesityBiasScalePower;
			float cloud0119 = ( pow( ( (0 + (simplePerlin3D26_g5 - -1) * (1 - 0) / (1 - -1)) * density99.y ) , density99.z ) + density99.x );
			float4 appendResult163 = (float4(_Color0.a , _Color0.a , _Color0.a , 1));
			float mulTime1_g3 = _Time.y * 1;
			float3 normalizeResult74 = normalize( -ase_worldViewDir );
			float3 rayStep107 = ( normalizeResult74 * _DepthStep );
			float simplePerlin3D15_g3 = snoise( ( curlNoiseScale100 * ( ( curlPanner104 * mulTime1_g3 ) + ( worldPos105 + ( rayStep107 * 1 ) ) ) ) );
			float3 rotatedValue3_g3 = RotateAroundAxis( float3( 0,0,0 ), cross( UNITY_MATRIX_V[0].xyz , ase_worldViewDir ), normalize( ase_worldViewDir ), ( simplePerlin3D15_g3 * 3.1415 ) );
			float simplePerlin3D26_g3 = snoise( ( ( rotatedValue3_g3 * (0 + (simplePerlin3D15_g3 - -1) * (1 - 0) / (1 - -1)) * curlScale102 ) + ( ( ( mulTime1_g3 * panner101 ) + ( worldPos105 + ( rayStep107 * 1 ) ) ) * noiseScale103 ) ) );
			float cloud1129 = ( pow( ( (0 + (simplePerlin3D26_g3 - -1) * (1 - 0) / (1 - -1)) * density99.y ) , density99.z ) + density99.x );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float heightScale200 = _HeightScale;
			float2 Offset191 = ( ( cloud1129 - 1 ) * i.viewDir.xy * heightScale200 ) + uv_MainTex;
			float4 appendResult165 = (float4(_Color1.a , _Color1.a , _Color1.a , 1));
			float mulTime1_g4 = _Time.y * 1;
			float simplePerlin3D15_g4 = snoise( ( curlNoiseScale100 * ( ( curlPanner104 * mulTime1_g4 ) + ( worldPos105 + ( rayStep107 * 2 ) ) ) ) );
			float3 rotatedValue3_g4 = RotateAroundAxis( float3( 0,0,0 ), cross( UNITY_MATRIX_V[0].xyz , ase_worldViewDir ), normalize( ase_worldViewDir ), ( simplePerlin3D15_g4 * 3.1415 ) );
			float simplePerlin3D26_g4 = snoise( ( ( rotatedValue3_g4 * (0 + (simplePerlin3D15_g4 - -1) * (1 - 0) / (1 - -1)) * curlScale102 ) + ( ( ( mulTime1_g4 * panner101 ) + ( worldPos105 + ( rayStep107 * 2 ) ) ) * noiseScale103 ) ) );
			float cloud2155 = ( pow( ( (0 + (simplePerlin3D26_g4 - -1) * (1 - 0) / (1 - -1)) * density99.y ) , density99.z ) + density99.x );
			float4 appendResult168 = (float4(_Color2.a , _Color2.a , _Color2.a , 1));
			float2 uv_BumpTex = i.uv_texcoord * _BumpTex_ST.xy + _BumpTex_ST.zw;
			float2 Offset196 = ( ( cloud1129 - 1 ) * i.viewDir.xy * heightScale200 ) + uv_BumpTex;
			float3 normal172 = UnpackScaleNormal( tex2D( _BumpTex, Offset196 ) ,_NormalScale );
			float dotResult205 = dot( normal172 , i.viewDir );
			float invFresnel11 = saturate( ( pow( ( saturate( dotResult205 ) * _FresnelBiasScalePower.y ) , _FresnelBiasScalePower.z ) + _FresnelBiasScalePower.x ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth175 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(ase_screenPos))));
			float distanceDepth175 = abs( ( screenDepth175 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFade ) );
			float4 appendResult174 = (float4(1 , 1 , 1 , ( invFresnel11 * saturate( distanceDepth175 ) )));
			float4 temp_output_160_0 = ( ( ( ( cloud0119 * _Color0 ) * appendResult163 ) + ( ( cloud1129 * _Color1 * tex2D( _MainTex, Offset191 ) ) * appendResult165 ) + ( ( cloud2155 * _Color2 ) * appendResult168 ) ) * _Color * appendResult174 );
			SurfaceOutputStandard s219 = (SurfaceOutputStandard ) 0;
			s219.Albedo = (temp_output_160_0).rgb;
			s219.Normal = WorldNormalVector( i , normal172 );
			s219.Emission = float3( 0,0,0 );
			s219.Metallic = _Metallic;
			s219.Smoothness = _Smoothness;
			s219.Occlusion = 1;

			data.light = gi.light;

			UnityGI gi219 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g219 = UnityGlossyEnvironmentSetup( s219.Smoothness, data.worldViewDir, s219.Normal, float3(0,0,0));
			gi219 = UnityGlobalIllumination( data, s219.Occlusion, s219.Normal, g219 );
			#endif

			float3 surfResult219 = LightingStandard ( s219, viewDir, gi219 ).rgb;
			surfResult219 += s219.Emission;

			c.rgb = surfResult219;
			c.a = saturate( (temp_output_160_0).a );
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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
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
				o.screenPos = ComputeScreenPos( o.pos );
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
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.screenPos = IN.screenPos;
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
1959;294;1436;821;-458.7956;1684.452;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;213;-4241.017,-2357.382;Float;False;983.592;463.3469;;8;72;106;74;76;73;69;107;105;World;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;72;-4191.017,-2091.498;Float;False;World;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;106;-3968.333,-2086.945;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-3828.407,-2009.036;Float;False;Property;_DepthStep;Depth Step;7;0;Create;True;0;0;False;0;0;0.34;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;74;-3821.984,-2088.882;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-3665.629,-2092.421;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;214;-4438.518,-1576.757;Float;False;1346.645;2905.411;;35;155;119;181;180;151;148;118;150;109;112;153;111;147;149;114;152;110;113;146;145;143;144;129;182;122;130;125;121;126;123;124;127;131;132;134;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.IntNode;134;-4360.755,-691.6929;Float;False;Constant;_Int0;Int 0;12;0;Create;True;0;0;False;0;1;0;0;1;INT;0
Node;AmplifyShaderEditor.GetLocalVarNode;132;-4388.518,-773.5897;Float;False;107;0;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;69;-3963.166,-2306.635;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;107;-3500.424,-2095.098;Float;False;rayStep;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;212;-2999.745,-2376.506;Float;False;1525.447;593.766;;14;53;49;83;39;98;21;101;104;103;100;102;99;193;200;Variables;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;39;-2901.98,-2326.432;Float;False;Property;_Panner;Panner;13;0;Create;True;0;0;False;0;0,-1,0;0,0.2,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;83;-2901.892,-2139.464;Float;False;Property;_CurlPanner;Curl Panner;16;0;Create;True;0;0;False;0;0,-1,0;0,-0.1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;21;-2395.305,-2322.77;Float;False;Property;_NoiseScale;Noise Scale;8;0;Create;True;0;0;False;0;1;1.48;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;98;-2949.745,-1966.74;Float;False;Property;_DesityBiasScalePower;Desity (Bias, Scale, Power);12;0;Create;True;0;0;False;0;0,1,5;0,1.03,0.27;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;127;-4209.865,-825.3994;Float;False;105;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;-4178.916,-748.6039;Float;False;2;2;0;FLOAT3;0,0,0;False;1;INT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-1912.543,-2129.003;Float;False;Property;_CurlScale;Curl Scale;14;0;Create;True;0;0;False;0;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-2407.055,-2135.93;Float;False;Property;_CurlNoiseScale;Curl Noise Scale;15;0;Create;True;0;0;False;0;4;0.88;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;105;-3736.457,-2307.382;Float;False;worldPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;103;-2199.376,-2323.79;Float;False;noiseScale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;104;-2652.56,-2139.824;Float;False;curlPanner;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-2669.543,-2326.506;Float;False;panner;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;100;-2175.162,-2136.598;Float;False;curlNoiseScale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;126;-4062.06,-676.1776;Float;False;99;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;-4070.211,-457.2549;Float;False;103;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;124;-4086.571,-604.0425;Float;False;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;123;-4059.043,-302.7717;Float;False;104;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;125;-4062.765,-535.4269;Float;False;102;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;-2640.308,-1966.092;Float;False;density;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;102;-1717.298,-2131.842;Float;False;curlScale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;130;-3948.492,-802.7393;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;122;-4064.626,-388.3889;Float;False;101;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;193;-2335.368,-1918.252;Float;False;Property;_HeightScale;Height Scale;5;0;Create;True;0;0;False;0;0;0.04;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;182;-3745.298,-701.5082;Float;False;3DCloud;-1;;3;34a03e0bd662f19429eba9f31f27d6d3;0;7;44;FLOAT3;0,0,0;False;38;FLOAT3;0,0,0;False;37;FLOAT;1;False;35;FLOAT3;0,0,0;False;34;FLOAT3;0,0,0;False;36;FLOAT;1;False;39;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;210;-1224.53,-1539.542;Float;False;1186.857;631.2094;;8;172;202;3;197;196;203;4;199;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;199;-1096.398,-1092.333;Float;False;Tangent;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-2135.472,-1919.926;Float;False;heightScale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;197;-1084.877,-1193.056;Float;False;129;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;-1155.031,-1328.786;Float;False;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;129;-3334.317,-705.3726;Float;False;cloud1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-1174.53,-1489.542;Float;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ParallaxMappingNode;196;-889.8168,-1472.521;Float;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0.01;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;203;-767.5983,-1268.383;Float;False;Property;_NormalScale;Normal Scale;4;0;Create;True;0;0;False;0;0;-0.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;211;38.78221,-1508.899;Float;False;1390.069;488.5454;;9;204;205;10;207;170;206;11;2;222;Invert Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;4;-597.4297,-1477.459;Float;True;Property;_BumpTex;Normal;3;0;Create;False;0;0;False;0;None;00e0021f9f2d77a4fb3d5957267488e7;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;172;-280.6734,-1469.332;Float;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;204;88.78221,-1369.805;Float;False;Tangent;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;205;288.8771,-1458.899;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;10;429.459,-1449.516;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;2;318.0934,-1204.354;Float;False;Property;_FresnelBiasScalePower;Fresnel (Bias, Scale, Power);6;0;Create;True;0;0;False;0;0,1,5;-0.85,2.19,1.75;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.IntNode;144;-4356.725,21.22241;Float;False;Constant;_Int1;Int 1;12;0;Create;True;0;0;False;0;2;0;0;1;INT;0
Node;AmplifyShaderEditor.GetLocalVarNode;143;-4384.487,-60.67458;Float;False;107;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;-4174.885,-35.68867;Float;False;2;2;0;FLOAT3;0,0,0;False;1;INT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;207;628.6358,-1441.645;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;-4205.834,-112.4843;Float;False;105;0;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;215;-2177.885,537.2164;Float;False;898.8301;582.4574;;6;192;179;201;195;191;178;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;-4228.325,-1055.489;Float;False;104;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;-2121.431,815.1684;Float;False;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;150;-3944.462,-89.8242;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;118;-4222.291,-1526.757;Float;False;105;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;148;-4055.012,410.1436;Float;False;104;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;-4066.18,255.6603;Float;False;103;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;170;789.8184,-1440.991;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;109;-4231.342,-1428.894;Float;False;99;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;152;-4060.595,324.5264;Float;False;101;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;111;-4232.047,-1288.143;Float;False;102;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;153;-4058.734,177.4883;Float;False;102;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;-4239.493,-1209.971;Float;False;103;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;195;-1993.812,935.6738;Float;False;Tangent;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;179;-2057.669,607.6686;Float;False;0;178;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;192;-2127.885,733.7146;Float;False;129;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;-4255.853,-1356.759;Float;False;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;-4058.029,36.73774;Float;False;99;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;-4233.908,-1141.105;Float;False;101;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;147;-4082.54,108.8726;Float;False;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;180;-3741.267,11.40703;Float;False;3DCloud;-1;;4;34a03e0bd662f19429eba9f31f27d6d3;0;7;44;FLOAT3;0,0,0;False;38;FLOAT3;0,0,0;False;37;FLOAT;1;False;35;FLOAT3;0,0,0;False;34;FLOAT3;0,0,0;False;36;FLOAT;1;False;39;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;206;1046.646,-1436.402;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;181;-3914.58,-1454.225;Float;False;3DCloud;-1;;5;34a03e0bd662f19429eba9f31f27d6d3;0;7;44;FLOAT3;0,0,0;False;38;FLOAT3;0,0,0;False;37;FLOAT;1;False;35;FLOAT3;0,0,0;False;34;FLOAT3;0,0,0;False;36;FLOAT;1;False;39;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxMappingNode;191;-1828.435,642.1506;Float;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0.01;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;176;-606.8838,1245.274;Float;False;Property;_DepthFade;Depth Fade;17;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;155;-3330.286,7.542645;Float;False;cloud2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;119;-3503.598,-1459.477;Float;False;cloud0;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;135;-993.2345,401.2469;Float;False;129;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;222;1175.796,-1386.452;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;157;-1030.276,542.0804;Float;False;Property;_Color1;Color 1;10;0;Create;True;0;0;False;0;1,1,1,1;0.9117647,0.9117647,0.9117647,0.547;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;175;-434.2087,1243.387;Float;False;True;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;156;-997.1236,801.6785;Float;False;155;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;137;-1037.754,197.5358;Float;False;Property;_Color0;Color 0;9;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,0.141;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;178;-1600.055,587.2164;Float;True;Property;_MainTex;Albedo;1;0;Create;False;0;0;False;0;None;efd0eee9e4394a94db1426ce0bb7a902;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;57;-1014.699,104.9986;Float;False;119;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;159;-1047.799,885.9735;Float;False;Property;_Color2;Color 2;11;0;Create;True;0;0;False;0;1,1,1,1;0.5128743,0.4749134,0.5294118,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-722.9019,427.5268;Float;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;163;-775.3849,214.526;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;1321.851,-1449.961;Float;True;invFresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;165;-718.486,557.1035;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;-792.4375,93.40507;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;12;-213.533,908.3427;Float;False;11;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;209;-242.2087,1243.387;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;168;-760.721,917.488;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;158;-772.2162,803.5792;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;-30.94601,917.3965;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;166;-558.6279,421.7141;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;164;-591.7742,170.6785;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;167;-594.3378,809.8289;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;174;107.1332,851.8628;Float;False;FLOAT4;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;36;-53.50126,578.9486;Float;False;Property;_Color;Color;2;0;Create;True;0;0;False;0;1,1,1,1;0.9920892,0.9558824,1,0.753;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;136;-166.5541,417.7764;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;160;210.34,429.8178;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;67;-555.8902,-2255.218;Float;False;1332.457;370.2003;;7;28;55;30;38;29;37;18;Signed Distance Field;1,1,1,1;0;0
Node;AmplifyShaderEditor.SwizzleNode;141;447.2931,314.5961;Float;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;28;-179.0601,-2107.017;Float;False;213;160;;1;27;Distance Change;1,1,1,1;0;0
Node;AmplifyShaderEditor.SwizzleNode;142;402.2787,657.0702;Float;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;220;568.0209,475.8793;Float;False;Property;_Metallic;Metallic;21;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;173;638.1367,400.3581;Float;False;172;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;221;1630.316,542.0342;Float;False;Property;_Smoothness;Smoothness;20;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-356.3691,-2110.534;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;169;562.0438,660.059;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosterizeNode;24;1076.907,-2121.303;Float;False;1;2;1;COLOR;0,0,0,0;False;0;INT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FWidthOpNode;27;-129.0601,-2057.018;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-536.9901,-2012.969;Float;False;Property;_ClipValue;Clip Value;19;0;Create;True;0;0;False;0;0;0.09;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;30;74.94059,-1995.017;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;880.405,-2111.387;Float;False;Property;_Posterize;Posterize;18;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;38;-116.4402,-2205.218;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;55;533.5681,-2004.856;Float;False;sdfValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomStandardSurface;219;840.2739,319.3976;Float;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;29;303.9409,-2109.017;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1143.374,335.3339;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Custom/Farl/Amplify/VolumetricCloud;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;True;False;False;Back;0;False;-1;0;False;-1;False;0;0;True;0;Custom;0.5;True;True;0;True;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;SrcAlpha;OneMinusSrcAlpha;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;106;0;72;0
WireConnection;74;0;106;0
WireConnection;73;0;74;0
WireConnection;73;1;76;0
WireConnection;107;0;73;0
WireConnection;131;0;132;0
WireConnection;131;1;134;0
WireConnection;105;0;69;0
WireConnection;103;0;21;0
WireConnection;104;0;83;0
WireConnection;101;0;39;0
WireConnection;100;0;53;0
WireConnection;99;0;98;0
WireConnection;102;0;49;0
WireConnection;130;0;127;0
WireConnection;130;1;131;0
WireConnection;182;44;130;0
WireConnection;182;38;126;0
WireConnection;182;37;121;0
WireConnection;182;35;122;0
WireConnection;182;34;123;0
WireConnection;182;36;124;0
WireConnection;182;39;125;0
WireConnection;200;0;193;0
WireConnection;129;0;182;0
WireConnection;196;0;3;0
WireConnection;196;1;197;0
WireConnection;196;2;202;0
WireConnection;196;3;199;0
WireConnection;4;1;196;0
WireConnection;4;5;203;0
WireConnection;172;0;4;0
WireConnection;205;0;172;0
WireConnection;205;1;204;0
WireConnection;10;0;205;0
WireConnection;146;0;143;0
WireConnection;146;1;144;0
WireConnection;207;0;10;0
WireConnection;207;1;2;2
WireConnection;150;0;145;0
WireConnection;150;1;146;0
WireConnection;170;0;207;0
WireConnection;170;1;2;3
WireConnection;180;44;150;0
WireConnection;180;38;151;0
WireConnection;180;37;149;0
WireConnection;180;35;152;0
WireConnection;180;34;148;0
WireConnection;180;36;147;0
WireConnection;180;39;153;0
WireConnection;206;0;170;0
WireConnection;206;1;2;1
WireConnection;181;44;118;0
WireConnection;181;38;109;0
WireConnection;181;37;112;0
WireConnection;181;35;113;0
WireConnection;181;34;114;0
WireConnection;181;36;110;0
WireConnection;181;39;111;0
WireConnection;191;0;179;0
WireConnection;191;1;192;0
WireConnection;191;2;201;0
WireConnection;191;3;195;0
WireConnection;155;0;180;0
WireConnection;119;0;181;0
WireConnection;222;0;206;0
WireConnection;175;0;176;0
WireConnection;178;1;191;0
WireConnection;139;0;135;0
WireConnection;139;1;157;0
WireConnection;139;2;178;0
WireConnection;163;0;137;4
WireConnection;163;1;137;4
WireConnection;163;2;137;4
WireConnection;11;0;222;0
WireConnection;165;0;157;4
WireConnection;165;1;157;4
WireConnection;165;2;157;4
WireConnection;138;0;57;0
WireConnection;138;1;137;0
WireConnection;209;0;175;0
WireConnection;168;0;159;4
WireConnection;168;1;159;4
WireConnection;168;2;159;4
WireConnection;158;0;156;0
WireConnection;158;1;159;0
WireConnection;177;0;12;0
WireConnection;177;1;209;0
WireConnection;166;0;139;0
WireConnection;166;1;165;0
WireConnection;164;0;138;0
WireConnection;164;1;163;0
WireConnection;167;0;158;0
WireConnection;167;1;168;0
WireConnection;174;3;177;0
WireConnection;136;0;164;0
WireConnection;136;1;166;0
WireConnection;136;2;167;0
WireConnection;160;0;136;0
WireConnection;160;1;36;0
WireConnection;160;2;174;0
WireConnection;141;0;160;0
WireConnection;142;0;160;0
WireConnection;37;1;18;0
WireConnection;169;0;142;0
WireConnection;24;0;26;0
WireConnection;27;0;37;0
WireConnection;30;0;27;0
WireConnection;38;0;37;0
WireConnection;55;0;29;0
WireConnection;219;0;141;0
WireConnection;219;1;173;0
WireConnection;219;3;220;0
WireConnection;219;4;221;0
WireConnection;29;0;38;0
WireConnection;29;1;27;0
WireConnection;29;2;30;0
WireConnection;0;9;169;0
WireConnection;0;13;219;0
ASEEND*/
//CHKSM=F56B1FFA37BF4326203DF2F24569D5F2ED6C039F