// Made with Amplify Shader Editor v1.9.3.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
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
		_DepthOfFieldBlurRadius("Depth Of Field Blur Radius", Float) = 100
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		
		
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
				float4 ase_texcoord4 : TEXCOORD4;
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform float4 _NearColor;
			uniform float4 _FarColor;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _NearDistance;
			uniform float _FarDistance;
			uniform float _Exp;
			uniform float _DepthOfFieldBlurRadius;
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
				
				o.pos = UnityObjectToClipPos( v.vertex );
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
				float4 screenPos = i.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float clampDepth10 = Linear01Depth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
				float clampResult18 = clamp( ( clampDepth10 * ( _ProjectionParams.z - _ProjectionParams.x ) ) , _NearDistance , _FarDistance );
				float depthFactor24 = saturate( pow( (0.0 + (clampResult18 - _NearDistance) * (1.0 - 0.0) / (_FarDistance - _NearDistance)) , _Exp ) );
				float4 lerpResult3 = lerp( _NearColor , _FarColor , depthFactor24);
				float2 uv_MainTex = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 temp_output_4_0_g238 = ase_screenPosNorm.xy;
				float2 uv6_g259 = temp_output_4_0_g238;
				float temp_output_8_0_g265 = ( abs( 0.0 ) / 1.0 );
				float temp_output_90_0_g259 = exp( ( ( temp_output_8_0_g265 * temp_output_8_0_g265 ) * -0.5 ) );
				float temp_output_2_0_g238 = _DepthOfFieldBlurRadius;
				float2 temp_output_1_0_g238 = _ScreenParams.xy;
				float simplePerlin2D29_g238 = snoise( ( temp_output_4_0_g238 * temp_output_1_0_g238 * 10.0 ) );
				float temp_output_49_0_g238 = (0.0 + (simplePerlin2D29_g238 - -1.0) * (90.0 - 0.0) / (1.0 - -1.0));
				float2 _Vector0 = float2(1,0);
				float3 rotatedValue51_g238 = RotateAroundAxis( float3( 0,0,0 ), float3( _Vector0 ,  0.0 ), float3( 0,0,1 ), temp_output_49_0_g238 );
				float2 temp_output_28_0_g259 = ( temp_output_2_0_g238 * ( rotatedValue51_g238.xy / temp_output_1_0_g238 ) );
				float temp_output_8_0_g264 = ( abs( 0.333 ) / 1.0 );
				float temp_output_92_0_g259 = exp( ( ( temp_output_8_0_g264 * temp_output_8_0_g264 ) * -0.5 ) );
				float temp_output_8_0_g263 = ( abs( -0.333 ) / 1.0 );
				float temp_output_91_0_g259 = exp( ( ( temp_output_8_0_g263 * temp_output_8_0_g263 ) * -0.5 ) );
				float temp_output_8_0_g266 = ( abs( 0.666 ) / 1.0 );
				float temp_output_88_0_g259 = exp( ( ( temp_output_8_0_g266 * temp_output_8_0_g266 ) * -0.5 ) );
				float temp_output_8_0_g260 = ( abs( -0.666 ) / 1.0 );
				float temp_output_89_0_g259 = exp( ( ( temp_output_8_0_g260 * temp_output_8_0_g260 ) * -0.5 ) );
				float temp_output_8_0_g262 = ( abs( 1.0 ) / 1.0 );
				float temp_output_97_0_g259 = exp( ( ( temp_output_8_0_g262 * temp_output_8_0_g262 ) * -0.5 ) );
				float temp_output_8_0_g261 = ( abs( -1.0 ) / 1.0 );
				float temp_output_104_0_g259 = exp( ( ( temp_output_8_0_g261 * temp_output_8_0_g261 ) * -0.5 ) );
				float2 uv6_g251 = temp_output_4_0_g238;
				float temp_output_8_0_g257 = ( abs( 0.0 ) / 1.0 );
				float temp_output_90_0_g251 = exp( ( ( temp_output_8_0_g257 * temp_output_8_0_g257 ) * -0.5 ) );
				float3 rotatedValue54_g238 = RotateAroundAxis( float3( 0,0,0 ), float3( _Vector0 ,  0.0 ), float3( 0,0,1 ), temp_output_49_0_g238 );
				float2 temp_output_28_0_g251 = ( temp_output_2_0_g238 * ( rotatedValue54_g238.xy / temp_output_1_0_g238 ) );
				float temp_output_8_0_g256 = ( abs( 0.333 ) / 1.0 );
				float temp_output_92_0_g251 = exp( ( ( temp_output_8_0_g256 * temp_output_8_0_g256 ) * -0.5 ) );
				float temp_output_8_0_g255 = ( abs( -0.333 ) / 1.0 );
				float temp_output_91_0_g251 = exp( ( ( temp_output_8_0_g255 * temp_output_8_0_g255 ) * -0.5 ) );
				float temp_output_8_0_g258 = ( abs( 0.666 ) / 1.0 );
				float temp_output_88_0_g251 = exp( ( ( temp_output_8_0_g258 * temp_output_8_0_g258 ) * -0.5 ) );
				float temp_output_8_0_g252 = ( abs( -0.666 ) / 1.0 );
				float temp_output_89_0_g251 = exp( ( ( temp_output_8_0_g252 * temp_output_8_0_g252 ) * -0.5 ) );
				float temp_output_8_0_g254 = ( abs( 1.0 ) / 1.0 );
				float temp_output_97_0_g251 = exp( ( ( temp_output_8_0_g254 * temp_output_8_0_g254 ) * -0.5 ) );
				float temp_output_8_0_g253 = ( abs( -1.0 ) / 1.0 );
				float temp_output_104_0_g251 = exp( ( ( temp_output_8_0_g253 * temp_output_8_0_g253 ) * -0.5 ) );
				float4 lerpResult27 = lerp( tex2D( _MainTex, uv_MainTex ) , ( ( ( ( ( tex2D( _MainTex, uv6_g259 ) * temp_output_90_0_g259 ) + ( tex2D( _MainTex, ( uv6_g259 + ( temp_output_28_0_g259 * 0.333 ) ) ) * temp_output_92_0_g259 ) + ( tex2D( _MainTex, ( uv6_g259 + ( temp_output_28_0_g259 * -0.333 ) ) ) * temp_output_91_0_g259 ) + ( tex2D( _MainTex, ( uv6_g259 + ( temp_output_28_0_g259 * 0.666 ) ) ) * temp_output_88_0_g259 ) + ( tex2D( _MainTex, ( uv6_g259 + ( temp_output_28_0_g259 * -0.666 ) ) ) * temp_output_89_0_g259 ) + ( tex2D( _MainTex, ( uv6_g259 + ( temp_output_28_0_g259 * 1.0 ) ) ) * temp_output_97_0_g259 ) + ( tex2D( _MainTex, ( uv6_g259 + ( temp_output_28_0_g259 * -1.0 ) ) ) * temp_output_104_0_g259 ) ) / ( temp_output_90_0_g259 + temp_output_92_0_g259 + temp_output_91_0_g259 + temp_output_88_0_g259 + temp_output_89_0_g259 + temp_output_97_0_g259 + temp_output_104_0_g259 ) ) + ( ( ( tex2D( _MainTex, uv6_g251 ) * temp_output_90_0_g251 ) + ( tex2D( _MainTex, ( uv6_g251 + ( temp_output_28_0_g251 * 0.333 ) ) ) * temp_output_92_0_g251 ) + ( tex2D( _MainTex, ( uv6_g251 + ( temp_output_28_0_g251 * -0.333 ) ) ) * temp_output_91_0_g251 ) + ( tex2D( _MainTex, ( uv6_g251 + ( temp_output_28_0_g251 * 0.666 ) ) ) * temp_output_88_0_g251 ) + ( tex2D( _MainTex, ( uv6_g251 + ( temp_output_28_0_g251 * -0.666 ) ) ) * temp_output_89_0_g251 ) + ( tex2D( _MainTex, ( uv6_g251 + ( temp_output_28_0_g251 * 1.0 ) ) ) * temp_output_97_0_g251 ) + ( tex2D( _MainTex, ( uv6_g251 + ( temp_output_28_0_g251 * -1.0 ) ) ) * temp_output_104_0_g251 ) ) / ( temp_output_90_0_g251 + temp_output_92_0_g251 + temp_output_91_0_g251 + temp_output_88_0_g251 + temp_output_89_0_g251 + temp_output_97_0_g251 + temp_output_104_0_g251 ) ) ) * 0.5 ) , depthFactor24);
				float4 blendOpSrc5 = lerpResult3;
				float4 blendOpDest5 = lerpResult27;
				float4 lerpBlendMode5 = lerp(blendOpDest5,( 1.0 - ( 1.0 - blendOpSrc5 ) * ( 1.0 - blendOpDest5 ) ),(lerpResult3).a);
				

				finalColor = lerpBlendMode5;

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19303
Node;AmplifyShaderEditor.CommentaryNode;22;-1715.092,176.6097;Inherit;False;1546.056;456.0693;Comment;12;13;15;16;21;20;19;18;10;24;33;34;35;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ProjectionParams;33;-1565.829,329.8763;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;35;-1357.46,432.0441;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;10;-1691.868,227.4403;Inherit;False;1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1147.225,450.1098;Float;False;Property;_NearDistance;Near Distance;0;0;Create;True;0;0;0;False;0;False;0;3.34;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-1172.823,532.9765;Float;False;Property;_FarDistance;Far Distance;1;0;Create;True;0;0;0;False;0;False;10;5.96;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-1327.885,268.038;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;18;-984.3639,237.2906;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;21;-845.2252,234.5925;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-817.7128,402.7192;Float;False;Property;_Exp;Exp;4;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;15;-664.3172,240.3481;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;13;-518.3706,242.2266;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;30;-1696,-1008;Inherit;False;611.1816;468.9626;Atmospheric Scattering Color;6;71;69;3;25;1;2;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-376.6413,237.2734;Float;False;depthFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;31;-1712,-464;Inherit;False;1058.573;556.2488;DOF;9;7;28;29;6;26;27;66;65;68;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;2;-1632,-800;Float;False;Property;_FarColor;Far Color;3;0;Create;True;0;0;0;False;0;False;1,1,1,1;0.669959,0.7029999,0.7000846,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;1;-1632,-960;Float;False;Property;_NearColor;Near Color;2;0;Create;True;0;0;0;False;0;False;1,1,1,1;0.6193793,0.6140213,0.5738367,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;25;-1600,-640;Inherit;False;24;depthFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1648,-160;Float;False;Property;_DepthOfFieldBlurRadius;Depth Of Field Blur Radius;5;0;Create;True;0;0;0;False;0;False;100;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;66;-1616,-80;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenParams;28;-1616,-336;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;7;-1584,-416;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;3;-1376,-832;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-1200,-64;Inherit;False;24;depthFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-1296,-400;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;65;-1264,-208;Inherit;False;GaussianBlur;-1;;238;c6de34130b3467b4ca3bbe312526f8a6;0;4;3;SAMPLER2D;0;False;1;FLOAT2;0,0;False;2;FLOAT;2;False;4;FLOAT2;0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;69;-1152,-752;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;27;-880,-320;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;71;-1152,-864;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;70;-592,-688;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;68;-708.4198,-283.0051;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;67;-512,-432;Inherit;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;72;-560,-832;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;5;-320,-720;Inherit;False;Screen;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.5;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;-80,-720;Float;False;True;-1;2;ASEMaterialInspector;0;9;Custom/Farl/Amplify/AmplifyAtmosphericScattering;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;True;7;False;;False;True;0;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
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
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;3;2;25;0
WireConnection;6;0;7;0
WireConnection;65;3;7;0
WireConnection;65;1;28;0
WireConnection;65;2;29;0
WireConnection;65;4;66;0
WireConnection;69;0;3;0
WireConnection;27;0;6;0
WireConnection;27;1;65;0
WireConnection;27;2;26;0
WireConnection;71;0;3;0
WireConnection;70;0;69;0
WireConnection;68;0;27;0
WireConnection;67;0;70;0
WireConnection;72;0;71;0
WireConnection;5;0;72;0
WireConnection;5;1;68;0
WireConnection;5;2;67;0
WireConnection;4;0;5;0
ASEEND*/
//CHKSM=900349F685D646CB6F061F0C0261E46D2632AFEE