// Made with Amplify Shader Editor v1.9.3.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SS/ProceduralOcean BiRP (ASE)"
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
		_WaveSpeed("Wave Speed", Vector) = (0,0,0,0)
		_DistortionSpeed("Distortion Speed", Vector) = (0,0,0,0)
		_DistortionScale("Distortion Scale", Float) = 0
		_WavefrontDistortionScale("Wavefront Distortion Scale", Float) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_WaveHeightDivide("Wave Height Divide", Float) = 1
		_FoamFactor("Foam Factor", Range( 0 , 1)) = 1
		[HideInInspector]_Distortion_ST("_Distortion_ST", Vector) = (0,0,0,0)
		_WaveHeight("Wave Height", Float) = 0
		_WavefrontBiasScalePower("Wavefront (Bias, Scale, Power)", Vector) = (0,1,1,0)
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
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
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
		uniform float _WaveHeight;
		uniform float4 _Color;
		uniform float4 _ColorTop;
		uniform float _WaveHeightDivide;
		uniform sampler2D _MainTex;
		uniform float4 _WaveSpeed;
		uniform float4 _MainTex_ST;
		uniform float _FoamFactor;
		uniform float4 _Color1;
		uniform float4 _WaveUV;
		uniform float _WavefrontDistortionScale;
		uniform float4 _WaveAxis;
		uniform float4 _WavefrontBiasScalePower;
		uniform float _Metallic;
		uniform float _Smoothness;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float2 uv_Distortion = v.texcoord.xy * _Distortion_ST.xy + _Distortion_ST.zw;
			float2 panner70 = ( 1.0 * _Time.y * (_DistortionSpeed).xy + uv_Distortion);
			float3 n98 = UnpackScaleNormal( tex2Dlod( _Distortion, float4( panner70, 0, 0.0) ), _DistortionScale );
			float dotResult130 = dot( n98 , float3(0,1,0) );
			float3 temp_cast_0 = (( dotResult130 * _WaveHeight )).xxx;
			v.vertex.xyz += temp_cast_0;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Distortion = i.uv_texcoord * _Distortion_ST.xy + _Distortion_ST.zw;
			float2 panner70 = ( 1.0 * _Time.y * (_DistortionSpeed).xy + uv_Distortion);
			float3 n98 = UnpackScaleNormal( tex2D( _Distortion, panner70 ), _DistortionScale );
			o.Normal = n98;
			float3 ase_worldPos = i.worldPos;
			float wHeight50 = ( ase_worldPos.y / _WaveHeightDivide );
			float temp_output_104_0 = saturate( wHeight50 );
			float4 lerpResult47 = lerp( _Color , _ColorTop , temp_output_104_0);
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 panner56 = ( 1.0 * _Time.y * (_WaveSpeed).xy + uv_MainTex);
			float2 panner60 = ( 1.0 * _Time.y * (_WaveSpeed).zw + uv_MainTex);
			float4 foam100 = ( tex2D( _MainTex, ( float3( panner56 ,  0.0 ) + n98 ).xy ) + tex2D( _MainTex, ( float3( ( 1.0 - panner60 ) ,  0.0 ) + n98 ).xy ) );
			float4 albedo109 = ( lerpResult47 + ( foam100 * ( 1.0 - temp_output_104_0 ) * _FoamFactor ) );
			o.Albedo = albedo109.rgb;
			float2 temp_output_122_0 = (_Distortion_ST).xy;
			float2 appendResult39 = (float2(_WaveUV.x , _WaveUV.y));
			float2 waveUV115 = appendResult39;
			float2 panner82 = ( 1.0 * _Time.y * (_DistortionSpeed).zw + ( ( ( uv_Distortion / temp_output_122_0 ) - waveUV115 ) * temp_output_122_0 ));
			float3 distort77 = UnpackScaleNormal( tex2D( _Distortion, panner82 ), _WavefrontDistortionScale );
			float2 temp_output_119_0 = (( float3( i.uv_texcoord ,  0.0 ) + distort77 )).xy;
			float2 appendResult32 = (float2(_WaveAxis.x , _WaveAxis.z));
			float2 normalizeResult34 = normalize( appendResult32 );
			float dotResult33 = dot( ( temp_output_119_0 - appendResult39 ) , normalizeResult34 );
			float temp_output_3_0_g1 = ( saturate( ( ( pow( saturate( ( 1.0 - distance( temp_output_119_0 , ( ( dotResult33 * normalizeResult34 ) + appendResult39 ) ) ) ) , _WavefrontBiasScalePower.z ) * _WavefrontBiasScalePower.y ) + _WavefrontBiasScalePower.x ) ) - _WavefrontBiasScalePower.w );
			float4 emission107 = ( _Color1 * saturate( ( temp_output_3_0_g1 / fwidth( temp_output_3_0_g1 ) ) ) * wHeight50 );
			o.Emission = emission107.rgb;
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
Version=19303
Node;AmplifyShaderEditor.Vector4Node;8;-1590.018,-659.5593;Inherit;False;Property;_WaveUV;WaveUV;6;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0,0;0.5,0.5,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;39;-1388.279,-642.9932;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;121;-1442.869,1324.29;Inherit;False;Property;_Distortion_ST;_Distortion_ST;17;1;[HideInInspector];Create;False;0;0;0;False;0;False;0,0,0,0;10,10,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;72;-1230.773,692.4417;Inherit;True;Property;_Distortion;Distortion;1;0;Create;True;0;0;0;False;0;False;None;dd2fd2df93418444c8e280f1d34deeb5;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SwizzleNode;122;-1247.095,1388.394;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;73;-1165.05,1177.348;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;115;-1231.668,-564.5086;Inherit;False;waveUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;125;-938.2001,1183.936;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;-1007.519,1336.072;Inherit;False;115;waveUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;120;-825.5383,1258.61;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;71;-1220.448,983.0652;Inherit;False;Property;_DistortionSpeed;Distortion Speed;10;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.1,-0.1,0,0.3;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;-711.5657,1368.405;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;85;-945.008,1092.536;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-596.4445,1266.736;Inherit;False;Property;_WavefrontDistortionScale;Wavefront Distortion Scale;12;0;Create;True;0;0;0;False;0;False;0;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;82;-661.3922,1084.794;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;81;-336.3965,1026.91;Inherit;True;Property;_TextureSample2;Texture Sample 2;11;0;Create;True;0;0;0;False;0;False;-1;None;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;-9.658462,1035.313;Inherit;False;distort;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-1940.952,-726.9921;Inherit;False;77;distort;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;40;-1953.323,-850.0151;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;11;-1585.974,-456.8378;Inherit;False;Property;_WaveAxis;WaveAxis;7;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0,0;1,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;87;-1712.92,-792.4713;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;119;-1386.819,-815.5746;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;32;-1403.961,-428.2764;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalizeNode;34;-1263.06,-420.0687;Inherit;False;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;31;-1161.914,-699.3772;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;83;-932.007,959.9363;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;118;-891.512,803.3687;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;33;-994.0922,-628.062;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;57;-1173.032,220.4736;Inherit;False;Property;_WaveSpeed;Wave Speed;9;0;Create;True;0;0;0;False;0;False;0,0,0,0;-0.25,0,0.25,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;4;-1212.586,-65.32594;Inherit;True;Property;_MainTex;Main Texture;0;0;Create;False;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.PannerNode;70;-550.3117,874.3525;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-559.6882,1021.686;Inherit;False;Property;_DistortionScale;Distortion Scale;11;0;Create;True;0;0;0;False;0;False;0;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-849.8333,-619.7458;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-703.5096,-578.3209;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;67;-342.0724,791.0922;Inherit;True;Property;_Tmp;Tmp;10;0;Create;True;0;0;0;False;0;False;-1;None;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;58;-915.103,76.19114;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;62;-871.9698,302.6018;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;60;-617.6627,255.4799;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;38;-560.0973,-673.0584;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;112;-1784.079,-1615.852;Inherit;False;734.8767;338.2253;;6;90;50;48;54;91;16;World Height;1,1,1,1;0;0
Node;AmplifyShaderEditor.SwizzleNode;61;-869.4146,218.282;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;-10.05373,786.2366;Inherit;False;n;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;16;-1734.079,-1565.852;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;64;-445.8222,298.7581;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;56;-614.7617,91.03201;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-1699.392,-1393.627;Inherit;False;Property;_WaveHeightDivide;Wave Height Divide;15;0;Create;True;0;0;0;False;0;False;1;0.96;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;41;-433.309,-678.6498;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;-446.1759,185.5;Inherit;False;98;n;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;68;-268.7372,328.0866;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;69;-253.1329,102.0327;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;90;-1407.279,-1424.743;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;93;-294.7399,-679.8353;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;135;-449.0676,-496.8215;Inherit;False;Property;_WavefrontBiasScalePower;Wavefront (Bias, Scale, Power);19;0;Create;True;0;0;0;False;0;False;0,1,1,0;-0.24,4.01,265.01,0.1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;42;-160.5758,-698.9672;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;59;-69.65116,263.6301;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;50;-1273.202,-1424.729;Inherit;False;wHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-49.65963,-34.70404;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;111;-939.6442,-1696.664;Inherit;False;1144.245;515.0906;;11;52;105;104;101;46;5;103;102;47;106;109;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-866.8513,-1297.573;Inherit;False;50;wHeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;63;254.8003,105.3945;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;-147.8676,-592.1213;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;100;395.6348,70.81087;Inherit;False;foam;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;104;-638.3247,-1384.043;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;137;8.098647,-595.5548;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;103;-463.1987,-1385.05;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;134;64.13237,-680.5214;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;46;-889.6442,-1474.652;Inherit;False;Property;_ColorTop;Color Top;3;1;[HDR];Create;True;0;0;0;False;0;False;0.5356628,1,0.4103774,1;0.2971698,0.8968982,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;5;-888.2309,-1646.664;Inherit;False;Property;_Color;Color;2;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;0,0.6502514,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;105;-568.8781,-1307.552;Inherit;False;Property;_FoamFactor;Foam Factor;16;0;Create;True;0;0;0;False;0;False;1;0.877;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;-479.3021,-1456.509;Inherit;False;100;foam;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;47;-511.855,-1607.837;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;13;-50.77778,-900.8277;Inherit;False;Property;_Color1;Wave Color;4;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;138;204.6033,-731.5185;Inherit;False;Step Antialiasing;-1;;1;2a825e80dfb3290468194f83380797bd;0;2;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;72.25452,-520.6589;Inherit;False;50;wHeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-288.0725,-1418.263;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;106;-186.4188,-1596.409;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;126;380.3515,-1279.656;Inherit;False;98;n;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;129;396.8683,-1203.424;Inherit;False;Constant;_up;up;19;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;429.9041,-712.8347;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;107;615.1442,-722.0265;Inherit;False;emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;130;564.5776,-1249.163;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;109;-19.39961,-1591.618;Inherit;False;albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;132;532.8145,-1127.192;Inherit;False;Property;_WaveHeight;Wave Height;18;0;Create;True;0;0;0;False;0;False;0;0.65;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;48;-1517.281,-1536.344;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;604.5542,-1559.27;Inherit;False;107;emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-1360.183,-1514.389;Inherit;False;wUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;12;1122.403,-1395.564;Inherit;False;Property;_WaveScale;WaveScale;8;0;Create;True;0;0;0;False;0;False;0,0,0,0;39.08237,8.455352,10.72727,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;76;499.5303,-1387.118;Inherit;False;Property;_Smoothness;Smoothness;14;0;Create;True;0;0;0;False;0;False;0;0.746;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;489.5303,-1469.118;Inherit;False;Property;_Metallic;Metallic;13;0;Create;True;0;0;0;False;0;False;0;0.737;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;703.0649,-1216.129;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;1178.88,-1521.245;Inherit;False;Property;_Cull;Cull Mode;5;1;[Enum];Create;False;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;603.1338,-1711.234;Inherit;False;109;albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;597.5935,-1647.665;Inherit;False;98;n;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;842.5111,-1664.93;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;SS/ProceduralOcean BiRP (ASE);False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;True;_Cull;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;39;0;8;1
WireConnection;39;1;8;2
WireConnection;122;0;121;0
WireConnection;73;2;72;0
WireConnection;115;0;39;0
WireConnection;125;0;73;0
WireConnection;125;1;122;0
WireConnection;120;0;125;0
WireConnection;120;1;117;0
WireConnection;124;0;120;0
WireConnection;124;1;122;0
WireConnection;85;0;71;0
WireConnection;82;0;124;0
WireConnection;82;2;85;0
WireConnection;81;0;72;0
WireConnection;81;1;82;0
WireConnection;81;5;86;0
WireConnection;77;0;81;0
WireConnection;87;0;40;0
WireConnection;87;1;88;0
WireConnection;119;0;87;0
WireConnection;32;0;11;1
WireConnection;32;1;11;3
WireConnection;34;0;32;0
WireConnection;31;0;119;0
WireConnection;31;1;39;0
WireConnection;83;0;71;0
WireConnection;118;2;72;0
WireConnection;33;0;31;0
WireConnection;33;1;34;0
WireConnection;70;0;118;0
WireConnection;70;2;83;0
WireConnection;36;0;33;0
WireConnection;36;1;34;0
WireConnection;35;0;36;0
WireConnection;35;1;39;0
WireConnection;67;0;72;0
WireConnection;67;1;70;0
WireConnection;67;5;74;0
WireConnection;58;2;4;0
WireConnection;62;0;57;0
WireConnection;60;0;58;0
WireConnection;60;2;62;0
WireConnection;38;0;119;0
WireConnection;38;1;35;0
WireConnection;61;0;57;0
WireConnection;98;0;67;0
WireConnection;64;0;60;0
WireConnection;56;0;58;0
WireConnection;56;2;61;0
WireConnection;41;0;38;0
WireConnection;68;0;64;0
WireConnection;68;1;113;0
WireConnection;69;0;56;0
WireConnection;69;1;113;0
WireConnection;90;0;16;2
WireConnection;90;1;91;0
WireConnection;93;0;41;0
WireConnection;42;0;93;0
WireConnection;42;1;135;3
WireConnection;59;0;4;0
WireConnection;59;1;68;0
WireConnection;50;0;90;0
WireConnection;2;0;4;0
WireConnection;2;1;69;0
WireConnection;63;0;2;0
WireConnection;63;1;59;0
WireConnection;136;0;42;0
WireConnection;136;1;135;2
WireConnection;100;0;63;0
WireConnection;104;0;52;0
WireConnection;137;0;136;0
WireConnection;137;1;135;1
WireConnection;103;0;104;0
WireConnection;134;0;137;0
WireConnection;47;0;5;0
WireConnection;47;1;46;0
WireConnection;47;2;104;0
WireConnection;138;1;135;4
WireConnection;138;2;134;0
WireConnection;102;0;101;0
WireConnection;102;1;103;0
WireConnection;102;2;105;0
WireConnection;106;0;47;0
WireConnection;106;1;102;0
WireConnection;44;0;13;0
WireConnection;44;1;138;0
WireConnection;44;2;51;0
WireConnection;107;0;44;0
WireConnection;130;0;126;0
WireConnection;130;1;129;0
WireConnection;109;0;106;0
WireConnection;48;0;16;1
WireConnection;48;1;16;3
WireConnection;54;0;48;0
WireConnection;131;0;130;0
WireConnection;131;1;132;0
WireConnection;0;0;110;0
WireConnection;0;1;99;0
WireConnection;0;2;108;0
WireConnection;0;3;75;0
WireConnection;0;4;76;0
WireConnection;0;11;131;0
ASEEND*/
//CHKSM=F3679D4F86963F4C3C178A910E5993B9C2454AB7