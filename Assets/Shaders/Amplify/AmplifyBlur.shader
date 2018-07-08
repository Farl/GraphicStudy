// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Farl/Amplify/AmplifyBlur"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_BlurRadius("Blur Radius", Float) = 2
	}

	SubShader
	{
		
		
		ZTest Always
		Cull Off
		ZWrite Off
		

		Pass
		{ 
			CGPROGRAM 

			#pragma vertex vert_img_custom 
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata_img_custom
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				
			};

			struct v2f_img_custom
			{
				float4 pos : SV_POSITION;
				half2 uv   : TEXCOORD0;
				half2 stereoUV : TEXCOORD2;
		#if UNITY_UV_STARTS_AT_TOP
				half4 uv2 : TEXCOORD1;
				half4 stereoUV2 : TEXCOORD3;
		#endif
				
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform float _BlurRadius;
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
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
			

			v2f_img_custom vert_img_custom ( appdata_img_custom v  )
			{
				v2f_img_custom o;
				
				o.pos = UnityObjectToClipPos ( v.vertex );
				o.uv = float4( v.texcoord.xy, 1, 1 );

				#if UNITY_UV_STARTS_AT_TOP
					o.uv2 = float4( v.texcoord.xy, 1, 1 );
					o.stereoUV2 = UnityStereoScreenSpaceUVAdjust ( o.uv2, _MainTex_ST );

					if ( _MainTex_TexelSize.y < 0.0 )
						o.uv.y = 1.0 - o.uv.y;
				#endif
				o.stereoUV = UnityStereoScreenSpaceUVAdjust ( o.uv, _MainTex_ST );
				return o;
			}

			half4 frag ( v2f_img_custom i ) : SV_Target
			{
				#ifdef UNITY_UV_STARTS_AT_TOP
					half2 uv = i.uv2;
					half2 stereoUV = i.stereoUV2;
				#else
					half2 uv = i.uv;
					half2 stereoUV = i.stereoUV;
				#endif	
				
				half4 finalColor;

				// ase common template code
				float2 uv_MainTex = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 temp_output_4_0_g282 = uv_MainTex;
				float2 uv6_g291 = temp_output_4_0_g282;
				float temp_output_8_0_g297 = ( abs( 0 ) / 1 );
				float temp_output_90_0_g291 = exp( ( ( temp_output_8_0_g297 * temp_output_8_0_g297 ) * -0.5 ) );
				float temp_output_2_0_g282 = _BlurRadius;
				float2 temp_output_1_0_g282 = _ScreenParams.xy;
				float simplePerlin2D29_g282 = snoise( ( temp_output_4_0_g282 * temp_output_1_0_g282 * 10.0 ) );
				float temp_output_49_0_g282 = (0 + (simplePerlin2D29_g282 - -1) * (90 - 0) / (1 - -1));
				float2 _Vector0 = float2(1,0);
				float3 rotatedValue51_g282 = RotateAroundAxis( float3( 0,0,0 ), float3( _Vector0 ,  0.0 ), float3( 0,0,1 ), temp_output_49_0_g282 );
				float2 temp_output_28_0_g291 = ( temp_output_2_0_g282 * ( rotatedValue51_g282.xy / temp_output_1_0_g282 ) );
				float temp_output_8_0_g296 = ( abs( 0.333 ) / 1 );
				float temp_output_92_0_g291 = exp( ( ( temp_output_8_0_g296 * temp_output_8_0_g296 ) * -0.5 ) );
				float temp_output_8_0_g295 = ( abs( -0.333 ) / 1 );
				float temp_output_91_0_g291 = exp( ( ( temp_output_8_0_g295 * temp_output_8_0_g295 ) * -0.5 ) );
				float temp_output_8_0_g298 = ( abs( 0.666 ) / 1 );
				float temp_output_88_0_g291 = exp( ( ( temp_output_8_0_g298 * temp_output_8_0_g298 ) * -0.5 ) );
				float temp_output_8_0_g292 = ( abs( -0.666 ) / 1 );
				float temp_output_89_0_g291 = exp( ( ( temp_output_8_0_g292 * temp_output_8_0_g292 ) * -0.5 ) );
				float temp_output_8_0_g294 = ( abs( 1.0 ) / 1 );
				float temp_output_97_0_g291 = exp( ( ( temp_output_8_0_g294 * temp_output_8_0_g294 ) * -0.5 ) );
				float temp_output_8_0_g293 = ( abs( -1.0 ) / 1 );
				float temp_output_104_0_g291 = exp( ( ( temp_output_8_0_g293 * temp_output_8_0_g293 ) * -0.5 ) );
				float2 uv6_g283 = temp_output_4_0_g282;
				float temp_output_8_0_g289 = ( abs( 0 ) / 1 );
				float temp_output_90_0_g283 = exp( ( ( temp_output_8_0_g289 * temp_output_8_0_g289 ) * -0.5 ) );
				float3 rotatedValue54_g282 = RotateAroundAxis( float3( 0,0,0 ), float3( _Vector0 ,  0.0 ), float3( 0,0,1 ), temp_output_49_0_g282 );
				float2 temp_output_28_0_g283 = ( temp_output_2_0_g282 * ( rotatedValue54_g282.xy / temp_output_1_0_g282 ) );
				float temp_output_8_0_g288 = ( abs( 0.333 ) / 1 );
				float temp_output_92_0_g283 = exp( ( ( temp_output_8_0_g288 * temp_output_8_0_g288 ) * -0.5 ) );
				float temp_output_8_0_g287 = ( abs( -0.333 ) / 1 );
				float temp_output_91_0_g283 = exp( ( ( temp_output_8_0_g287 * temp_output_8_0_g287 ) * -0.5 ) );
				float temp_output_8_0_g290 = ( abs( 0.666 ) / 1 );
				float temp_output_88_0_g283 = exp( ( ( temp_output_8_0_g290 * temp_output_8_0_g290 ) * -0.5 ) );
				float temp_output_8_0_g284 = ( abs( -0.666 ) / 1 );
				float temp_output_89_0_g283 = exp( ( ( temp_output_8_0_g284 * temp_output_8_0_g284 ) * -0.5 ) );
				float temp_output_8_0_g286 = ( abs( 1.0 ) / 1 );
				float temp_output_97_0_g283 = exp( ( ( temp_output_8_0_g286 * temp_output_8_0_g286 ) * -0.5 ) );
				float temp_output_8_0_g285 = ( abs( -1.0 ) / 1 );
				float temp_output_104_0_g283 = exp( ( ( temp_output_8_0_g285 * temp_output_8_0_g285 ) * -0.5 ) );
				

				finalColor = ( ( ( ( ( tex2D( _MainTex, uv6_g291 ) * temp_output_90_0_g291 ) + ( tex2D( _MainTex, ( uv6_g291 + ( temp_output_28_0_g291 * 0.333 ) ) ) * temp_output_92_0_g291 ) + ( tex2D( _MainTex, ( uv6_g291 + ( temp_output_28_0_g291 * -0.333 ) ) ) * temp_output_91_0_g291 ) + ( tex2D( _MainTex, ( uv6_g291 + ( temp_output_28_0_g291 * 0.666 ) ) ) * temp_output_88_0_g291 ) + ( tex2D( _MainTex, ( uv6_g291 + ( temp_output_28_0_g291 * -0.666 ) ) ) * temp_output_89_0_g291 ) + ( tex2D( _MainTex, ( uv6_g291 + ( temp_output_28_0_g291 * 1.0 ) ) ) * temp_output_97_0_g291 ) + ( tex2D( _MainTex, ( uv6_g291 + ( temp_output_28_0_g291 * -1.0 ) ) ) * temp_output_104_0_g291 ) ) / ( temp_output_90_0_g291 + temp_output_92_0_g291 + temp_output_91_0_g291 + temp_output_88_0_g291 + temp_output_89_0_g291 + temp_output_97_0_g291 + temp_output_104_0_g291 ) ) + ( ( ( tex2D( _MainTex, uv6_g283 ) * temp_output_90_0_g283 ) + ( tex2D( _MainTex, ( uv6_g283 + ( temp_output_28_0_g283 * 0.333 ) ) ) * temp_output_92_0_g283 ) + ( tex2D( _MainTex, ( uv6_g283 + ( temp_output_28_0_g283 * -0.333 ) ) ) * temp_output_91_0_g283 ) + ( tex2D( _MainTex, ( uv6_g283 + ( temp_output_28_0_g283 * 0.666 ) ) ) * temp_output_88_0_g283 ) + ( tex2D( _MainTex, ( uv6_g283 + ( temp_output_28_0_g283 * -0.666 ) ) ) * temp_output_89_0_g283 ) + ( tex2D( _MainTex, ( uv6_g283 + ( temp_output_28_0_g283 * 1.0 ) ) ) * temp_output_97_0_g283 ) + ( tex2D( _MainTex, ( uv6_g283 + ( temp_output_28_0_g283 * -1.0 ) ) ) * temp_output_104_0_g283 ) ) / ( temp_output_90_0_g283 + temp_output_92_0_g283 + temp_output_91_0_g283 + temp_output_88_0_g283 + temp_output_89_0_g283 + temp_output_97_0_g283 + temp_output_104_0_g283 ) ) ) * 0.5 );

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
432;311;1010;692;553.0769;487.9616;1.335159;True;False
Node;AmplifyShaderEditor.RangedFloatNode;29;22.5371,-124.3547;Float;False;Property;_BlurRadius;Blur Radius;0;0;Create;True;0;0;False;0;2;17.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenParams;26;195.2529,-251.0805;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomTextureCoordinatesNode;6;52.70612,14.23163;Float;False;0;-1;2;_MainTex;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;2;204.131,-65.37553;Float;False;0;0;_MainTex;Shader;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;83;399.942,-147.5987;Float;False;GaussianBlur;-1;;282;c6de34130b3467b4ca3bbe312526f8a6;0;4;1;FLOAT2;0,0;False;2;FLOAT;2;False;3;SAMPLER2D;0;False;4;FLOAT2;0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;654.3329,-153.7018;Float;False;True;2;Float;ASEMaterialInspector;0;1;Custom/Farl/Amplify/AmplifyBlur;c71b220b631b6344493ea3cf87110c93;0;0;SubShader 0 Pass 0;1;False;False;True;Off;False;False;True;2;True;7;False;True;0;False;0;0;0;False;False;False;False;False;False;False;False;False;True;2;0;0;0;1;0;FLOAT4;0,0,0,0;False;0
WireConnection;83;1;26;0
WireConnection;83;2;29;0
WireConnection;83;3;2;0
WireConnection;83;4;6;0
WireConnection;1;0;83;0
ASEEND*/
//CHKSM=2E4477FEC233DDF6B20EC1E7B31FD92B090634EB