// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Farl/Amplify/AmplifyAtmosphericScattering"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_NearDistance("Near Distance", Float) = 0
		_FarDistance("Far Distance", Float) = 10
		_NearColor("Near Color", Color) = (1,1,1,1)
		_FarColor("Far Color", Color) = (1,1,1,1)
		_Exp("Exp", Float) = 1
		_DepthOfFieldBlurRadius("Depth Of Field Blur Radius", Float) = 2
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
			#include "UnityCG.cginc"


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
				float4 ase_texcoord4 : TEXCOORD4;
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform float _DepthOfFieldBlurRadius;
			uniform sampler2D _CameraDepthTexture;
			uniform float _NearDistance;
			uniform float _FarDistance;
			uniform float _Exp;
			uniform float4 _NearColor;
			uniform float4 _FarColor;
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
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				
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
				float2 temp_output_4_0_g315 = uv_MainTex;
				float2 uv6_g324 = temp_output_4_0_g315;
				float temp_output_8_0_g330 = ( abs( 0 ) / 1 );
				float temp_output_90_0_g324 = exp( ( ( temp_output_8_0_g330 * temp_output_8_0_g330 ) * -0.5 ) );
				float temp_output_2_0_g315 = _DepthOfFieldBlurRadius;
				float2 temp_output_1_0_g315 = _ScreenParams.xy;
				float simplePerlin2D29_g315 = snoise( ( temp_output_4_0_g315 * temp_output_1_0_g315 * 10.0 ) );
				float temp_output_49_0_g315 = (0 + (simplePerlin2D29_g315 - -1) * (90 - 0) / (1 - -1));
				float2 _Vector0 = float2(1,0);
				float3 rotatedValue51_g315 = RotateAroundAxis( float3( 0,0,0 ), float3( _Vector0 ,  0.0 ), float3( 0,0,1 ), temp_output_49_0_g315 );
				float2 temp_output_28_0_g324 = ( temp_output_2_0_g315 * ( rotatedValue51_g315.xy / temp_output_1_0_g315 ) );
				float temp_output_8_0_g329 = ( abs( 0.333 ) / 1 );
				float temp_output_92_0_g324 = exp( ( ( temp_output_8_0_g329 * temp_output_8_0_g329 ) * -0.5 ) );
				float temp_output_8_0_g328 = ( abs( -0.333 ) / 1 );
				float temp_output_91_0_g324 = exp( ( ( temp_output_8_0_g328 * temp_output_8_0_g328 ) * -0.5 ) );
				float temp_output_8_0_g331 = ( abs( 0.666 ) / 1 );
				float temp_output_88_0_g324 = exp( ( ( temp_output_8_0_g331 * temp_output_8_0_g331 ) * -0.5 ) );
				float temp_output_8_0_g325 = ( abs( -0.666 ) / 1 );
				float temp_output_89_0_g324 = exp( ( ( temp_output_8_0_g325 * temp_output_8_0_g325 ) * -0.5 ) );
				float temp_output_8_0_g327 = ( abs( 1.0 ) / 1 );
				float temp_output_97_0_g324 = exp( ( ( temp_output_8_0_g327 * temp_output_8_0_g327 ) * -0.5 ) );
				float temp_output_8_0_g326 = ( abs( -1.0 ) / 1 );
				float temp_output_104_0_g324 = exp( ( ( temp_output_8_0_g326 * temp_output_8_0_g326 ) * -0.5 ) );
				float2 uv6_g316 = temp_output_4_0_g315;
				float temp_output_8_0_g322 = ( abs( 0 ) / 1 );
				float temp_output_90_0_g316 = exp( ( ( temp_output_8_0_g322 * temp_output_8_0_g322 ) * -0.5 ) );
				float3 rotatedValue54_g315 = RotateAroundAxis( float3( 0,0,0 ), float3( _Vector0 ,  0.0 ), float3( 0,0,1 ), temp_output_49_0_g315 );
				float2 temp_output_28_0_g316 = ( temp_output_2_0_g315 * ( rotatedValue54_g315.xy / temp_output_1_0_g315 ) );
				float temp_output_8_0_g321 = ( abs( 0.333 ) / 1 );
				float temp_output_92_0_g316 = exp( ( ( temp_output_8_0_g321 * temp_output_8_0_g321 ) * -0.5 ) );
				float temp_output_8_0_g320 = ( abs( -0.333 ) / 1 );
				float temp_output_91_0_g316 = exp( ( ( temp_output_8_0_g320 * temp_output_8_0_g320 ) * -0.5 ) );
				float temp_output_8_0_g323 = ( abs( 0.666 ) / 1 );
				float temp_output_88_0_g316 = exp( ( ( temp_output_8_0_g323 * temp_output_8_0_g323 ) * -0.5 ) );
				float temp_output_8_0_g317 = ( abs( -0.666 ) / 1 );
				float temp_output_89_0_g316 = exp( ( ( temp_output_8_0_g317 * temp_output_8_0_g317 ) * -0.5 ) );
				float temp_output_8_0_g319 = ( abs( 1.0 ) / 1 );
				float temp_output_97_0_g316 = exp( ( ( temp_output_8_0_g319 * temp_output_8_0_g319 ) * -0.5 ) );
				float temp_output_8_0_g318 = ( abs( -1.0 ) / 1 );
				float temp_output_104_0_g316 = exp( ( ( temp_output_8_0_g318 * temp_output_8_0_g318 ) * -0.5 ) );
				float4 screenPos = i.ase_texcoord4;
				float clampDepth10 = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(screenPos))));
				float clampResult18 = clamp( ( clampDepth10 * ( _ProjectionParams.z - _ProjectionParams.x ) ) , _NearDistance , _FarDistance );
				float depthFactor24 = saturate( pow( (0 + (clampResult18 - _NearDistance) * (1 - 0) / (_FarDistance - _NearDistance)) , _Exp ) );
				float4 lerpResult27 = lerp( tex2D( _MainTex, uv_MainTex ) , ( ( ( ( ( tex2D( _MainTex, uv6_g324 ) * temp_output_90_0_g324 ) + ( tex2D( _MainTex, ( uv6_g324 + ( temp_output_28_0_g324 * 0.333 ) ) ) * temp_output_92_0_g324 ) + ( tex2D( _MainTex, ( uv6_g324 + ( temp_output_28_0_g324 * -0.333 ) ) ) * temp_output_91_0_g324 ) + ( tex2D( _MainTex, ( uv6_g324 + ( temp_output_28_0_g324 * 0.666 ) ) ) * temp_output_88_0_g324 ) + ( tex2D( _MainTex, ( uv6_g324 + ( temp_output_28_0_g324 * -0.666 ) ) ) * temp_output_89_0_g324 ) + ( tex2D( _MainTex, ( uv6_g324 + ( temp_output_28_0_g324 * 1.0 ) ) ) * temp_output_97_0_g324 ) + ( tex2D( _MainTex, ( uv6_g324 + ( temp_output_28_0_g324 * -1.0 ) ) ) * temp_output_104_0_g324 ) ) / ( temp_output_90_0_g324 + temp_output_92_0_g324 + temp_output_91_0_g324 + temp_output_88_0_g324 + temp_output_89_0_g324 + temp_output_97_0_g324 + temp_output_104_0_g324 ) ) + ( ( ( tex2D( _MainTex, uv6_g316 ) * temp_output_90_0_g316 ) + ( tex2D( _MainTex, ( uv6_g316 + ( temp_output_28_0_g316 * 0.333 ) ) ) * temp_output_92_0_g316 ) + ( tex2D( _MainTex, ( uv6_g316 + ( temp_output_28_0_g316 * -0.333 ) ) ) * temp_output_91_0_g316 ) + ( tex2D( _MainTex, ( uv6_g316 + ( temp_output_28_0_g316 * 0.666 ) ) ) * temp_output_88_0_g316 ) + ( tex2D( _MainTex, ( uv6_g316 + ( temp_output_28_0_g316 * -0.666 ) ) ) * temp_output_89_0_g316 ) + ( tex2D( _MainTex, ( uv6_g316 + ( temp_output_28_0_g316 * 1.0 ) ) ) * temp_output_97_0_g316 ) + ( tex2D( _MainTex, ( uv6_g316 + ( temp_output_28_0_g316 * -1.0 ) ) ) * temp_output_104_0_g316 ) ) / ( temp_output_90_0_g316 + temp_output_92_0_g316 + temp_output_91_0_g316 + temp_output_88_0_g316 + temp_output_89_0_g316 + temp_output_97_0_g316 + temp_output_104_0_g316 ) ) ) * 0.5 ) , depthFactor24);
				float4 lerpResult3 = lerp( _NearColor , _FarColor , depthFactor24);
				float4 blendOpSrc5 = lerpResult27;
				float4 blendOpDest5 = lerpResult3;
				

				finalColor = 2.0f*blendOpDest5*blendOpSrc5 + blendOpDest5*blendOpDest5*(1.0f - 2.0f*blendOpSrc5);

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
432;311;1010;692;2029.36;951.9954;1.528416;True;False
Node;AmplifyShaderEditor.CommentaryNode;22;-1715.092,176.6097;Float;False;1546.056;456.0693;Comment;12;13;15;16;21;20;19;18;10;24;33;34;35;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ProjectionParams;33;-1565.829,329.8763;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenDepthNode;10;-1691.868,227.4403;Float;False;1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;35;-1357.46,432.0441;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1147.225,450.1098;Float;False;Property;_NearDistance;Near Distance;0;0;Create;True;0;0;False;0;0;3.34;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-1172.823,532.9765;Float;False;Property;_FarDistance;Far Distance;1;0;Create;True;0;0;False;0;10;5.96;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-1327.885,268.038;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;18;-984.3639,237.2906;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;21;-845.2252,234.5925;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-817.7128,402.7192;Float;False;Property;_Exp;Exp;4;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;31;-1599.915,-994.7535;Float;False;1058.573;556.2488;DOF;7;7;28;8;29;6;26;27;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PowerNode;15;-664.3172,240.3481;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomTextureCoordinatesNode;8;-1549.915,-848.9644;Float;False;0;-1;2;_MainTex;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;29;-1513.275,-553.5047;Float;False;Property;_DepthOfFieldBlurRadius;Depth Of Field Blur Radius;5;0;Create;True;0;0;False;0;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenParams;28;-1435.179,-722.0263;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;7;-1399.493,-944.7535;Float;False;0;0;_MainTex;Shader;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;13;-518.3706,242.2266;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;30;-1437.514,-392.6511;Float;False;1241.357;500.4714;Atmospheric Scattering;5;3;1;2;25;5;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-1337.502,-2.540973;Float;False;24;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-376.6413,237.2734;Float;False;depthFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-1195.765,-936.342;Float;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;26;-1094.37,-598.1302;Float;False;24;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;-1387.514,-342.6511;Float;False;Property;_NearColor;Near Color;2;0;Create;True;0;0;False;0;1,1,1,1;0.6193793,0.6140213,0.5738367,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;2;-1376.244,-174.6692;Float;False;Property;_FarColor;Far Color;3;0;Create;True;0;0;False;0;1,1,1,1;0.669959,0.7029999,0.7000846,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;57;-1128.986,-747.1583;Float;False;GaussianBlur;-1;;315;c6de34130b3467b4ca3bbe312526f8a6;0;4;1;FLOAT2;0,0;False;2;FLOAT;2;False;3;SAMPLER2D;0;False;4;FLOAT2;0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;27;-725.3416,-846.6741;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;3;-1103.802,-111.1593;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;5;-410.6499,-138.4934;Float;False;SoftLight;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;True;2;Float;ASEMaterialInspector;0;1;Custom/Farl/Amplify/AmplifyAtmosphericScattering;c71b220b631b6344493ea3cf87110c93;0;0;SubShader 0 Pass 0;1;False;False;True;Off;False;False;True;2;True;7;False;True;0;False;0;0;0;False;False;False;False;False;False;False;False;False;True;2;0;0;0;1;0;FLOAT4;0,0,0,0;False;0
WireConnection;35;0;33;3
WireConnection;35;1;33;1
WireConnection;34;0;10;0
WireConnection;34;1;35;0
WireConnection;18;0;34;0
WireConnection;18;1;19;0
WireConnection;18;2;20;0
WireConnection;21;0;18;0
WireConnection;21;1;19;0
WireConnection;21;2;20;0
WireConnection;15;0;21;0
WireConnection;15;1;16;0
WireConnection;13;0;15;0
WireConnection;24;0;13;0
WireConnection;6;0;7;0
WireConnection;6;1;8;0
WireConnection;57;1;28;0
WireConnection;57;2;29;0
WireConnection;57;3;7;0
WireConnection;57;4;8;0
WireConnection;27;0;6;0
WireConnection;27;1;57;0
WireConnection;27;2;26;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;3;2;25;0
WireConnection;5;0;27;0
WireConnection;5;1;3;0
WireConnection;4;0;5;0
ASEEND*/
//CHKSM=B6C8C50BBDE229A0419F2DCF6829228660CC85CF