// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Custom Standard"
{
	Properties
	{
		_MainTex("Albedo", 2D) = "white" {}
		[NoScaleOffset]_BumpMap("Normal", 2D) = "bump" {}
		[NoScaleOffset]_MetallicGlossMap("Metallic Smoothness", 2D) = "white" {}
		[NoScaleOffset]_OcclusionMap("Ambient Occlusion", 2D) = "white" {}
		[NoScaleOffset]_DetailMask("Detail Mask", 2D) = "white" {}
		_DetailNormalMap("Detail Normal", 2D) = "bump" {}
		[NoScaleOffset]_DetailAlbedoMap("Detail Albedo x 2", 2D) = "gray" {}
		[HDR][NoScaleOffset]_EmissionMap("Emission", 2D) = "black" {}
		_BumpScale("Normal Scale", Float) = 1
		_DetailNormalMapScale("Detail Normal Scale", Float) = 1
		_GlossMapScale("Gloss Map Scale", Float) = 1
		_EmissionColor("Emission Color", Color) = (0,0,0,0)
		_Color("Color", Color) = (1,1,1,1)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
			float2 uv2_texcoord2;
		};

		uniform float _BumpScale;
		uniform sampler2D _BumpMap;
		uniform float4 _BumpMap_ST;
		uniform float _DetailNormalMapScale;
		uniform sampler2D _DetailNormalMap;
		uniform float4 _DetailNormalMap_ST;
		uniform sampler2D _DetailMask;
		uniform float4 _DetailMask_ST;
		uniform float4 _Color;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _DetailAlbedoMap;
		uniform float4 _EmissionColor;
		uniform sampler2D _EmissionMap;
		uniform sampler2D _MetallicGlossMap;
		uniform float _GlossMapScale;
		uniform sampler2D _OcclusionMap;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			float2 parallaxOffset49 = float2( 0,0 );
			float2 uv_DetailNormalMap = i.uv_texcoord * _DetailNormalMap_ST.xy + _DetailNormalMap_ST.zw;
			float3 detailNormalTangent71 = UnpackScaleNormal( tex2D( _DetailNormalMap, uv_DetailNormalMap ) ,_DetailNormalMapScale );
			float2 uv_DetailMask = i.uv2_texcoord2 * _DetailMask_ST.xy + _DetailMask_ST.zw;
			float detailMask58 = tex2D( _DetailMask, uv_DetailMask ).a;
			float3 lerpResult72 = lerp( UnpackScaleNormal( tex2D( _BumpMap, ( uv_BumpMap + parallaxOffset49 ) ) ,_BumpScale ) , detailNormalTangent71 , detailMask58);
			float3 normal74 = lerpResult72;
			o.Normal = normal74;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 parallaxUV87 = ( uv_MainTex + parallaxOffset49 );
			float4 lerpResult55 = lerp( float4(1,1,1,1) , ( tex2D( _DetailAlbedoMap, parallaxUV87 ) * float4(4.594794,4.594794,4.594794,2) ) , detailMask58);
			float4 albedo52 = ( _Color * tex2D( _MainTex, parallaxUV87 ) * lerpResult55 );
			o.Albedo = albedo52.rgb;
			float4 emission53 = ( _EmissionColor * tex2D( _EmissionMap, parallaxUV87 ) );
			o.Emission = emission53.rgb;
			float4 tex2DNode6 = tex2D( _MetallicGlossMap, parallaxUV87 );
			float metaillic80 = (tex2DNode6.r).x;
			o.Metallic = metaillic80;
			float glossiness81 = ( tex2DNode6.a * _GlossMapScale );
			o.Smoothness = glossiness81;
			float4 ao91 = tex2D( _OcclusionMap, parallaxUV87 );
			o.Occlusion = ao91.r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
0;45;990;855;1493.867;510.2489;1.561535;True;False
Node;AmplifyShaderEditor.CommentaryNode;50;-137.2007,-1656.566;Float;False;1434.314;766.5547;;15;38;39;40;8;41;25;43;42;45;44;46;47;48;49;93;Parallax Offset;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;1063.113,-1345.841;Float;False;parallaxOffset;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;85;-1934.304,485.8799;Float;False;0;2;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;86;-1902.739,658.4885;Float;False;49;0;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;63;-2219.967,-1695.276;Float;False;1866.53;923.0317;;12;62;61;52;33;13;60;59;55;57;2;31;94;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;-1662.521,628.8146;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;75;-2206.263,-698.9728;Float;False;1459.765;766.382;;12;65;64;35;16;4;72;12;21;36;71;73;74;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;-1511.326,616.0972;Float;False;parallaxUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;37;-1146.759,873.3193;Float;False;1;11;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;94;-2077.523,-1610.491;Float;False;87;0;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;54;-249.6402,-504.6054;Float;False;918.3579;441.4347;;5;32;53;15;34;92;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;82;-1129.151,148.3578;Float;False;1277.535;398.389;;7;89;78;81;80;76;23;6;Metaillic Glossiness;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-2156.263,-317.4216;Float;False;0;12;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;21;-2135.306,-179.6644;Float;False;Property;_DetailNormalMapScale;Detail Normal Scale;11;0;Create;False;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;13;-1757.097,-1385.953;Float;True;Property;_DetailAlbedoMap;Detail Albedo x 2;7;1;[NoScaleOffset];Create;False;0;0;False;0;None;d3a780a450cf8584793c374ad13bcaa4;True;1;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;65;-1948.607,-508.2808;Float;False;49;0;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;62;-1787.336,-989.8235;Float;False;Constant;_ColorSpaceDoubleLinear;Color Space Double (Linear);23;0;Create;True;0;0;False;0;4.594794,4.594794,4.594794,2;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-1944.763,-648.9728;Float;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;11;-897,921;Float;True;Property;_DetailMask;Detail Mask;5;1;[NoScaleOffset];Create;False;0;0;False;0;None;45ea98975d00f49d4a37af20347af491;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;89;-1105.782,204.9016;Float;False;87;0;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;57;-1248.467,-1241.52;Float;False;Constant;_white;white;23;0;Create;True;0;0;False;0;1,1,1,1;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;59;-1206.642,-1043.265;Float;False;58;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-231.9793,-436.1321;Float;False;87;0;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;64;-1713.078,-571.5249;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;-598.6801,1011.475;Float;False;detailMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;12;-1909.111,-262.6261;Float;True;Property;_DetailNormalMap;Detail Normal;6;0;Create;False;0;0;False;0;None;8178c5ce4aa3d5341804ce7d0ff18428;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-1422.723,-1128.945;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1812.043,-403.8134;Float;False;Property;_BumpScale;Normal Scale;9;0;Create;False;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-905.3473,198.3578;Float;True;Property;_MetallicGlossMap;Metallic Smoothness;2;1;[NoScaleOffset];Create;False;0;0;False;0;None;380d8cba402d8d4449e8f6e04c1183a9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;71;-1548.696,-172.2344;Float;False;detailNormalTangent;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;4;-1562.132,-501.3317;Float;True;Property;_BumpMap;Normal;1;1;[NoScaleOffset];Create;False;0;0;False;0;None;dcca21e48675b2f4a94837d3a378637d;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;73;-1460.571,-47.59079;Float;False;58;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-648.087,412.3771;Float;False;Property;_GlossMapScale;Gloss Map Scale;16;0;Create;False;0;0;False;0;1;0.57;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;31;-1207.087,-1645.276;Float;False;Property;_Color;Color;22;0;Create;False;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;32;-20.94954,-454.6054;Float;False;Property;_EmissionColor;Emission Color;21;0;Create;False;0;0;False;0;0,0,0,0;0.2205882,0.2205882,0.2205882,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-1289.451,-1461.848;Float;True;Property;_MainTex;Albedo;0;0;Create;False;0;0;False;0;None;d5bc70618862cb04b8e4366956d3e13d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;15;-98.41063,-275.4554;Float;True;Property;_EmissionMap;Emission;8;2;[HDR];[NoScaleOffset];Create;False;0;0;False;0;None;7500c8a43fbd6b344affb592fa314394;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;55;-986.4672,-1169.52;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-1067.63,671.2059;Float;False;87;0;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;72;-1170.492,-319.0099;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-288.8342,395.8324;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;78;-252.394,287.7721;Float;False;FLOAT;0;1;1;1;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;10;-863,656;Float;True;Property;_OcclusionMap;Ambient Occlusion;4;1;[NoScaleOffset];Create;False;0;0;False;0;None;ecd84d608ef693546b70a9f04f88ff0a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;233.4971,-288.8516;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-796.2203,-1536.093;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;44;433.1955,-1079.698;Float;False;FLOAT;2;1;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;41;95.22866,-1184.538;Float;False;Tangent;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;38;498.2089,-1496.026;Float;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;93;-92.26154,-1590.221;Float;False;0;2;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;201.3575,-1338.983;Float;False;Property;_Parallax;Height Map Height;15;0;Create;False;0;0;False;0;0.02;0.08;0.005;0.08;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;266.5363,-1001.434;Float;False;Constant;_pointfourtwo;point four two;23;0;Create;True;0;0;False;0;0.42;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;43;265.6467,-1179.147;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;554.5877,-1027.279;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;647.1903,-1418.777;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;47;706.8519,-1206.578;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;888.6124,-1329.033;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;623.8512,327.5269;Float;False;80;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1474.005,1257.602;Float;False;Property;_SrcBlend;Src Blend;13;0;Fetch;False;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;81;-85.61623,441.638;Float;False;glossiness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1460.246,348.558;Float;False;Property;_Metallic;Metallic;17;0;Create;False;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1443.47,186.0185;Float;False;Property;_SmoothnessTextureChannel;Smoothness Texture Channel;18;0;Create;False;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-103.908,331.8875;Float;False;metaillic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1526.347,280.5273;Float;False;Property;_SpecularHighlights;SpecularHighlights;19;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;100;629.2191,399.9944;Float;False;81;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;434.7177,-290.8657;Float;False;emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1436.216,1473.967;Float;False;Property;_ZWrite;Z Write;20;0;Create;False;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1668.48,1049.514;Float;False;Property;_Cutoff;Cutoff;10;0;Fetch;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;634.5872,205.4057;Float;False;53;0;1;COLOR;0
Node;AmplifyShaderEditor.Vector4Node;61;-1798.574,-1170.255;Float;False;Constant;_ColorSpaceDoubleGamma;Color Space Double (Gamma);23;0;Create;True;0;0;False;0;2,2,2,2;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;29;-1436.201,1340.479;Float;False;Property;_UVSec;UV Sec;12;0;Fetch;False;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;91;-553.2823,713.5972;Float;False;ao;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-618.4382,-1535.406;Float;False;albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;638.6132,127.5702;Float;False;74;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;46;441.4723,-1219.023;Float;False;FLOAT2;0;1;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-1447.832,1189.265;Float;False;Property;_DstBlend;Dst Blend;14;0;Fetch;False;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;639.9551,485.8819;Float;False;91;0;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;8;190.3974,-1606.566;Float;True;Property;_ParallaxMap;Height Map;3;1;[NoScaleOffset];Create;False;0;0;False;0;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;96;668.137,41.68275;Float;False;52;0;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;39;323.0179,-1414.638;Float;False;Constant;_pointfive;point five;23;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;74;-980.4988,-264.7262;Float;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;962.4502,209.9712;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/Farl/Custom Standard;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;88;0;85;0
WireConnection;88;1;86;0
WireConnection;87;0;88;0
WireConnection;13;1;94;0
WireConnection;11;1;37;0
WireConnection;64;0;35;0
WireConnection;64;1;65;0
WireConnection;58;0;11;4
WireConnection;12;1;36;0
WireConnection;12;5;21;0
WireConnection;60;0;13;0
WireConnection;60;1;62;0
WireConnection;6;1;89;0
WireConnection;71;0;12;0
WireConnection;4;1;64;0
WireConnection;4;5;16;0
WireConnection;2;1;94;0
WireConnection;15;1;92;0
WireConnection;55;0;57;0
WireConnection;55;1;60;0
WireConnection;55;2;59;0
WireConnection;72;0;4;0
WireConnection;72;1;71;0
WireConnection;72;2;73;0
WireConnection;76;0;6;4
WireConnection;76;1;23;0
WireConnection;78;0;6;1
WireConnection;10;1;90;0
WireConnection;34;0;32;0
WireConnection;34;1;15;0
WireConnection;33;0;31;0
WireConnection;33;1;2;0
WireConnection;33;2;55;0
WireConnection;44;0;43;0
WireConnection;38;0;8;2
WireConnection;38;1;39;0
WireConnection;43;0;41;0
WireConnection;45;0;44;0
WireConnection;45;1;42;0
WireConnection;40;0;38;0
WireConnection;40;1;25;0
WireConnection;47;0;46;0
WireConnection;47;1;45;0
WireConnection;48;0;40;0
WireConnection;48;1;47;0
WireConnection;81;0;76;0
WireConnection;80;0;78;0
WireConnection;53;0;34;0
WireConnection;91;0;10;0
WireConnection;52;0;33;0
WireConnection;46;0;43;0
WireConnection;8;1;93;0
WireConnection;74;0;72;0
WireConnection;0;0;96;0
WireConnection;0;1;97;0
WireConnection;0;2;98;0
WireConnection;0;3;99;0
WireConnection;0;4;100;0
WireConnection;0;5;101;0
ASEEND*/
//CHKSM=ADBB2C5E140222DBCB9F14FD3BBC45068DBF1DDC