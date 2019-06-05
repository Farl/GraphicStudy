// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifyConeFog"
{
	Properties
	{
		_Scale("Scale", Vector) = (1,1,1,0)
		_Offset("Offset", Vector) = (0,0,0,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Off
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha noshadow noforwardadd 
		struct Input
		{
			float3 worldPos;
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

		uniform float3 _Offset;
		uniform float3 _Scale;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float2 appendResult2_g5 = (float2(( ase_vertex3Pos + _Offset ).x , ( ase_vertex3Pos + _Offset ).z));
			float2 appendResult5_g5 = (float2(length( appendResult2_g5 ) , ( ase_vertex3Pos + _Offset ).y));
			float2 q23_g5 = appendResult5_g5;
			float r237_g5 = _Scale.y;
			float h38_g5 = _Scale.z;
			float2 appendResult40_g5 = (float2(r237_g5 , h38_g5));
			float2 k141_g5 = appendResult40_g5;
			float r136_g5 = _Scale.x;
			float2 appendResult45_g5 = (float2(( r237_g5 - r136_g5 ) , ( h38_g5 * 2 )));
			float2 k242_g5 = appendResult45_g5;
			float dotResult70_g5 = dot( ( k141_g5 - q23_g5 ) , k242_g5 );
			float dotResult74_g5 = dot( k242_g5 , k242_g5 );
			float2 cb75_g5 = ( ( q23_g5 - k141_g5 ) + ( k242_g5 * saturate( ( dotResult70_g5 / dotResult74_g5 ) ) ) );
			float ifLocalVar77_g5 = 0;
			if( (cb75_g5).x >= 0 )
				ifLocalVar77_g5 = 1.0;
			else
				ifLocalVar77_g5 = -1.0;
			float temp_output_48_0_g5 = (q23_g5).x;
			float temp_output_52_0_g5 = (q23_g5).y;
			float ifLocalVar51_g5 = 0;
			if( temp_output_52_0_g5 >= 0 )
				ifLocalVar51_g5 = r237_g5;
			else
				ifLocalVar51_g5 = r136_g5;
			float2 appendResult60_g5 = (float2(( temp_output_48_0_g5 - min( temp_output_48_0_g5 , ifLocalVar51_g5 ) ) , ( abs( temp_output_52_0_g5 ) - h38_g5 )));
			float2 ca61_g5 = appendResult60_g5;
			float ifLocalVar82_g5 = 0;
			if( (ca61_g5).y == 0 )
				ifLocalVar82_g5 = 1.0;
			else if( (ca61_g5).y < 0 )
				ifLocalVar82_g5 = -1.0;
			float ifLocalVar86_g5 = 0;
			if( ( ifLocalVar77_g5 + ifLocalVar82_g5 ) >= -1 )
				ifLocalVar86_g5 = 1.0;
			else
				ifLocalVar86_g5 = -1.0;
			float s76_g5 = ifLocalVar86_g5;
			float dotResult91_g5 = dot( ca61_g5 , ca61_g5 );
			float dotResult92_g5 = dot( cb75_g5 , cb75_g5 );
			float sdf28 = -( s76_g5 * sqrt( min( dotResult91_g5 , dotResult92_g5 ) ) );
			float3 temp_cast_0 = (sdf28).xxx;
			c.rgb = temp_cast_0;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
391;316;942;557;814.6931;947.1068;1;True;False
Node;AmplifyShaderEditor.Vector3Node;46;-421.6931,-753.1068;Float;False;Property;_Offset;Offset;3;0;Create;True;0;0;False;0;0,0,0;0,-0.5,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;9;-460.0686,-898.0679;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-217.6931,-773.1068;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;37;-209.1624,-589.849;Float;False;Property;_Scale;Scale;2;0;Create;True;0;0;False;0;1,1,1;1,0,0.5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;2;-847.9355,-0.4803314;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;43;0.8632813,-737.4064;Float;False;SDF Cone;-1;;5;0fb8de29fd7e049769442ad8d571301a;0;2;19;FLOAT3;0,0,0;False;20;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;4;-612.8906,-205.8559;Float;False;Property;_Color;Color;1;0;Create;False;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-656.1026,-28.48033;Float;True;Property;_3DNoiseTex;3D Noise;0;0;Create;False;0;0;False;0;None;None;True;0;False;white;LockedToTexture3D;False;Object;-1;Auto;Texture3D;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;44;218.3069,-726.1068;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;518.9391,-732.4644;Float;False;sdf;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-244.3195,173.5592;Float;False;28;0;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;40;373.7465,-735.5601;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;35;-414.4586,-591.5538;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-341.997,-126.2896;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;189.0996,-121.1419;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Custom/Farl/Amplify/AmplifyConeFog;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;0;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;SrcAlpha;OneMinusSrcAlpha;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;45;0;9;0
WireConnection;45;1;46;0
WireConnection;43;19;45;0
WireConnection;43;20;37;0
WireConnection;1;1;2;0
WireConnection;44;0;43;0
WireConnection;28;0;44;0
WireConnection;40;0;44;0
WireConnection;5;0;4;0
WireConnection;5;1;1;0
WireConnection;0;13;5;0
WireConnection;0;15;29;0
ASEEND*/
//CHKSM=5DFFECFF8072243104E6A2988721080A5AB0BEE3