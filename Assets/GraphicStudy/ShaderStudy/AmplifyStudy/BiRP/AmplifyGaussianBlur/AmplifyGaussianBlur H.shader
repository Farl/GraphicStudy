// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Farl/Amplify/AmplifyGaussianBlur H"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_Radius("Radius", Float) = 1
		_BlurOffsets("BlurOffsets", Vector) = (0,1,0,0)
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
			
			uniform float _Radius;
			uniform half4 _BlurOffsets;

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
				float2 uv6_g1 = uv_MainTex;
				float temp_output_8_0_g56 = ( abs( 0 ) / 1 );
				float temp_output_90_0_g1 = exp( ( ( temp_output_8_0_g56 * temp_output_8_0_g56 ) * -0.5 ) );
				float2 temp_output_28_0_g1 = ( _Radius * ( _BlurOffsets.xy / _ScreenParams.xy ) );
				float temp_output_8_0_g55 = ( abs( 0.333 ) / 1 );
				float temp_output_92_0_g1 = exp( ( ( temp_output_8_0_g55 * temp_output_8_0_g55 ) * -0.5 ) );
				float temp_output_8_0_g54 = ( abs( -0.333 ) / 1 );
				float temp_output_91_0_g1 = exp( ( ( temp_output_8_0_g54 * temp_output_8_0_g54 ) * -0.5 ) );
				float temp_output_8_0_g57 = ( abs( 0.666 ) / 1 );
				float temp_output_88_0_g1 = exp( ( ( temp_output_8_0_g57 * temp_output_8_0_g57 ) * -0.5 ) );
				float temp_output_8_0_g46 = ( abs( -0.666 ) / 1 );
				float temp_output_89_0_g1 = exp( ( ( temp_output_8_0_g46 * temp_output_8_0_g46 ) * -0.5 ) );
				float temp_output_8_0_g53 = ( abs( 1.0 ) / 1 );
				float temp_output_97_0_g1 = exp( ( ( temp_output_8_0_g53 * temp_output_8_0_g53 ) * -0.5 ) );
				float temp_output_8_0_g52 = ( abs( -1.0 ) / 1 );
				float temp_output_104_0_g1 = exp( ( ( temp_output_8_0_g52 * temp_output_8_0_g52 ) * -0.5 ) );
				

				finalColor = ( ( ( tex2D( _MainTex, uv6_g1 ) * temp_output_90_0_g1 ) + ( tex2D( _MainTex, ( uv6_g1 + ( temp_output_28_0_g1 * 0.333 ) ) ) * temp_output_92_0_g1 ) + ( tex2D( _MainTex, ( uv6_g1 + ( temp_output_28_0_g1 * -0.333 ) ) ) * temp_output_91_0_g1 ) + ( tex2D( _MainTex, ( uv6_g1 + ( temp_output_28_0_g1 * 0.666 ) ) ) * temp_output_88_0_g1 ) + ( tex2D( _MainTex, ( uv6_g1 + ( temp_output_28_0_g1 * -0.666 ) ) ) * temp_output_89_0_g1 ) + ( tex2D( _MainTex, ( uv6_g1 + ( temp_output_28_0_g1 * 1.0 ) ) ) * temp_output_97_0_g1 ) + ( tex2D( _MainTex, ( uv6_g1 + ( temp_output_28_0_g1 * -1.0 ) ) ) * temp_output_104_0_g1 ) ) / ( temp_output_90_0_g1 + temp_output_92_0_g1 + temp_output_91_0_g1 + temp_output_88_0_g1 + temp_output_89_0_g1 + temp_output_97_0_g1 + temp_output_104_0_g1 ) );

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
0;45;831;855;910.2675;748.4142;1.363429;True;False
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;3;-812.9439,-64.3427;Float;False;0;0;_MainTex;Shader;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;8;-705.7526,-243.9456;Half;False;Property;_BlurOffsets;BlurOffsets;1;0;Create;True;0;0;False;0;0,1,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomTextureCoordinatesNode;4;-685.2154,117.8274;Float;False;0;-1;2;;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;6;-565.8627,21.50754;Float;False;Property;_Radius;Radius;0;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenParams;7;-555.3494,-378.9013;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;2;-307,-70.5;Float;False;Gaussian Blur 2D;-1;;1;a124a256111673e4a8c38a493d3e6f8a;0;5;86;FLOAT2;256,256;False;29;FLOAT2;1,0;False;27;FLOAT;0;False;1;SAMPLER2D;;False;5;FLOAT2;0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;0,0;Float;False;True;2;Float;ASEMaterialInspector;0;1;Custom/Farl/Amplify/AmplifyGaussianBlur H;c71b220b631b6344493ea3cf87110c93;0;0;SubShader 0 Pass 0;1;False;False;True;Off;False;False;True;2;True;7;False;True;0;False;0;0;0;False;False;False;False;False;False;False;False;False;True;2;0;0;0;1;0;FLOAT4;0,0,0,0;False;0
WireConnection;4;2;3;0
WireConnection;2;86;7;0
WireConnection;2;29;8;0
WireConnection;2;27;6;0
WireConnection;2;1;3;0
WireConnection;2;5;4;0
WireConnection;1;0;2;0
ASEEND*/
//CHKSM=A78044FABF99DC01C008A38DB808E79CF7139E8D