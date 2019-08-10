// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifyLineWave"
{
	Properties
	{
		_DynamicRipple("DynamicRipple", 2D) = "gray" {}
		_LineParam("Line Param", Float) = 0
		_LinePower("Line Power", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting keepalpha addshadow fullforwardshadows noforwardadd 
		struct Input
		{
			float2 uv_texcoord;
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

		uniform sampler2D _DynamicRipple;
		uniform float4 _DynamicRipple_ST;
		uniform float _LineParam;
		uniform float _LinePower;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			c.rgb = 0;
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
			float2 uv_TexCoord5 = i.uv_texcoord * float2( 1,1 ) + float2( 0,0 );
			float2 uv_DynamicRipple = i.uv_texcoord * _DynamicRipple_ST.xy + _DynamicRipple_ST.zw;
			float4 ripple9 = tex2D( _DynamicRipple, uv_DynamicRipple );
			float temp_output_3_0_g1 = ( 0.5 - saturate( pow( ( abs( ( ( uv_TexCoord5.y + abs( ( (ripple9).g - 0.5 ) ) ) - 0.5 ) ) * _LineParam ) , _LinePower ) ) );
			float3 temp_cast_0 = (saturate( ( temp_output_3_0_g1 / fwidth( temp_output_3_0_g1 ) ) )).xxx;
			o.Emission = temp_cast_0;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
184;186;956;573;2321.689;33.76285;1;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;3;-863.7103,-199.5581;Float;True;Property;_DynamicRipple;DynamicRipple;0;0;Create;True;0;0;False;0;None;;False;gray;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;4;-636.9635,-200.008;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;11;-2137.223,192.6823;Float;False;9;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-334.0176,-197.8134;Float;False;ripple;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;13;-1961.088,218.1859;Float;False;False;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;12;-1759.062,231.3891;Float;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1801.106,-30.14158;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;22;-1639.689,387.2372;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-1520.248,210.2338;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;14;-1333.74,-29.52112;Float;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1259.007,86.73026;Float;False;Property;_LineParam;Line Param;1;0;Create;True;0;0;False;0;0;40;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;15;-1196.729,9.229365;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-1130.617,203.8278;Float;False;Property;_LinePower;Line Power;2;0;Create;True;0;0;False;0;1;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-1063.87,46.59587;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;20;-845.9666,169.767;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;19;-680.6522,154.5436;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-538,382;Float;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;7;-351,268;Float;False;Step Antialiasing;-1;;1;2a825e80dfb3290468194f83380797bd;0;2;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/Farl/Amplify/AmplifyLineWave;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;3;0
WireConnection;9;0;4;0
WireConnection;13;0;11;0
WireConnection;12;0;13;0
WireConnection;22;0;12;0
WireConnection;10;0;5;2
WireConnection;10;1;22;0
WireConnection;14;0;10;0
WireConnection;15;0;14;0
WireConnection;17;0;15;0
WireConnection;17;1;18;0
WireConnection;20;0;17;0
WireConnection;20;1;21;0
WireConnection;19;0;20;0
WireConnection;7;1;19;0
WireConnection;7;2;8;0
WireConnection;0;15;7;0
ASEEND*/
//CHKSM=A2DF2EFE86A87FC9791264122C10B9E5F8F3B90F