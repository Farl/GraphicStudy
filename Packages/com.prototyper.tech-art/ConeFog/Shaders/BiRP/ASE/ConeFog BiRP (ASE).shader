// Made with Amplify Shader Editor v1.9.3.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SS/ConeFog BiRP (ASE)"
{
	Properties
	{
		[HDR]_Color("Color", Color) = (1,1,1,1)
		_NoiseScale("Noise Scale", Float) = 1
		_3DNoiseTex("3D Noise", 3D) = "white" {}
		_NoiseSpeed("Noise Speed", Vector) = (0,0,0,0)
		_FresnelOpacity("Fresnel Opacity (Bias, Scale, Power)", Vector) = (0,1,5,0)
		_NoiseParam("Noise (Bias, Scale, Power)", Vector) = (0,1,1,0)
		_Length("Length", Float) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd vertex:vertexDataFunc 
		struct Input
		{
			float4 vertexColor : COLOR;
			float3 worldPos;
			float3 worldNormal;
			float eyeDepth;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float4 _Color;
		uniform float3 _FresnelOpacity;
		uniform sampler3D _3DNoiseTex;
		uniform float _NoiseScale;
		uniform float3 _NoiseSpeed;
		uniform float3 _NoiseParam;
		uniform float _Length;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV59 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode59 = ( _FresnelOpacity.x + _FresnelOpacity.y * pow( 1.0 - fresnelNdotV59, _FresnelOpacity.z ) );
			float fresnelOpacity62 = saturate( fresnelNode59 );
			float cameraDepthFade81 = (( i.eyeDepth -_ProjectionParams.y - 0.0 ) / _Length);
			float opacity63 = ( _Color.a * i.vertexColor.a * ( 1.0 - fresnelOpacity62 ) * ( pow( ( tex3D( _3DNoiseTex, ( ( ase_worldPos * _NoiseScale ) + float3( 0,0,0 ) + ( _Time.y * _NoiseSpeed ) ) ).r * _NoiseParam.y ) , _NoiseParam.z ) + _NoiseParam.x ) * saturate( cameraDepthFade81 ) );
			c.rgb = ( ( _Color * i.vertexColor ) * opacity63 ).rgb;
			c.a = opacity63;
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
Version=19303
Node;AmplifyShaderEditor.CommentaryNode;76;-2236.792,-130.5869;Inherit;False;1439.371;848.9309;;13;79;78;77;1;80;55;49;54;57;58;2;56;53;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-2122.779,300.5393;Float;False;Property;_NoiseScale;Noise Scale;3;0;Create;True;0;0;0;False;0;False;1;0.11;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;56;-2186.792,426.7362;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;2;-2140.786,145.0834;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;58;-2175.818,529.1569;Float;False;Property;_NoiseSpeed;Noise Speed;5;0;Create;True;0;0;0;False;0;False;0,0,0;0,0.1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-1967.319,424.9072;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-1906.964,216.4081;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;60;-1935.925,-768.156;Float;False;Property;_FresnelOpacity;Fresnel Opacity (Bias, Scale, Power);6;0;Create;False;0;0;0;False;0;False;0,1,5;-0.06,1.45,0.6;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;49;-1998.397,-80.58686;Float;True;Property;_3DNoiseTex;3D Noise;4;0;Create;False;0;0;0;False;0;False;None;decce4e1072f54a0184d0c7ee5de69f5;False;white;LockedToTexture3D;Texture3D;-1;0;2;SAMPLER3D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-1769.794,238.3554;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;59;-1525.057,-875.558;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;80;-1489.886,225.2404;Float;False;Property;_NoiseParam;Noise (Bias, Scale, Power);8;0;Create;False;0;0;0;False;0;False;0,1,1;0.01,0.61,0.6;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;1;-1612.393,3.402141;Inherit;True;Property;;;0;0;Create;False;0;0;0;False;0;False;-1;None;decce4e1072f54a0184d0c7ee5de69f5;True;0;False;white;LockedToTexture3D;False;Object;-1;Auto;Texture3D;8;0;SAMPLER3D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;61;-1180.589,-864.5106;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-823.2473,826.062;Float;False;Property;_Length;Length;9;0;Create;True;0;0;0;False;0;False;1;2.33;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-1297.959,20.34574;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-1011.411,-873.836;Float;False;fresnelOpacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;81;-670.5605,709.4038;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-686.9565,412.7829;Inherit;True;62;fresnelOpacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;78;-1139.75,72.21783;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;47;-588.3318,191.8045;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;84;-406.8264,699.4006;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;4;-644.6403,-228.2674;Float;False;Property;_Color;Color;0;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;0.6797647,0.6563228,0.3448806,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;66;-478.7368,412.783;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;79;-968.5718,108.5283;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-292.6699,124.8866;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-112,128;Float;False;opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;-319.8711,-21.00596;Inherit;False;63;opacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-341.997,-126.2896;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;9;-460.0686,-898.0679;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;46;-421.6931,-753.1068;Float;False;Property;_Offset;Offset;2;0;Create;True;0;0;0;False;0;False;0,0,0;0,-0.5,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;37;-209.1624,-589.849;Float;False;Property;_Scale;Scale;1;0;Create;True;0;0;0;False;0;False;1,1,1;1,0,0.5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-217.6931,-773.1068;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;43;0.8632813,-737.4064;Inherit;False;SDF Cone;-1;;5;0fb8de29fd7e049769442ad8d571301a;0;2;19;FLOAT3;0,0,0;False;20;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;44;218.3069,-726.1068;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;518.9391,-732.4644;Float;False;sdf;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-137.3156,-96.07552;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.InverseOpNode;73;-2226.145,-1039.07;Inherit;False;1;0;FLOAT3x3;0,0,0,0,0,1,1,0,1;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-143.632,344.3683;Inherit;False;28;sdf;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-2069.532,-1031.497;Inherit;False;2;2;0;FLOAT3x3;0,0,0,0,0,1,1,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;74;-138.5815,511.3117;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;35;-414.4586,-591.5538;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;72;-2414.074,-918.2213;Inherit;True;Property;_BumpTex;Normal;7;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldToTangentMatrix;68;-2481.399,-1065.913;Inherit;False;0;1;FLOAT3x3;0
Node;AmplifyShaderEditor.SignOpNode;40;373.7465,-735.5601;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;80,-64;Inherit;False;63;opacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;340.9448,-129.6725;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;SS/ConeFog BiRP (ASE);False;False;False;False;True;True;True;True;True;True;True;True;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;-1;False;;-1;False;;False;0;Transparent;0.5;True;False;0;True;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;57;0;56;0
WireConnection;57;1;58;0
WireConnection;54;0;2;0
WireConnection;54;1;53;0
WireConnection;55;0;54;0
WireConnection;55;2;57;0
WireConnection;59;1;60;1
WireConnection;59;2;60;2
WireConnection;59;3;60;3
WireConnection;1;0;49;0
WireConnection;1;1;55;0
WireConnection;61;0;59;0
WireConnection;77;0;1;1
WireConnection;77;1;80;2
WireConnection;62;0;61;0
WireConnection;81;0;82;0
WireConnection;78;0;77;0
WireConnection;78;1;80;3
WireConnection;84;0;81;0
WireConnection;66;0;65;0
WireConnection;79;0;78;0
WireConnection;79;1;80;1
WireConnection;48;0;4;4
WireConnection;48;1;47;4
WireConnection;48;2;66;0
WireConnection;48;3;79;0
WireConnection;48;4;84;0
WireConnection;63;0;48;0
WireConnection;5;0;4;0
WireConnection;5;1;47;0
WireConnection;45;0;9;0
WireConnection;45;1;46;0
WireConnection;43;19;45;0
WireConnection;43;20;37;0
WireConnection;44;0;43;0
WireConnection;28;0;44;0
WireConnection;85;0;5;0
WireConnection;85;1;86;0
WireConnection;73;0;68;0
WireConnection;69;0;73;0
WireConnection;69;1;72;0
WireConnection;40;0;44;0
WireConnection;0;9;64;0
WireConnection;0;13;85;0
ASEEND*/
//CHKSM=41C4BC90305D47FDFCCBA14E526DCD04B2428F36