// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Farl/Amplify/AmplifyBlurCommandBuffer"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		[Toggle(_SINGLE_PASS_VR_ON)] _SINGLE_PASS_VR("SINGLE_PASS_VR", Float) = 0
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
			#pragma shader_feature _SINGLE_PASS_VR_ON


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
			
			uniform sampler2D _GrabBlurTexture;
			uniform sampler2D _MaskTex;
			uniform float4 _MaskTex_ST;
			uniform float4 _GrabBlurTexture_ST;

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
				float2 uv_MaskTex = i.uv.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float4 appendResult15 = (float4(( uv_MaskTex.x / 32 ) , uv_MaskTex.y , 0 , 0));
				#ifdef _SINGLE_PASS_VR_ON
				float4 staticSwitch29 = appendResult15;
				#else
				float4 staticSwitch29 = float4( uv_MaskTex, 0.0 , 0.0 );
				#endif
				float2 uv_GrabBlurTexture = i.uv.xy * _GrabBlurTexture_ST.xy + _GrabBlurTexture_ST.zw;
				float4 appendResult18 = (float4(( uv_GrabBlurTexture.x / 8 ) , uv_GrabBlurTexture.y , 0 , 0));
				#ifdef _SINGLE_PASS_VR_ON
				float4 staticSwitch30 = appendResult18;
				#else
				float4 staticSwitch30 = float4( uv_GrabBlurTexture, 0.0 , 0.0 );
				#endif
				float4 lerpResult10 = lerp( tex2D( _MainTex, uv_MainTex ) , tex2D( _GrabBlurTexture, staticSwitch29.xy ) , tex2D( _MaskTex, staticSwitch30.xy ).r);
				

				finalColor = lerpResult10;

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
2213;354;1620;797;1081.724;632.5823;1.3;True;True
Node;AmplifyShaderEditor.CustomTextureCoordinatesNode;24;-1240.706,-25.08808;Float;False;0;9;2;_GrabBlurTexture;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomTextureCoordinatesNode;23;-1219.938,-277.5269;Float;False;0;13;2;_MaskTex;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;26;-915.6083,-18.42797;Float;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;25;-883.2067,-275.9109;Float;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleDivideOpNode;16;-632.0446,-328.0428;Float;False;2;0;FLOAT;0;False;1;FLOAT;32;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;17;-639.0292,-73.89848;Float;False;2;0;FLOAT;0;False;1;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;3;-565.4276,-590.2393;Float;False;0;0;_MainTex;Shader;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;15;-489.4953,-277.1606;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;18;-483.7711,-20.48608;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;29;-323.8235,-276.3826;Float;False;Property;_SINGLE_PASS_VR;SINGLE_PASS_VR;3;0;Create;False;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;30;-304.3238,-28.08234;Float;False;Property;_SINGLE_PASS_VR;SINGLE_PASS_VR;2;0;Fetch;True;0;0;False;0;0;0;0;True;_SINGLE_PASS_VR_ON;Toggle;2;Key0;Key1;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;28;-97.03295,-546.3401;Float;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.CustomTextureCoordinatesNode;4;-405.5016,-498.3122;Float;False;0;-1;2;_MainTex;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;9;-22.27917,-308.4315;Float;True;Global;_GrabBlurTexture;_GrabBlurTexture;0;1;[HideInInspector];Create;False;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;13;-23.14879,-55.44885;Float;True;Global;_MaskTex;_MaskTex;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;11;-23.97658,-520.6479;Float;True;Property;_TextureSample7;Texture Sample 7;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;10;357.7688,-328.6122;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;586.8112,-328.6414;Float;False;True;2;Float;ASEMaterialInspector;0;1;Custom/Farl/Amplify/AmplifyBlurCommandBuffer;c71b220b631b6344493ea3cf87110c93;0;0;SubShader 0 Pass 0;1;False;False;True;Off;False;False;True;2;True;7;False;True;0;False;0;0;0;False;False;False;False;False;False;False;False;False;True;2;0;0;0;1;0;FLOAT4;0,0,0,0;False;0
WireConnection;26;0;24;0
WireConnection;25;0;23;0
WireConnection;16;0;25;0
WireConnection;17;0;26;0
WireConnection;15;0;16;0
WireConnection;15;1;25;1
WireConnection;18;0;17;0
WireConnection;18;1;26;1
WireConnection;29;1;23;0
WireConnection;29;0;15;0
WireConnection;30;1;24;0
WireConnection;30;0;18;0
WireConnection;28;0;3;0
WireConnection;4;2;3;0
WireConnection;9;1;29;0
WireConnection;13;1;30;0
WireConnection;11;0;28;0
WireConnection;11;1;4;0
WireConnection;10;0;11;0
WireConnection;10;1;9;0
WireConnection;10;2;13;1
WireConnection;1;0;10;0
ASEEND*/
//CHKSM=B976FED38FC1838D83190018E8D67397180EAE02