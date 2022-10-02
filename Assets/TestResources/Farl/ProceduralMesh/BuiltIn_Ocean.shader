// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/BuiltIn_Ocean"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_Distortion("Distortion", 2D) = "bump" {}
		[HDR]_Color("Color", Color) = (1,1,1,1)
		[HDR]_ColorTop("Color Top", Color) = (0.5356628,1,0.4103774,1)
		[HDR]_Color1("Wave Color", Color) = (1,1,1,1)
		[Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull Mode", Float) = 0
		[HideInInspector]_WaveUV("WaveUV", Vector) = (0,0,0,0)
		[HideInInspector]_WaveAxis("WaveAxis", Vector) = (0,0,0,0)
		_Wavefront("Wavefront", Float) = 0
		_WaveSpeed("Wave Speed", Vector) = (0,0,0,0)
		_DistortionSpeed("Distortion Speed", Vector) = (0,0,0,0)
		_DistortionScale("Distortion Scale", Float) = 0
		_WavefrontDistortionScale("Wavefront Distortion Scale", Float) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_WaveHeightDivide("Wave Height Divide", Float) = 1
		_FoamFactor("Foam Factor", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull [_Cull]
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows noshadow 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float _Cull;
		uniform sampler2D _Distortion;
		uniform float4 _DistortionSpeed;
		uniform float4 _Distortion_ST;
		uniform float _DistortionScale;
		uniform float4 _Color;
		uniform float4 _ColorTop;
		uniform float _WaveHeightDivide;
		uniform sampler2D _MainTex;
		uniform float4 _WaveSpeed;
		uniform float4 _MainTex_ST;
		uniform float _FoamFactor;
		uniform float4 _Color1;
		uniform float _WavefrontDistortionScale;
		uniform float4 _WaveUV;
		uniform float4 _WaveAxis;
		uniform float _Wavefront;
		uniform float _Metallic;
		uniform float _Smoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv0_Distortion = i.uv_texcoord * _Distortion_ST.xy + _Distortion_ST.zw;
			float2 panner70 = ( 1.0 * _Time.y * (_DistortionSpeed).xy + uv0_Distortion);
			float3 tex2DNode67 = UnpackScaleNormal( tex2D( _Distortion, panner70 ), _DistortionScale );
			float3 n98 = tex2DNode67;
			o.Normal = n98;
			float3 ase_worldPos = i.worldPos;
			float wHeight50 = ( ase_worldPos.y / _WaveHeightDivide );
			float temp_output_104_0 = saturate( wHeight50 );
			float4 lerpResult47 = lerp( _Color , _ColorTop , temp_output_104_0);
			float2 uv0_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 panner56 = ( 1.0 * _Time.y * (_WaveSpeed).xy + uv0_MainTex);
			float2 panner60 = ( 1.0 * _Time.y * (_WaveSpeed).zw + uv0_MainTex);
			float4 foam100 = ( tex2D( _MainTex, ( float3( panner56 ,  0.0 ) + tex2DNode67 ).xy ) + tex2D( _MainTex, ( float3( ( 1.0 - panner60 ) ,  0.0 ) + tex2DNode67 ).xy ) );
			o.Albedo = ( lerpResult47 + ( foam100 * ( 1.0 - temp_output_104_0 ) * _FoamFactor ) ).rgb;
			float2 panner82 = ( 1.0 * _Time.y * (_DistortionSpeed).zw + uv0_Distortion);
			float3 distort77 = UnpackScaleNormal( tex2D( _Distortion, panner82 ), _WavefrontDistortionScale );
			float3 break80 = ( float3( i.uv_texcoord ,  0.0 ) + distort77 );
			float4 appendResult37 = (float4(break80.x , break80.y , 0.0 , 0.0));
			float4 appendResult39 = (float4(_WaveUV.x , _WaveUV.y , 0.0 , 0.0));
			float4 appendResult32 = (float4(_WaveAxis.x , _WaveAxis.z , 0.0 , 0.0));
			float4 normalizeResult34 = normalize( appendResult32 );
			float dotResult33 = dot( ( appendResult37 - appendResult39 ) , normalizeResult34 );
			o.Emission = ( _Color1 * step( 0.1 , pow( saturate( ( 1.0 - distance( appendResult37 , ( ( dotResult33 * normalizeResult34 ) + appendResult39 ) ) ) ) , _Wavefront ) ) * wHeight50 ).rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18301
109;475;1108;514;732.7662;899.2332;2.010861;True;False
Node;AmplifyShaderEditor.Vector4Node;71;-1381.765,638.8677;Inherit;False;Property;_DistortionSpeed;Distortion Speed;11;0;Create;True;0;0;False;0;False;0,0,0,0;0.1,-0.1,0,0.1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;72;-1325.552,389.8354;Inherit;True;Property;_Distortion;Distortion;1;0;Create;True;0;0;False;0;False;None;dd2fd2df93418444c8e280f1d34deeb5;True;bump;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;73;-1091.055,541.1371;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;85;-1147.108,854.6661;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;82;-905.3074,892.3661;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-957.3074,1028.866;Inherit;False;Property;_WavefrontDistortionScale;Wavefront Distortion Scale;13;0;Create;True;0;0;False;0;False;0;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;81;-685.607,794.8662;Inherit;True;Property;_TextureSample2;Texture Sample 2;11;0;Create;True;0;0;False;0;False;-1;None;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;-372.4962,763.2848;Inherit;False;distort;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;40;-1260.499,-1042.013;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;88;-1192.346,-879.3225;Inherit;False;77;distort;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;87;-990.3459,-942.3225;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;80;-728.5157,-950.9549;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.Vector4Node;11;-674.2091,-567.4454;Inherit;False;Property;_WaveAxis;WaveAxis;7;1;[HideInInspector];Create;True;0;0;False;0;False;0,0,0,0;1,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;8;-720.0866,-764.493;Inherit;False;Property;_WaveUV;WaveUV;6;1;[HideInInspector];Create;True;0;0;False;0;False;0,0,0,0;0.4796,0.4661954,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;37;-445.4907,-913.3972;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;39;-474.4398,-733.6425;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;32;-492.1962,-538.884;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TexturePropertyNode;4;-1208.246,14.23733;Inherit;True;Property;_MainTex;Main Texture;0;0;Create;False;0;0;False;0;False;None;9fbef4b79ca3b784ba023cb1331520d5;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.Vector4Node;57;-1077.556,289.9107;Inherit;False;Property;_WaveSpeed;Wave Speed;10;0;Create;True;0;0;False;0;False;0,0,0,0;-0.25,0,0.25,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;34;-351.2951,-530.6763;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;31;-254.1691,-786.4871;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;83;-1134.107,722.0661;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;62;-861.8437,361.9126;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;58;-915.103,125.3757;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;60;-617.6627,255.4799;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;61;-859.2885,277.5928;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-908.8987,789.6418;Inherit;False;Property;_DistortionScale;Distortion Scale;12;0;Create;True;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;33;-68.12481,-774.1754;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;70;-899.5222,642.3085;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;67;-704.3917,519.7217;Inherit;True;Property;_Tmp;Tmp;10;0;Create;True;0;0;False;0;False;-1;None;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;64;-445.8222,298.7581;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;56;-614.7617,91.03201;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-1231.19,-156.0451;Inherit;False;Property;_WaveHeightDivide;Wave Height Divide;16;0;Create;True;0;0;False;0;False;1;0.96;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;63.35207,-754.4973;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldPosInputsNode;16;-1355.697,-480.9645;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;90;-1022.161,-283.718;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;69;-383.3273,410.1595;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;68;-336.7277,574.0095;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;35;210.251,-711.915;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;59;-289.5351,241.931;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;50;-888.084,-283.704;Inherit;False;wHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;38;324.6834,-810.6503;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-352,27.5;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;41;414.294,-889.6124;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-416.1122,-59.67348;Inherit;False;50;wHeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;63;34.91635,83.69547;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;43;521.7195,-721.8734;Inherit;False;Property;_Wavefront;Wavefront;9;0;Create;True;0;0;False;0;False;0;300;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;100;175.7509,49.11179;Inherit;False;foam;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;104;-187.5855,-146.1437;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;93;563.9037,-877.3977;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;-28.5629,-218.6097;Inherit;False;100;foam;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;46;-438.9051,-236.7525;Inherit;False;Property;_ColorTop;Color Top;3;1;[HDR];Create;True;0;0;False;0;False;0.5356628,1,0.4103774,1;0.5063781,3.067205,2.011221,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;42;707.1071,-821.2432;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;5;-437.4918,-408.7641;Inherit;False;Property;_Color;Color;2;1;[HDR];Create;False;0;0;False;0;False;1,1,1,1;0,1.260125,1.515717,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;103;-12.45948,-147.1502;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-118.1389,-69.65186;Inherit;False;Property;_FoamFactor;Foam Factor;17;0;Create;True;0;0;False;0;False;1;0.298;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;97;867.1243,-835.8751;Inherit;False;2;0;FLOAT;0.1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;13;604.9963,-1040.681;Inherit;False;Property;_Color1;Wave Color;4;1;[HDR];Create;False;0;0;False;0;False;1,1,1,1;0.3018868,0.3018868,0.3018868,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;162.6667,-180.3638;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;47;-61.11584,-369.9375;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;-354.8949,690.5369;Inherit;False;n;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;689.0621,-673.9261;Inherit;False;50;wHeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;12;201.6695,502.7006;Inherit;False;Property;_WaveScale;WaveScale;8;0;Create;True;0;0;False;0;False;0,0,0,0;39.08237,8.455352,10.72727,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;7;258.1465,377.0195;Inherit;False;Property;_Cull;Cull Mode;5;1;[Enum];Create;False;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;1035.4,-850.9707;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;245.6258,270.9947;Inherit;False;54;wUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;24;-433.5855,-1077.164;Inherit;False;Constant;_up;up;7;0;Create;True;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;48;-1132.163,-395.3181;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;978.5696,-659.6358;Inherit;False;98;n;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;75;729.6039,-452.4583;Inherit;False;Property;_Metallic;Metallic;14;0;Create;True;0;0;False;0;False;0;0.781;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-975.0647,-373.3642;Inherit;False;wUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;76;739.6039,-370.4583;Inherit;False;Property;_Smoothness;Smoothness;15;0;Create;True;0;0;False;0;False;0;0.175;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;106;264.3204,-358.5093;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1258.939,-631.9171;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Custom/Farl/Amplify/BuiltIn_Ocean;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;True;7;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;73;2;72;0
WireConnection;85;0;71;0
WireConnection;82;0;73;0
WireConnection;82;2;85;0
WireConnection;81;0;72;0
WireConnection;81;1;82;0
WireConnection;81;5;86;0
WireConnection;77;0;81;0
WireConnection;87;0;40;0
WireConnection;87;1;88;0
WireConnection;80;0;87;0
WireConnection;37;0;80;0
WireConnection;37;1;80;1
WireConnection;39;0;8;1
WireConnection;39;1;8;2
WireConnection;32;0;11;1
WireConnection;32;1;11;3
WireConnection;34;0;32;0
WireConnection;31;0;37;0
WireConnection;31;1;39;0
WireConnection;83;0;71;0
WireConnection;62;0;57;0
WireConnection;58;2;4;0
WireConnection;60;0;58;0
WireConnection;60;2;62;0
WireConnection;61;0;57;0
WireConnection;33;0;31;0
WireConnection;33;1;34;0
WireConnection;70;0;73;0
WireConnection;70;2;83;0
WireConnection;67;0;72;0
WireConnection;67;1;70;0
WireConnection;67;5;74;0
WireConnection;64;0;60;0
WireConnection;56;0;58;0
WireConnection;56;2;61;0
WireConnection;36;0;33;0
WireConnection;36;1;34;0
WireConnection;90;0;16;2
WireConnection;90;1;91;0
WireConnection;69;0;56;0
WireConnection;69;1;67;0
WireConnection;68;0;64;0
WireConnection;68;1;67;0
WireConnection;35;0;36;0
WireConnection;35;1;39;0
WireConnection;59;0;4;0
WireConnection;59;1;68;0
WireConnection;50;0;90;0
WireConnection;38;0;37;0
WireConnection;38;1;35;0
WireConnection;2;0;4;0
WireConnection;2;1;69;0
WireConnection;41;0;38;0
WireConnection;63;0;2;0
WireConnection;63;1;59;0
WireConnection;100;0;63;0
WireConnection;104;0;52;0
WireConnection;93;0;41;0
WireConnection;42;0;93;0
WireConnection;42;1;43;0
WireConnection;103;0;104;0
WireConnection;97;1;42;0
WireConnection;102;0;101;0
WireConnection;102;1;103;0
WireConnection;102;2;105;0
WireConnection;47;0;5;0
WireConnection;47;1;46;0
WireConnection;47;2;104;0
WireConnection;98;0;67;0
WireConnection;44;0;13;0
WireConnection;44;1;97;0
WireConnection;44;2;51;0
WireConnection;48;0;16;1
WireConnection;48;1;16;3
WireConnection;54;0;48;0
WireConnection;106;0;47;0
WireConnection;106;1;102;0
WireConnection;0;0;106;0
WireConnection;0;1;99;0
WireConnection;0;2;44;0
WireConnection;0;3;75;0
WireConnection;0;4;76;0
ASEEND*/
//CHKSM=22C268F210B15DD0F39CBEC0FC57EC97B0ED15A6