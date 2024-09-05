// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Anisotropic/Circular"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_AlbedoRGBOpacityA("Albedo (RGB) Opacity (A)", 2D) = "white" {}
		_AlbedoTint("Albedo Tint", Color) = (1,1,1,1)
		_Specular("Specular", 2D) = "white" {}
		_SpecularTint("Specular Tint", Color) = (1,1,1,1)
		_Normal("Normal", 2D) = "bump" {}
		_NormalAmount("Normal Amount", Range( -2 , 2)) = 1
		_AnisotropyFalloff("Anisotropy Falloff", Range( 1 , 256)) = 64
		_AnisotropyOffset("Anisotropy Offset", Range( -1 , 1)) = 0
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf StandardSpecular keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_Normal;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float2 uv_AlbedoRGBOpacityA;
			float2 uv_Specular;
		};

		uniform float _NormalAmount;
		uniform sampler2D _Normal;
		uniform float4 WorldSpaceLightPos0;
		uniform float4 _AlbedoTint;
		uniform sampler2D _AlbedoRGBOpacityA;
		uniform float4 _SpecularTint;
		uniform sampler2D _Specular;
		uniform float _AnisotropyOffset;
		uniform float _AnisotropyFalloff;

		void surf( Input input , inout SurfaceOutputStandardSpecular output )
		{
			output.Normal = float3(0,0,1);
			float3 NormalMap = UnpackScaleNormal( tex2D( _Normal,input.uv_Normal) ,_NormalAmount );
			float3 PixelNormalWorld = normalize( WorldNormalVector( input , NormalMap ) );
			float3 LightDirection = normalize( WorldSpaceLightDir( WorldSpaceLightPos0 ) );
			float3 ViewDirection = normalize( ( _WorldSpaceCameraPos - input.worldPos ) );
			float nDotL = dot( PixelNormalWorld , LightDirection );
			float3 HalfVector = normalize( ( LightDirection + ViewDirection ) );
			float nDotH = dot( PixelNormalWorld , HalfVector );
			output.Normal = NormalMap;
			float4 Node41Port0FLOAT4=( _AlbedoTint * tex2D( _AlbedoRGBOpacityA,input.uv_AlbedoRGBOpacityA) );
			output.Albedo = Node41Port0FLOAT4.xyz;
			float4 FLOATToFLOAT41=0.0;
			output.Specular = max( ( ( ( _SpecularTint * tex2D( _Specular,input.uv_Specular) ) * pow( max( sin( radians( ( ( _AnisotropyOffset + nDotH ) * 180.0 ) ) ) , 0.0 ) , _AnisotropyFalloff ) ) * nDotL ) , FLOATToFLOAT41 ).xyz;
			float Node42Port3FLOAT=( _AlbedoTint * tex2D( _AlbedoRGBOpacityA,input.uv_AlbedoRGBOpacityA) ).w;
			output.Alpha = Node42Port3FLOAT;
			clip( Node42Port3FLOAT - 0.6 );
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=15
-1915;32;1910;1019;1498.283;207.8025;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;61;-3818.594,-85.00156;672.9105;238.5802;Pixel Normal Vector;3;58;51;52
Node;AmplifyShaderEditor.CommentaryNode;60;-2989.588,457.5991;586.7201;231.8202;Halfway Vector;3;46;18;17
Node;AmplifyShaderEditor.CommentaryNode;59;-3994.292,314.6999;874.0206;255.4803;Light Direction Vector;4;15;14;13;16
Node;AmplifyShaderEditor.CommentaryNode;57;-3991.898,642.3001;860.5006;304.4899;View Direction Vector;5;6;9;8;10;11
Node;AmplifyShaderEditor.WorldSpaceCameraPos;6;-3959.809,690.5999
Node;AmplifyShaderEditor.WorldPosInputsNode;10;-3887.112,776.1987
Node;AmplifyShaderEditor.NormalizeNode;9;-3537.11,756.199;0,0,0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;8;-3699.808,732.3992;0.0,0,0;0,0,0
Node;AmplifyShaderEditor.WorldSpaceLightPos;13;-3979.301,410.9026
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;14;-3751.803,408.3016;0,0,0,0
Node;AmplifyShaderEditor.NormalizeNode;15;-3524.3,413.5027;0,0,0
Node;AmplifyShaderEditor.NormalizeNode;18;-2760.305,538.902;0,0,0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-2943.107,530.9026;0.0,0,0;0,0,0
Node;AmplifyShaderEditor.WorldNormalVector;51;-3784.708,-30.40153;0,0,0
Node;AmplifyShaderEditor.NormalizeNode;58;-3570.492,1.399191;0,0,0
Node;AmplifyShaderEditor.DotProductOpNode;21;-2812.199,31.0029;0.0,0,0;0,0,0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-1955.204,253.5026;0.0;0.0
Node;AmplifyShaderEditor.RangedFloatNode;25;-2303.304,176.503;Property;_AnisotropyOffset;Anisotropy Offset;9;0;-1;1
Node;AmplifyShaderEditor.DotProductOpNode;23;-2335.101,279.9036;0.0,0,0;0,0,0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1787.703,253.0026;0.0;0.0
Node;AmplifyShaderEditor.RadiansOpNode;29;-1604.702,253.3027;0.0
Node;AmplifyShaderEditor.SinOpNode;30;-1430.901,254.2025;0.0
Node;AmplifyShaderEditor.RangedFloatNode;32;-1418.601,357.3027;Constant;_Float1;Float 1;-1;0;0;0
Node;AmplifyShaderEditor.SimpleMaxOp;31;-1251.303,254.8026;0.0;0.0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1405.404,539.7997;Property;_AnisotropyFalloff;Anisotropy Falloff;8;64;1;256
Node;AmplifyShaderEditor.ColorNode;43;-1315.204,-195.798;Property;_SpecularTint;Specular Tint;4;1,1,1,1
Node;AmplifyShaderEditor.SamplerNode;4;-1389.803,-20.40015;Property;_Specular;Specular;3;None;True;0;False;white;Auto;False;Object;-1;0,0;1.0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-1042.105,-89.49779;0.0,0,0,0;0,0,0,0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-872.6018,69.80269;0.0,0,0,0;0
Node;AmplifyShaderEditor.PowerNode;38;-1051.004,253.1033;0.0;0.0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-691.3027,152.2005;0.0,0,0,0;0.0
Node;AmplifyShaderEditor.SimpleMaxOp;54;-514.202,220.4997;0.0,0,0,0;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-279.9993,-352.7;True;StandardSpecular;Anisotropic/Circular;False;False;False;False;False;False;False;False;False;False;False;False;Back;On;LEqual;Masked;0.6;True;True;0;False;TransparentCutout;AlphaTest;0,0,0;0,0,0;0,0,0;0,0,0;0.0;0.0;0.0;0.0;0.0;0.0;0.0;0,0,0
Node;AmplifyShaderEditor.SamplerNode;1;-1321.102,-460.4998;Property;_AlbedoRGBOpacityA;Albedo (RGB) Opacity (A);1;None;True;0;False;white;Auto;False;Object;-1;0,0;1.0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-962.7011,-540.5963;0.0,0,0,0;0,0,0,0
Node;AmplifyShaderEditor.ColorNode;40;-1266.202,-631.3965;Property;_AlbedoTint;Albedo Tint;2;1,1,1,1
Node;AmplifyShaderEditor.BreakToComponentsNode;42;-728.0019,-249.5965;FLOAT4;0.0,0,0,0
Node;AmplifyShaderEditor.SamplerNode;45;-4805.913,-340.998;Property;_Normal;Normal;5;None;True;0;True;bump;Auto;True;Object;-1;0,0;1.0
Node;AmplifyShaderEditor.RangedFloatNode;47;-5137.81,-324.9976;Property;_NormalAmount;Normal Amount;6;1;-2;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-4378.583,-322.203;NormalMap;1;0.0,0,0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-3388.301,-3.401581;PixelNormalWorld;2;0.0,0,0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-3343.401,401.8022;LightDirection;3;0.0,0,0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-510.6903,-335.0045;6
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-3352.008,755.8986;ViewDirection;4;0.0,0,0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-2640.498,29.70248;nDotL;5;0.0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-2583.402,535.2017;HalfVector;6;0.0,0,0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-2166.802,277.3034;nDotH;7;0.0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1948.803,369.003;Constant;_Float0;Float 0;-1;180;0;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-685.1027,305.5001;Constant;_Float2;Float 2;-1;0;0;0
WireConnection;9;0;8;0
WireConnection;8;0;6;0
WireConnection;8;1;10;0
WireConnection;14;0;13;0
WireConnection;15;0;14;0
WireConnection;18;0;17;0
WireConnection;17;0;16;0
WireConnection;17;1;11;0
WireConnection;51;0;62;0
WireConnection;58;0;51;0
WireConnection;21;0;52;0
WireConnection;21;1;16;0
WireConnection;26;0;25;0
WireConnection;26;1;24;0
WireConnection;23;0;52;0
WireConnection;23;1;46;0
WireConnection;27;0;26;0
WireConnection;27;1;28;0
WireConnection;29;0;27;0
WireConnection;30;0;29;0
WireConnection;31;0;30;0
WireConnection;31;1;32;0
WireConnection;44;0;43;0
WireConnection;44;1;4;0
WireConnection;39;0;44;0
WireConnection;39;1;38;0
WireConnection;38;0;31;0
WireConnection;38;1;3;0
WireConnection;53;0;39;0
WireConnection;53;1;22;0
WireConnection;54;0;53;0
WireConnection;54;1;55;0
WireConnection;0;0;41;0
WireConnection;0;1;63;0
WireConnection;0;3;54;0
WireConnection;0;6;42;3
WireConnection;0;7;42;3
WireConnection;41;0;40;0
WireConnection;41;1;1;0
WireConnection;42;0;41;0
WireConnection;45;1;47;0
WireConnection;62;0;45;0
WireConnection;52;0;58;0
WireConnection;16;0;15;0
WireConnection;11;0;9;0
WireConnection;22;0;21;0
WireConnection;46;0;18;0
WireConnection;24;0;23;0
ASEEND*/
//CHKSM=3F2B5427217F3CE04AA55E5C16C3D8AFDFF82EA6