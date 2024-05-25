// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifyConeFog"
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
		Blend One One
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd vertex:vertexDataFunc 
		struct Input
		{
			float4 vertexColor : COLOR;
			float3 worldPos;
			float3 worldNormal;
			float eyeDepth;
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
			float fresnelNDotV59 = dot( normalize( ase_worldNormal ), ase_worldViewDir );
			float fresnelNode59 = ( _FresnelOpacity.x + _FresnelOpacity.y * pow( 1.0 - fresnelNDotV59, _FresnelOpacity.z ) );
			float fresnelOpacity62 = saturate( fresnelNode59 );
			float mulTime56 = _Time.y * 1;
			float cameraDepthFade81 = (( i.eyeDepth -_ProjectionParams.y - 0 ) / _Length);
			float opacity63 = ( _Color.a * i.vertexColor.a * ( 1.0 - fresnelOpacity62 ) * ( pow( ( tex3D( _3DNoiseTex, ( ( ase_worldPos * _NoiseScale ) + float3( 0,0,0 ) + ( mulTime56 * _NoiseSpeed ) ) ).r * _NoiseParam.y ) , _NoiseParam.z ) + _NoiseParam.x ) * saturate( cameraDepthFade81 ) );
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
Version=15001
25;45;1412;798;1498.804;326.4026;1.706126;True;False
Node;AmplifyShaderEditor.CommentaryNode;76;-2236.792,-130.5869;Float;False;1439.371;848.9309;;13;79;78;77;1;80;55;49;54;57;58;2;56;53;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-2122.779,300.5393;Float;False;Property;_NoiseScale;Noise Scale;4;0;Create;True;0;0;False;0;1;0.29;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;56;-2186.792,426.7362;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;2;-2140.786,145.0834;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;58;-2175.818,529.1569;Float;False;Property;_NoiseSpeed;Noise Speed;6;0;Create;True;0;0;False;0;0,0,0;0,0.1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-1967.319,424.9072;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-1906.964,216.4081;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;49;-1998.397,-80.58686;Float;True;Property;_3DNoiseTex;3D Noise;5;0;Create;False;0;0;False;0;None;decce4e1072f54a0184d0c7ee5de69f5;False;white;LockedToTexture3D;0;1;SAMPLER3D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-1769.794,238.3554;Float;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;60;-1935.925,-768.156;Float;False;Property;_FresnelOpacity;Fresnel Opacity (Bias, Scale, Power);7;0;Create;False;0;0;False;0;0,1,5;0.35,0.9,1.43;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;80;-1489.886,225.2404;Float;False;Property;_NoiseParam;Noise (Bias, Scale, Power);9;0;Create;False;0;0;False;0;0,1,1;0.01,0.61,0.6;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;1;-1612.393,3.402141;Float;True;Property;;;0;0;Create;False;0;0;False;0;None;decce4e1072f54a0184d0c7ee5de69f5;True;0;False;white;LockedToTexture3D;False;Object;-1;Auto;Texture3D;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;59;-1525.057,-875.558;Float;False;World;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-823.2473,826.062;Float;False;Property;_Length;Length;10;0;Create;True;0;0;False;0;1;2.33;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-1297.959,20.34574;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;61;-1180.589,-864.5106;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-1011.411,-873.836;Float;False;fresnelOpacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;81;-670.5605,709.4038;Float;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-686.9565,412.7829;Float;True;62;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;78;-1139.75,72.21783;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;47;-588.3318,191.8045;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;84;-406.8264,699.4006;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;4;-644.6403,-228.2674;Float;False;Property;_Color;Color;1;1;[HDR];Create;False;0;0;False;0;1,1,1,1;2.542478,2.568,0.7175295,0.321;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;66;-478.7368,412.783;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;79;-968.5718,108.5283;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-292.6699,124.8866;Float;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-80.8894,169.2407;Float;False;opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;-319.8711,-21.00596;Float;False;63;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-341.997,-126.2896;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NegateNode;44;218.3069,-726.1068;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;37;-209.1624,-589.849;Float;False;Property;_Scale;Scale;2;0;Create;True;0;0;False;0;1,1,1;1,0,0.5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;9;-460.0686,-898.0679;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-137.3156,-96.07552;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;142.8489,-63.8057;Float;False;63;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;43;0.8632813,-737.4064;Float;False;SDF Cone;-1;;5;0fb8de29fd7e049769442ad8d571301a;0;2;19;FLOAT3;0,0,0;False;20;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;518.9391,-732.4644;Float;False;sdf;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.InverseOpNode;73;-2226.145,-1039.07;Float;False;1;0;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.Vector3Node;46;-421.6931,-753.1068;Float;False;Property;_Offset;Offset;3;0;Create;True;0;0;False;0;0,0,0;0,-0.5,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;29;-143.632,344.3683;Float;False;28;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-2069.532,-1031.497;Float;False;2;2;0;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-217.6931,-773.1068;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;74;-138.5815,511.3117;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;35;-414.4586,-591.5538;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;72;-2414.074,-918.2213;Float;True;Property;_BumpTex;Normal;8;0;Create;False;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldToTangentMatrix;68;-2481.399,-1065.913;Float;False;0;1;FLOAT3x3;0
Node;AmplifyShaderEditor.SignOpNode;40;373.7465,-735.5601;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;340.9448,-129.6725;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Custom/Farl/Amplify/AmplifyConeFog;False;False;False;False;True;True;True;True;True;True;True;True;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;-1;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;4;One;One;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;57;0;56;0
WireConnection;57;1;58;0
WireConnection;54;0;2;0
WireConnection;54;1;53;0
WireConnection;55;0;54;0
WireConnection;55;2;57;0
WireConnection;1;0;49;0
WireConnection;1;1;55;0
WireConnection;59;1;60;1
WireConnection;59;2;60;2
WireConnection;59;3;60;3
WireConnection;77;0;1;1
WireConnection;77;1;80;2
WireConnection;61;0;59;0
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
WireConnection;44;0;43;0
WireConnection;85;0;5;0
WireConnection;85;1;86;0
WireConnection;43;19;45;0
WireConnection;43;20;37;0
WireConnection;28;0;44;0
WireConnection;73;0;68;0
WireConnection;69;0;73;0
WireConnection;69;1;72;0
WireConnection;45;0;9;0
WireConnection;45;1;46;0
WireConnection;40;0;44;0
WireConnection;0;9;64;0
WireConnection;0;13;85;0
ASEEND*/
//CHKSM=DA9ADF3832FDD52D31E921F8AC23DC3223A04D09