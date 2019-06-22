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
		_HeightScale("Height Scale", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
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

		uniform sampler2D _DeepTex;
		uniform sampler2D _MainTex;
		uniform float _SpaceScale;
		uniform float _HeightScale;
		uniform sampler2D _PositionBuffer;
		uniform float4 _PositionBuffer_TexelSize;
		uniform float4 _ColorDeep;
		uniform float4 _Color;
		uniform float _ParticleScale;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 appendResult117 = (float3(_SpaceScale , _HeightScale , _SpaceScale));
			float2 uv2_TexCoord12 = v.texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
			float4 temp_cast_1 = (0.5).xxxx;
			float4 particlePos77 = ( float4( appendResult117 , 0.0 ) * ( ( tex2Dlod( _PositionBuffer, float4( ( uv2_TexCoord12 * (_PositionBuffer_TexelSize).xy ), 0, 0) ) - temp_cast_1 ) * 5.0 * 2.0 ) );
			float heightFactor135 = saturate( ( (particlePos77).g + 0.5 ) );
			float4 appendResult55 = (float4(( ( ase_vertex3Pos * _ParticleScale * (abs( ( heightFactor135 - 0.5 ) )*2 + 0.1) ).x * length( (float4( unity_ObjectToWorld[0][0],unity_ObjectToWorld[1][0],unity_ObjectToWorld[2][0],unity_ObjectToWorld[3][0] )).xyz ) ) , ( ( ase_vertex3Pos * _ParticleScale * (abs( ( heightFactor135 - 0.5 ) )*2 + 0.1) ).y * length( (float4( unity_ObjectToWorld[0][1],unity_ObjectToWorld[1][1],unity_ObjectToWorld[2][1],unity_ObjectToWorld[3][1] )).xyz ) ) , ( ( ase_vertex3Pos * _ParticleScale * (abs( ( heightFactor135 - 0.5 ) )*2 + 0.1) ).z * length( (float4( unity_ObjectToWorld[0][2],unity_ObjectToWorld[1][2],unity_ObjectToWorld[2][2],unity_ObjectToWorld[3][2] )).xyz ) ) , 0));
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
			float3 appendResult117 = (float3(_SpaceScale , _HeightScale , _SpaceScale));
			float2 uv2_TexCoord12 = i.uv2_texcoord2 * float2( 1,1 ) + float2( 0,0 );
			float4 temp_cast_1 = (0.5).xxxx;
			float4 particlePos77 = ( float4( appendResult117 , 0.0 ) * ( ( tex2D( _PositionBuffer, ( uv2_TexCoord12 * (_PositionBuffer_TexelSize).xy ) ) - temp_cast_1 ) * 5.0 * 2.0 ) );
			float heightFactor135 = saturate( ( (particlePos77).g + 0.5 ) );
			float4 lerpResult100 = lerp( tex2D( _DeepTex, uv_TexCoord1 ) , tex2D( _MainTex, uv_TexCoord1 ) , heightFactor135);
			float temp_output_101_0 = (lerpResult100).a;
			float4 lerpResult86 = lerp( _ColorDeep , _Color , heightFactor135);
			c.rgb = ( lerpResult100 * lerpResult86 * temp_output_101_0 ).rgb;
			c.a = temp_output_101_0;
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
405;412;956;488;3955.016;-63.49246;1;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;14;-1009.669,394.9039;Float;True;Property;_PositionBuffer;_PositionBuffer;3;1;[HideInInspector];Create;False;0;0;True;0;None;;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexelSizeNode;13;-735.2711,640.7098;Float;False;-1;1;0;SAMPLER2D;;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-742.5923,487.209;Float;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;16;-501.2478,581.6448;Float;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-300.2186,519.7897;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-40.9349,644.7968;Float;False;Constant;_Float0;Float 0;10;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;15;-151.8455,441.3689;Float;True;Property;_TextureSample0;Texture Sample 0;4;0;Create;True;0;0;False;0;None;None;True;1;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;128;134.7296,638.6833;Float;False;Constant;_Float1;Float 1;10;0;Create;True;0;0;False;0;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;136.0144,743.5745;Float;False;Constant;_Float2;Float 2;10;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;54.88067,220.3928;Float;False;Property;_SpaceScale;Space Scale;2;0;Create;True;0;0;False;0;0;-6.19;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;118;55.80227,302.2328;Float;False;Property;_HeightScale;Height Scale;8;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;126;153.7285,457.6499;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;301.8042,485.7064;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;117;292.2807,206.0104;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;571.7026,397.3521;Float;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-450.2401,1022.283;Float;False;77;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;788.5532,381.4;Float;False;particlePos;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;133;-261.6049,1105.415;Float;False;Constant;_Float3;Float 3;9;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;91;-270.8977,1020.883;Float;False;False;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;132;-24.24,1039.98;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;134;113.4208,1039.98;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;135;300.9972,1030.724;Float;False;heightFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewMatrixNode;18;-3348.814,-1090.637;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-3891.834,295.929;Float;False;135;0;1;FLOAT;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;19;-3146.814,-1043.637;Float;False;Row;2;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;102;-3707.713,299.6229;Float;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;22;-3145.485,-878.3079;Float;False;Row;0;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VectorFromMatrixNode;21;-3147.052,-1204.966;Float;False;Row;1;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;20;-2955.566,-1040.975;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.AbsOpNode;103;-3572.032,308.1763;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;23;-3564.608,574.3627;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-3532.475,223.9088;Float;False;Property;_ParticleScale;Particle Scale;5;0;Create;True;0;0;False;0;0;0.61;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;29;-3238.212,794.2053;Float;False;Column;2;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VectorFromMatrixNode;24;-3238.212,625.7964;Float;False;Column;1;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;27;-2743.295,-1036.351;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;28;-3238.212,447.6718;Float;False;Column;0;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;25;-2946.983,-1195.48;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;26;-2957.712,-886.4694;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;81;-3518.753,76.37157;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;139;-3424.016,312.4925;Float;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;32;-3057.179,818.8634;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;35;-2728.778,-1199.67;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;30;-2730.592,-873.0322;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;33;-3068.882,456.069;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;31;-3054.678,643.3674;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;34;-2553.285,-1052.037;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-3206.583,198.1551;Float;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-2412.931,-1049.538;Float;False;camForward;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;-3177.602,-434.1165;Float;False;36;0;1;FLOAT3;0
Node;AmplifyShaderEditor.LengthOpNode;41;-2842.269,664.3153;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;69;-2951.113,272.5438;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;44;-3165.561,-533.4485;Float;False;37;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-2545.66,-875.9075;Float;False;camRight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;45;-3153.175,-351.3144;Float;False;Constant;_Vector0;Vector 0;1;0;Create;True;0;0;False;0;0,0,0,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-2515.737,-1200.397;Float;False;camUp;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LengthOpNode;38;-2849.14,810.8983;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-3168.572,-622.2451;Float;False;46;0;1;FLOAT3;0
Node;AmplifyShaderEditor.LengthOpNode;40;-2844.559,460.4733;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-2638.427,820.0593;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.MatrixFromVectors;47;-2930.751,-534.9535;Float;False;FLOAT4x4;4;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-2652.169,451.3119;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-2652.169,673.4763;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-2467.432,757.4653;Float;False;52;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.DynamicAppendNode;55;-2452.908,599.5394;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;-2620.41,1131.09;Float;False;77;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-2694.054,-529.0805;Float;False;camMatrix;-1;True;1;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-2223.872,569.7648;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;57;-2315.685,981.1664;Float;False;FLOAT4;4;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-723.5569,-605.6087;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-2068.128,665.9594;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldToObjectMatrix;62;-2110.798,489.7236;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.GetLocalVarNode;137;-268.3605,-814.2112;Float;False;135;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-345.699,-1015.294;Float;True;Property;_MainTex;Main Tex;1;0;Create;False;0;0;False;0;None;56277f370fb77a448a152bcd2e3a9077;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;99;-335.4901,-1225.87;Float;True;Property;_DeepTex;Deep Tex;7;0;Create;True;0;0;False;0;None;95b6b0f4a804a40a89a6fccd6055468f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;136;-260.0012,-346.0955;Float;False;135;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;87;-265.6389,-709.4704;Float;False;Property;_ColorDeep;Color Deep;6;1;[HDR];Create;True;0;0;False;0;1,1,1,1;1,0,0,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-1834.512,652.7334;Float;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;83;-266.5088,-524.6203;Float;False;Property;_Color;Color;4;1;[HDR];Create;True;0;0;False;0;1,1,1,0.907;0,0.2997563,1.010809,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;100;56.48161,-1050.752;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;130;361.9235,-1002.75;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;86;-10.37775,-523.7294;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;72;-340.29,-22.35384;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;101;140.3381,-855.8166;Float;True;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-1660.444,659.6044;Float;False;vertexPosF;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-300.2268,-105.5619;Float;False;65;0;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;421.8664,-699.9658;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;1200.132,477.4779;Float;False;vertexPos0;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;-3175.736,332.0884;Float;False;67;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;-2583.301,37.20233;Float;False;vertexN;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;58;-3131.883,-67.53606;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;74;-71.1901,-84.22168;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;-3142.191,107.879;Float;False;52;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;127.9223,-19.01729;Float;False;66;0;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;53;-3046.793,981.1674;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;71;824.3629,527.0579;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;64;-2742.776,52.46783;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-2901.587,50.78143;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;70;1050.479,446.9844;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;49;-3233.529,975.8813;Float;False;Column;3;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;627.153,-516.1844;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Custom/Farl/Amplify/AmplifyGPUParticle;False;False;False;False;True;True;True;True;True;True;False;True;False;False;True;False;False;False;False;Off;2;False;-1;0;False;-1;False;0;0;False;0;Custom;0.5;True;False;0;True;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;4;One;One;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;13;0;14;0
WireConnection;16;0;13;0
WireConnection;17;0;12;0
WireConnection;17;1;16;0
WireConnection;15;0;14;0
WireConnection;15;1;17;0
WireConnection;126;0;15;0
WireConnection;126;1;127;0
WireConnection;125;0;126;0
WireConnection;125;1;128;0
WireConnection;125;2;129;0
WireConnection;117;0;11;0
WireConnection;117;1;118;0
WireConnection;117;2;11;0
WireConnection;10;0;117;0
WireConnection;10;1;125;0
WireConnection;77;0;10;0
WireConnection;91;0;89;0
WireConnection;132;0;91;0
WireConnection;132;1;133;0
WireConnection;134;0;132;0
WireConnection;135;0;134;0
WireConnection;19;0;18;0
WireConnection;102;0;92;0
WireConnection;22;0;18;0
WireConnection;21;0;18;0
WireConnection;20;0;19;0
WireConnection;103;0;102;0
WireConnection;29;0;23;0
WireConnection;24;0;23;0
WireConnection;27;0;20;0
WireConnection;28;0;23;0
WireConnection;25;0;21;0
WireConnection;26;0;22;0
WireConnection;139;0;103;0
WireConnection;32;0;29;0
WireConnection;35;0;25;0
WireConnection;30;0;26;0
WireConnection;33;0;28;0
WireConnection;31;0;24;0
WireConnection;34;0;27;0
WireConnection;84;0;81;0
WireConnection;84;1;85;0
WireConnection;84;2;139;0
WireConnection;36;0;34;0
WireConnection;41;0;31;0
WireConnection;69;0;84;0
WireConnection;46;0;30;0
WireConnection;37;0;35;0
WireConnection;38;0;32;0
WireConnection;40;0;33;0
WireConnection;48;0;69;2
WireConnection;48;1;38;0
WireConnection;47;0;43;0
WireConnection;47;1;44;0
WireConnection;47;2;42;0
WireConnection;47;3;45;0
WireConnection;50;0;69;0
WireConnection;50;1;40;0
WireConnection;51;0;69;1
WireConnection;51;1;41;0
WireConnection;55;0;50;0
WireConnection;55;1;51;0
WireConnection;55;2;48;0
WireConnection;52;0;47;0
WireConnection;59;0;55;0
WireConnection;59;1;54;0
WireConnection;57;0;78;0
WireConnection;61;0;59;0
WireConnection;61;1;57;0
WireConnection;3;1;1;0
WireConnection;99;1;1;0
WireConnection;63;0;62;0
WireConnection;63;1;61;0
WireConnection;100;0;99;0
WireConnection;100;1;3;0
WireConnection;100;2;137;0
WireConnection;130;0;100;0
WireConnection;86;0;87;0
WireConnection;86;1;83;0
WireConnection;86;2;136;0
WireConnection;101;0;100;0
WireConnection;65;0;63;0
WireConnection;82;0;130;0
WireConnection;82;1;86;0
WireConnection;82;2;101;0
WireConnection;67;0;70;0
WireConnection;66;0;64;0
WireConnection;74;0;73;0
WireConnection;74;1;72;0
WireConnection;53;0;49;0
WireConnection;64;0;60;0
WireConnection;60;0;58;0
WireConnection;60;1;56;0
WireConnection;70;0;77;0
WireConnection;70;1;71;0
WireConnection;49;0;23;0
WireConnection;0;9;101;0
WireConnection;0;13;82;0
WireConnection;0;11;74;0
ASEEND*/
//CHKSM=B6310D183BFC01A575B4CD63D0003E659887FB02