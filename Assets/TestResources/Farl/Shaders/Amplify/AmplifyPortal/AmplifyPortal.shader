// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Farl/Amplify/AmplifyPortal"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_MainTex_ST("Main Texture ST", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
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
			
			uniform sampler2D Portal;
			uniform sampler2D PortalMask;

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
				float2 appendResult34 = (float2(( 1 / _MainTex_ST.x ) , 1));
				float4 lerpResult6 = lerp( tex2D( _MainTex, uv_MainTex ) , tex2D( Portal, (uv_MainTex*appendResult34 + 0) ) , tex2D( PortalMask, uv_MainTex ).r);
				

				finalColor = lerpResult6;

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
1927;324;1906;827;2395.679;-193.221;1.114919;True;False
Node;AmplifyShaderEditor.Vector4Node;32;-2119.178,723.9222;Float;False;Property;_MainTex_ST;Main Texture ST;4;0;Fetch;False;0;0;False;0;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;35;-1867.208,739.5309;Float;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomTextureCoordinatesNode;23;-2016.591,566.6918;Float;False;0;-1;2;_MainTex;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;34;-1718.923,750.6804;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;9;-1856.194,342.476;Float;True;Global;Portal;Portal;3;0;Create;True;0;0;False;0;None;None;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;2;-600.7819,-733.6167;Float;False;0;0;_MainTex;Shader;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;10;-975.427,781.2218;Float;True;Global;PortalMask;PortalMask;2;0;Create;True;0;0;False;0;None;None;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;30;-1616.314,568.8703;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;2,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CustomTextureCoordinatesNode;25;-701.9619,883.4492;Float;False;0;-1;2;_MainTex;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;8;-1354.303,402.0545;Float;True;Property;_Test;Test;1;0;Create;True;0;0;True;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-417.782,-737.6167;Float;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-338.4265,772.2218;Float;True;Global;_PortalMask;Temp2;1;0;Create;False;0;0;True;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;6;10.49931,397.8084;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomTextureCoordinatesNode;12;-716.6721,132.3945;Float;False;0;-1;2;_MainTex;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomTextureCoordinatesNode;4;-981.7902,-697.5607;Float;False;0;-1;2;_MainTex;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomTextureCoordinatesNode;26;-867.9084,-379.1524;Float;False;0;-1;2;_MainTex;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;11;-1016.427,17.2218;Float;True;Global;ScreenCopy;ScreenCopy;0;0;Create;True;0;0;False;0;None;None;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;7;-367.4265,16.2218;Float;True;Global;Temp3;Temp3;0;0;Create;True;0;0;True;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;27;-530.0249,-449.265;Float;True;Global;TextureSample1;Texture Sample 1;0;0;Create;True;0;0;True;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;28;-1157.606,-456.2649;Float;True;Global;_PortalCameraCopy;_PortalCameraCopy;1;0;Create;True;0;0;False;0;None;None;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;199.4183,398.5702;Float;False;True;2;Float;ASEMaterialInspector;0;1;Custom/Farl/Amplify/AmplifyPortal;c71b220b631b6344493ea3cf87110c93;0;0;SubShader 0 Pass 0;1;False;False;True;Off;False;False;True;2;True;7;False;True;0;False;0;0;0;False;False;False;False;False;False;False;False;False;True;2;0;0;0;1;0;FLOAT4;0,0,0,0;False;0
WireConnection;35;1;32;1
WireConnection;34;0;35;0
WireConnection;30;0;23;0
WireConnection;30;1;34;0
WireConnection;8;0;9;0
WireConnection;8;1;30;0
WireConnection;3;0;2;0
WireConnection;5;0;10;0
WireConnection;5;1;25;0
WireConnection;6;0;3;0
WireConnection;6;1;8;0
WireConnection;6;2;5;1
WireConnection;7;0;11;0
WireConnection;7;1;12;0
WireConnection;27;0;28;0
WireConnection;27;1;26;0
WireConnection;1;0;6;0
ASEEND*/
//CHKSM=8B671BB49B50AE6C583274A98B4D2E2D0FED71CF