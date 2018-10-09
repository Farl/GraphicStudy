// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifyFlowMapTexture"
{
	Properties
	{
		_Power("Power", Float) = 1
		_MainTex("Main Tex", 2D) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha noshadow exclude_path:deferred 
		struct Input
		{
			float2 uv2_texcoord2;
			float4 vertexColor : COLOR;
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

		uniform sampler2D _MainTex;
		uniform float _Power;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float temp_output_37_0 = saturate( distance( i.uv2_texcoord2 , float2( 0.5,0.5 ) ) );
			float clampResult11 = clamp( pow( temp_output_37_0 , _Power ) , 0 , 0.5 );
			float temp_output_8_0 = ( 1.0 - (0 + (clampResult11 - 0) * (1 - 0) / (0.5 - 0)) );
			c.rgb = 0;
			c.a = ( temp_output_8_0 * i.vertexColor.a );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			float3 gammaToLinear36 = GammaToLinearSpace( float4(0.5019608,0.5019608,0,1).rgb );
			float3 gammaToLinear34 = GammaToLinearSpace( float3( i.uv2_texcoord2 ,  0.0 ) );
			float temp_output_37_0 = saturate( distance( i.uv2_texcoord2 , float2( 0.5,0.5 ) ) );
			float clampResult11 = clamp( pow( temp_output_37_0 , _Power ) , 0 , 0.5 );
			float temp_output_8_0 = ( 1.0 - (0 + (clampResult11 - 0) * (1 - 0) / (0.5 - 0)) );
			float3 lerpResult32 = lerp( gammaToLinear36 , gammaToLinear34 , temp_output_8_0);
			o.Emission = lerpResult32;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
145;280;1237;626;1064.866;667.9857;1.883461;True;True
Node;AmplifyShaderEditor.TexCoordVertexDataNode;23;-1510.454,-116.7732;Float;True;1;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;7;-1201.363,57.10421;Float;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;37;-977.9667,43.36403;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1139.952,343.7636;Float;False;Property;_Power;Power;0;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;14;-797.2086,105.2911;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;11;-495.7851,204.9469;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;31;-659.2027,-526.8835;Float;False;Constant;_Color0;Color 0;3;1;[Gamma];Create;True;0;0;False;0;0.5019608,0.5019608,0,1;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GammaToLinearNode;34;-1229.103,-131.728;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;12;-328.8478,130.1059;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;33;-992.6791,-83.62994;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GammaToLinearNode;36;-255.6413,-474.1542;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;8;-123.0277,123.8052;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;25;111.0882,256.7703;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;32;487.4198,-441.5273;Float;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-835.0079,-54.85232;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;30;46.30872,-729.2614;Float;False;Global;_GrabScreen0;Grab Screen 0;3;0;Create;True;0;0;False;0;Object;-1;True;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LinearToGammaNode;35;-1242.046,-234.8106;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-1025.984,-27.57001;Float;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;False;0;43.33;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;27;-202.9304,-812.8496;Float;True;Property;_MainTex;Main Tex;1;0;Create;True;0;0;True;0;None;None;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;343.9632,108.0005;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;19;1031.825,-277.6458;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Custom/Farl/Amplify/AmplifyFlowMapTexture;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;False;False;False;Back;0;False;-1;7;False;-1;False;0;0;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;SrcAlpha;OneMinusSrcAlpha;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;7;0;23;0
WireConnection;37;0;7;0
WireConnection;14;0;37;0
WireConnection;14;1;15;0
WireConnection;11;0;14;0
WireConnection;34;0;23;0
WireConnection;12;0;11;0
WireConnection;33;0;34;0
WireConnection;36;0;31;0
WireConnection;8;0;12;0
WireConnection;32;0;36;0
WireConnection;32;1;33;0
WireConnection;32;2;8;0
WireConnection;39;0;37;0
WireConnection;39;1;40;0
WireConnection;35;0;23;0
WireConnection;42;0;8;0
WireConnection;42;1;25;4
WireConnection;19;2;32;0
WireConnection;19;9;42;0
ASEEND*/
//CHKSM=080A2F7320E5B8219FEC759A7FC7E629A4B038D4