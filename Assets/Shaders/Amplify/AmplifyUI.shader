// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/AmplifyUI"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
		_BumpTex("Normal Map", 2D) = "bump" {}
		_FresnelScale("Fresnel Scale", Float) = 0
		_FresnelPower("Fresnel Power", Float) = 1
		_TangentSpaceLightDir("Tangent Space Light Dir", Vector) = (0,0,0,0)
		_SpecularShininess("Specular Shininess", Float) = 0.01
		_Specular("Specular", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }
		
		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp] 
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		
		Pass
		{
			Name "Default"
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_ALPHACLIP
			
			
			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_tangent : TANGENT;
				float3 ase_normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
			};
			
			uniform fixed4 _Color;
			uniform fixed4 _TextureSampleAdd;
			uniform float4 _ClipRect;
			uniform sampler2D _MainTex;
			uniform float3 _TangentSpaceLightDir;
			uniform sampler2D _BumpTex;
			uniform float4 _BumpTex_ST;
			uniform float _SpecularShininess;
			uniform float4 _Specular;
			uniform float _FresnelScale;
			uniform float _FresnelPower;
			uniform float4 _MainTex_ST;
			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				OUT.worldPosition = IN.vertex;
				float3 ase_worldPos = mul(unity_ObjectToWorld, IN.vertex).xyz;
				float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir(ase_worldPos) );
				OUT.ase_texcoord2.xyz = ase_worldViewDir;
				float3 ase_worldTangent = UnityObjectToWorldDir(IN.ase_tangent);
				OUT.ase_texcoord3.xyz = ase_worldTangent;
				float3 ase_worldNormal = UnityObjectToWorldNormal(IN.ase_normal);
				OUT.ase_texcoord4.xyz = ase_worldNormal;
				float ase_vertexTangentSign = IN.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				OUT.ase_texcoord5.xyz = ase_worldBitangent;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				OUT.ase_texcoord2.w = 0;
				OUT.ase_texcoord3.w = 0;
				OUT.ase_texcoord4.w = 0;
				OUT.ase_texcoord5.w = 0;
				
				OUT.worldPosition.xyz +=  float3( 0, 0, 0 ) ;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

				OUT.texcoord = IN.texcoord;
				
				OUT.color = IN.color * _Color;
				return OUT;
			}

			fixed4 frag(v2f IN  ) : SV_Target
			{
				float3 ase_worldViewDir = IN.ase_texcoord2.xyz;
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldTangent = IN.ase_texcoord3.xyz;
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3x3 worldToTanMat = float3x3(ase_worldTangent,ase_worldBitangent,ase_worldNormal);
				float3 temp_output_93_0 = mul( ase_worldViewDir, worldToTanMat );
				float3 normalizeResult95 = normalize( ( _TangentSpaceLightDir + temp_output_93_0 ) );
				float2 uv_BumpTex = IN.texcoord.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;
				float3 tex2DNode54 = UnpackNormal( tex2D( _BumpTex, uv_BumpTex ) );
				float dotResult97 = dot( normalizeResult95 , tex2DNode54 );
				float3 normalizeResult85 = normalize( temp_output_93_0 );
				float dotResult74 = dot( normalizeResult85 , tex2DNode54 );
				float2 uv_MainTex = IN.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 temp_output_48_0 = ( tex2D( _MainTex, uv_MainTex ) * IN.color );
				float4 appendResult35 = (float4(( ( pow( max( dotResult97 , 0 ) , ( _SpecularShininess * 128 ) ) * _Specular ) + float4( (pow( ( saturate( -dotResult74 ) * _FresnelScale ) , _FresnelPower )).xxx , 0.0 ) ).rgb , (temp_output_48_0).a));
				
				half4 color = appendResult35;
				
				color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
				
				#ifdef UNITY_UI_ALPHACLIP
				clip (color.a - 0.001);
				#endif

				return color;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
454;383;707;491;-363.2551;738.6396;2.242692;True;False
Node;AmplifyShaderEditor.WorldToTangentMatrix;90;72.48377,-1324.716;Float;False;0;1;FLOAT3x3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;84;61.70888,-1574.148;Float;False;World;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;307.1958,-1472.205;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;94;352.1459,-1709.086;Float;False;Property;_TangentSpaceLightDir;Tangent Space Light Dir;5;0;Create;True;0;0;False;0;0,0,0;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;85;557.0568,-1300.297;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;54;347.9902,-1110.546;Float;True;Property;_BumpTex;Normal Map;1;0;Create;False;0;0;False;0;None;00e0021f9f2d77a4fb3d5957267488e7;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;74;765.4892,-1158.631;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;96;663.7026,-1507.088;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;77;831.0357,-1026.865;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;95;831.4637,-1501.952;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;97;1023.26,-1495.105;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;848.1157,-703.4259;Float;False;Property;_FresnelScale;Fresnel Scale;3;0;Create;True;0;0;False;0;0;0.59;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;76;950.7946,-1118.371;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;1059.208,-1298.243;Float;False;Property;_SpecularShininess;Specular Shininess;6;0;Create;True;0;0;False;0;0.01;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;1311.215,-1338.081;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;128;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;98;1218.41,-1450.597;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;834.1612,-630.7443;Float;False;Property;_FresnelPower;Fresnel Power;4;0;Create;True;0;0;False;0;1;3.19;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;29;-193.9287,-128.6542;Float;False;0;0;_MainTex;Shader;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;1183.764,-1118.87;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;30;5.91412,-162.2885;Float;True;Property;_TextureSample0;Texture Sample 0;6;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;104;1340.263,-1246.219;Float;False;Property;_Specular;Specular;7;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;99;1458.069,-1455.733;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;87;1197.912,-966.418;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;47;305.259,-56.10217;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;78;1051.837,-595.7069;Float;False;FLOAT3;0;0;0;0;1;0;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;1623.852,-1286.753;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;468.1928,-147.3451;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;102;1288.379,-406.4624;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;52;652.8151,-82.14603;Float;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;38;172.0927,183.0815;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CrossProductOpNode;41;606.7461,234.4691;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DdyOpNode;40;416.1837,264.4453;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;79;1162.817,-800.6407;Float;False;Tangent;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;50;797.276,-240.3657;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;49;544.6641,27.9746;Float;False;Property;_Lighting;Lighting;0;0;Create;True;0;0;False;0;0;0.03;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;860.525,-784.9709;Float;False;Property;_FresnelBias;Fresnel Bias;2;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;53;824.4117,482.9384;Float;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LightColorNode;28;158.7425,-386.0362;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;35;1124.368,-6.945897;Float;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DdxOpNode;39;403.3369,146.682;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;43;1011.424,307.2682;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;80;678.8885,-873.6069;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;825.1434,270.8687;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1E-09,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendOpsNode;31;502.489,-349.5239;Float;False;HardLight;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;27;1467.314,-28.67455;Float;False;True;2;Float;ASEMaterialInspector;0;3;Custom/Farl/AmplifyUI;5056123faa0c79b47ab6ad7e8bf059a4;0;0;Default;2;True;2;SrcAlpha;OneMinusSrcAlpha;0;One;Zero;False;True;Off;False;False;False;False;False;True;5;Queue=Transparent;IgnoreProjector=True;RenderType=Transparent;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;0;0;False;False;False;False;False;False;False;False;False;True;2;0;0;0;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;93;0;84;0
WireConnection;93;1;90;0
WireConnection;85;0;93;0
WireConnection;74;0;85;0
WireConnection;74;1;54;0
WireConnection;96;0;94;0
WireConnection;96;1;93;0
WireConnection;77;0;74;0
WireConnection;95;0;96;0
WireConnection;97;0;95;0
WireConnection;97;1;54;0
WireConnection;76;0;77;0
WireConnection;100;0;101;0
WireConnection;98;0;97;0
WireConnection;88;0;76;0
WireConnection;88;1;82;0
WireConnection;30;0;29;0
WireConnection;99;0;98;0
WireConnection;99;1;100;0
WireConnection;87;0;88;0
WireConnection;87;1;83;0
WireConnection;78;0;87;0
WireConnection;103;0;99;0
WireConnection;103;1;104;0
WireConnection;48;0;30;0
WireConnection;48;1;47;0
WireConnection;102;0;103;0
WireConnection;102;1;78;0
WireConnection;52;0;48;0
WireConnection;41;0;39;0
WireConnection;41;1;40;0
WireConnection;40;0;38;0
WireConnection;79;0;80;0
WireConnection;79;1;81;0
WireConnection;79;2;82;0
WireConnection;79;3;83;0
WireConnection;50;0;48;0
WireConnection;50;1;31;0
WireConnection;50;2;49;0
WireConnection;35;0;102;0
WireConnection;35;3;52;0
WireConnection;39;0;38;0
WireConnection;43;0;42;0
WireConnection;42;0;41;0
WireConnection;31;0;28;0
WireConnection;31;1;48;0
WireConnection;27;0;35;0
ASEEND*/
//CHKSM=D3F015A0C6F0A13C413087CBA76D567FA0681093