// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifyGPUParticle"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
		_SpaceScale("Space Scale", Float) = 0
		[HideInInspector]_PositionBuffer("_PositionBuffer", 2D) = "white" {}
		[HDR]_Color("Color", Color) = (1,1,1,0.907)
		_ParticleScale("Particle Scale", Float) = 0
		[HDR]_ColorDeep("Color Deep", Color) = (1,1,1,1)
		_DeepTex("Deep Tex", 2D) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Off
		ZWrite Off
		Blend One One
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog noforwardadd vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float2 uv2_texcoord2;
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
		uniform sampler2D _DeepTex;
		uniform float _SpaceScale;
		uniform sampler2D _PositionBuffer;
		uniform float4 _PositionBuffer_TexelSize;
		uniform float4 _ColorDeep;
		uniform float4 _Color;
		uniform float _ParticleScale;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float2 uv2_TexCoord12 = v.texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
			float4 appendResult6 = (float4(( uv2_TexCoord12 * _SpaceScale ).x , tex2Dlod( _PositionBuffer, float4( ( uv2_TexCoord12 * (_PositionBuffer_TexelSize).xy ), 0, 0) ).g , ( uv2_TexCoord12 * _SpaceScale ).y , 0));
			float4 particlePos77 = appendResult6;
			float4 appendResult55 = (float4(( ( ase_vertex3Pos * _ParticleScale * ( abs( ( (particlePos77).y - 0.5 ) ) * 2 ) ).x * length( (float4( unity_ObjectToWorld[0][0],unity_ObjectToWorld[1][0],unity_ObjectToWorld[2][0],unity_ObjectToWorld[3][0] )).xyz ) ) , ( ( ase_vertex3Pos * _ParticleScale * ( abs( ( (particlePos77).y - 0.5 ) ) * 2 ) ).y * length( (float4( unity_ObjectToWorld[0][1],unity_ObjectToWorld[1][1],unity_ObjectToWorld[2][1],unity_ObjectToWorld[3][1] )).xyz ) ) , ( ( ase_vertex3Pos * _ParticleScale * ( abs( ( (particlePos77).y - 0.5 ) ) * 2 ) ).z * length( (float4( unity_ObjectToWorld[0][2],unity_ObjectToWorld[1][2],unity_ObjectToWorld[2][2],unity_ObjectToWorld[3][2] )).xyz ) ) , 0));
			float3 normalizeResult30 = normalize( (UNITY_MATRIX_V[0]).xyz );
			float3 camRight46 = normalizeResult30;
			float3 normalizeResult35 = normalize( (UNITY_MATRIX_V[1]).xyz );
			float3 camUp37 = normalizeResult35;
			float3 normalizeResult27 = normalize( (UNITY_MATRIX_V[2]).xyz );
			float3 camForward36 = -normalizeResult27;
			float4x4 camMatrix52 = float4x4(float4( camRight46 , 0.0 ), float4( camUp37 , 0.0 ), float4( camForward36 , 0.0 ), float4(0,0,0,1));
			float4 appendResult57 = (float4(particlePos77));
			float4 vertexPosF65 = mul( unity_WorldToObject, ( mul( appendResult55, camMatrix52 ) + appendResult57 ) );
			v.vertex.xyz += ( vertexPosF65 - float4( ase_vertex3Pos , 0.0 ) ).xyz;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_TexCoord1 = i.uv_texcoord * float2( 1,1 ) + float2( 0,0 );
			float4 tex2DNode3 = tex2D( _MainTex, uv_TexCoord1 );
			float2 uv2_TexCoord12 = i.uv2_texcoord2 * float2( 1,1 ) + float2( 0,0 );
			float4 appendResult6 = (float4(( uv2_TexCoord12 * _SpaceScale ).x , tex2D( _PositionBuffer, ( uv2_TexCoord12 * (_PositionBuffer_TexelSize).xy ) ).g , ( uv2_TexCoord12 * _SpaceScale ).y , 0));
			float4 particlePos77 = appendResult6;
			float temp_output_90_0 = (0 + ((particlePos77).y - 0) * (1 - 0) / (1 - 0));
			float4 lerpResult100 = lerp( tex2D( _DeepTex, uv_TexCoord1 ) , tex2DNode3 , temp_output_90_0);
			float4 lerpResult86 = lerp( _ColorDeep , _Color , temp_output_90_0);
			c.rgb = ( lerpResult100 * lerpResult86 * (lerpResult100).a ).rgb;
			c.a = tex2DNode3.a;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
322;251;956;488;1891.383;1302.471;3.134542;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;14;-1016.192,626.4897;Float;True;Property;_PositionBuffer;_PositionBuffer;3;1;[HideInInspector];Create;False;0;0;True;0;None;;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexelSizeNode;13;-730.1116,655.871;Float;False;-1;1;0;SAMPLER2D;;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-1034.13,477.3397;Float;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;16;-501.2478,581.6448;Float;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-692.6576,388.5776;Float;False;Property;_SpaceScale;Space Scale;2;0;Create;True;0;0;False;0;0;-0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-300.2186,519.7897;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-527.1154,324.6842;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;5;-383.3555,317.4236;Float;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SamplerNode;15;-151.8455,488.1285;Float;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;6;160.466,298.8671;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-4065.834,303.929;Float;False;77;0;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;300.3558,177.4055;Float;False;particlePos;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ViewMatrixNode;18;-3348.814,-1090.637;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.ComponentMaskNode;94;-3888.312,298.7789;Float;False;False;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;19;-3146.814,-1043.637;Float;False;Row;2;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;102;-3666.713,304.6229;Float;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;23;-3564.608,574.3627;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;21;-3147.052,-1204.966;Float;False;Row;1;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;20;-2955.566,-1040.975;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;22;-3145.485,-878.3079;Float;False;Row;0;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;103;-3499.032,315.1763;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;81;-3518.753,76.37157;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;26;-2957.712,-886.4694;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;27;-2743.295,-1036.351;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;29;-3238.212,794.2053;Float;False;Column;2;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;25;-2946.983,-1195.48;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;24;-3238.212,625.7964;Float;False;Column;1;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;85;-3532.475,223.9088;Float;False;Property;_ParticleScale;Particle Scale;5;0;Create;True;0;0;False;0;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;28;-3238.212,447.6718;Float;False;Column;0;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleNode;104;-3367.701,302.2776;Float;False;2;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;34;-2553.285,-1052.037;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;32;-3057.179,818.8634;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;31;-3054.678,643.3674;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;35;-2728.778,-1199.67;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-3206.583,198.1551;Float;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;33;-3068.882,456.069;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;30;-2730.592,-873.0322;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-2515.737,-1200.397;Float;False;camUp;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LengthOpNode;38;-2849.14,810.8983;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-2412.931,-1049.538;Float;False;camForward;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;69;-2951.113,272.5438;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;42;-3177.602,-434.1165;Float;False;36;0;1;FLOAT3;0
Node;AmplifyShaderEditor.LengthOpNode;41;-2842.269,664.3153;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;45;-3153.175,-351.3144;Float;False;Constant;_Vector0;Vector 0;1;0;Create;True;0;0;False;0;0,0,0,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-2545.66,-875.9075;Float;False;camRight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LengthOpNode;40;-2844.559,460.4733;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-3165.561,-533.4485;Float;False;37;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-3168.572,-622.2451;Float;False;46;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-2638.427,820.0593;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-2652.169,451.3119;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.MatrixFromVectors;47;-2930.751,-534.9535;Float;False;FLOAT4x4;4;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-2652.169,673.4763;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-2467.432,757.4653;Float;False;52;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-622.2754,-273.4846;Float;False;77;0;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-2694.054,-529.0805;Float;False;camMatrix;-1;True;1;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4x4;0
Node;AmplifyShaderEditor.DynamicAppendNode;55;-2452.908,599.5394;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;-2620.41,1131.09;Float;False;77;0;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;57;-2315.685,981.1664;Float;False;FLOAT4;4;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;91;-444.5717,-274.885;Float;False;False;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-2223.872,569.7648;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-723.5569,-605.6087;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-296.9369,-820.2461;Float;True;Property;_MainTex;Main Tex;1;0;Create;False;0;0;False;0;None;0000000000000000f000000000000000;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;90;-241.0489,-271.4846;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectMatrix;62;-2110.798,489.7236;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SamplerNode;99;-299.2669,-1034.011;Float;True;Property;_DeepTex;Deep Tex;7;0;Create;True;0;0;False;0;None;0000000000000000f000000000000000;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-2068.128,665.9594;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-1834.512,652.7334;Float;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;87;-254.4933,-614.7327;Float;False;Property;_ColorDeep;Color Deep;6;1;[HDR];Create;True;0;0;False;0;1,1,1,1;1,0,0,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;100;56.48161,-1050.752;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;83;-267.902,-446.601;Float;False;Property;_Color;Color;4;1;[HDR];Create;True;0;0;False;0;1,1,1,0.907;0,0.2997569,1.010809,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;86;-10.37775,-523.7294;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-300.2268,-105.5619;Float;False;65;0;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;101;217.6147,-948.2126;Float;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;72;-340.29,-22.35384;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-1660.444,659.6044;Float;False;vertexPosF;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FractNode;2;-466.6407,-447.3485;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;-2583.301,37.20233;Float;False;vertexN;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;70;331.4432,300.9841;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalVertexDataNode;58;-3131.883,-67.53606;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;498.6661,289.0172;Float;False;vertexPos0;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;127.9223,-19.01729;Float;False;66;0;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;53;-3046.793,981.1674;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;74;-71.1901,-84.22168;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;49;-3233.529,975.8813;Float;False;Column;3;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;79;-3175.736,332.0884;Float;False;67;0;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-2901.587,50.78143;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;71;161.4809,463.3627;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;403.3872,-698.2858;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalizeNode;64;-2742.776,52.46783;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;-3142.191,107.879;Float;False;52;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;379.321,-505.2736;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Custom/Farl/Amplify/AmplifyGPUParticle;False;False;False;False;True;True;True;True;True;True;False;True;False;False;True;False;False;False;False;Off;2;False;-1;0;False;-1;False;0;0;False;0;Custom;0.5;True;False;0;True;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;4;One;One;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;13;0;14;0
WireConnection;16;0;13;0
WireConnection;17;0;12;0
WireConnection;17;1;16;0
WireConnection;10;0;12;0
WireConnection;10;1;11;0
WireConnection;5;0;10;0
WireConnection;15;0;14;0
WireConnection;15;1;17;0
WireConnection;6;0;5;0
WireConnection;6;1;15;2
WireConnection;6;2;5;1
WireConnection;77;0;6;0
WireConnection;94;0;92;0
WireConnection;19;0;18;0
WireConnection;102;0;94;0
WireConnection;21;0;18;0
WireConnection;20;0;19;0
WireConnection;22;0;18;0
WireConnection;103;0;102;0
WireConnection;26;0;22;0
WireConnection;27;0;20;0
WireConnection;29;0;23;0
WireConnection;25;0;21;0
WireConnection;24;0;23;0
WireConnection;28;0;23;0
WireConnection;104;0;103;0
WireConnection;34;0;27;0
WireConnection;32;0;29;0
WireConnection;31;0;24;0
WireConnection;35;0;25;0
WireConnection;84;0;81;0
WireConnection;84;1;85;0
WireConnection;84;2;104;0
WireConnection;33;0;28;0
WireConnection;30;0;26;0
WireConnection;37;0;35;0
WireConnection;38;0;32;0
WireConnection;36;0;34;0
WireConnection;69;0;84;0
WireConnection;41;0;31;0
WireConnection;46;0;30;0
WireConnection;40;0;33;0
WireConnection;48;0;69;2
WireConnection;48;1;38;0
WireConnection;50;0;69;0
WireConnection;50;1;40;0
WireConnection;47;0;43;0
WireConnection;47;1;44;0
WireConnection;47;2;42;0
WireConnection;47;3;45;0
WireConnection;51;0;69;1
WireConnection;51;1;41;0
WireConnection;52;0;47;0
WireConnection;55;0;50;0
WireConnection;55;1;51;0
WireConnection;55;2;48;0
WireConnection;57;0;78;0
WireConnection;91;0;89;0
WireConnection;59;0;55;0
WireConnection;59;1;54;0
WireConnection;3;1;1;0
WireConnection;90;0;91;0
WireConnection;99;1;1;0
WireConnection;61;0;59;0
WireConnection;61;1;57;0
WireConnection;63;0;62;0
WireConnection;63;1;61;0
WireConnection;100;0;99;0
WireConnection;100;1;3;0
WireConnection;100;2;90;0
WireConnection;86;0;87;0
WireConnection;86;1;83;0
WireConnection;86;2;90;0
WireConnection;101;0;100;0
WireConnection;65;0;63;0
WireConnection;2;0;1;0
WireConnection;66;0;64;0
WireConnection;70;0;6;0
WireConnection;70;1;71;0
WireConnection;67;0;70;0
WireConnection;53;0;49;0
WireConnection;74;0;73;0
WireConnection;74;1;72;0
WireConnection;49;0;23;0
WireConnection;60;0;58;0
WireConnection;60;1;56;0
WireConnection;82;0;100;0
WireConnection;82;1;86;0
WireConnection;82;2;101;0
WireConnection;64;0;60;0
WireConnection;0;9;3;4
WireConnection;0;13;82;0
WireConnection;0;11;74;0
ASEEND*/
//CHKSM=6867ACFB90E54AD7CA8C2ED65162C2FBFE4FFBD9