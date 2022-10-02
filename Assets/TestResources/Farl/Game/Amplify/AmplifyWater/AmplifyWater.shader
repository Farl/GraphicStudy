// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Farl/Amplify/AmplifyWater"
{
	Properties
	{
		_Distance("Distance", Float) = 1
		_ColorDeep("ColorDeep", Color) = (0,0,0,0)
		_ColorShallow("Color Shallow", Color) = (1,1,1,1)
		_Distortion("Distortion", 2D) = "bump" {}
		_PannerSpeed("Panner Speed", Vector) = (0.1,0.1,0,0)
		_DistortionScale("Distortion Scale", Range( 0 , 1)) = 1
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_ColorPower("Color Power", Float) = 0
		_GrabPower("Grab Power", Float) = 0
		_AlphaPower("Alpha Power", Float) = 0
		_Foam("Foam", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,0)
		_FoamPower("Foam Power", Float) = 1
		_NormalScale("Normal Scale", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ "_GrabScreen0" }
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.5
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPos;
		};

		uniform sampler2D _Distortion;
		uniform float2 _PannerSpeed;
		uniform float4 _Distortion_ST;
		uniform float _NormalScale;
		uniform float4 _Color;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabScreen0 )
		uniform float _DistortionScale;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Distance;
		uniform float _GrabPower;
		uniform float4 _ColorShallow;
		uniform float4 _ColorDeep;
		uniform float _ColorPower;
		uniform sampler2D _Foam;
		uniform float4 _Foam_ST;
		uniform float _FoamPower;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _AlphaPower;


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 pannerSpeed63 = _PannerSpeed;
			float2 uv0_Distortion = i.uv_texcoord * _Distortion_ST.xy + _Distortion_ST.zw;
			float2 panner19 = ( 1.0 * _Time.y * pannerSpeed63 + uv0_Distortion);
			float3 tex2DNode14 = UnpackScaleNormal( tex2D( _Distortion, panner19 ), _NormalScale );
			float3 normal26 = tex2DNode14;
			o.Normal = normal26;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor8 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,( ase_grabScreenPosNorm + float4( ( _DistortionScale * tex2DNode14 ) , 0.0 ) ).xy/( ase_grabScreenPosNorm + float4( ( _DistortionScale * tex2DNode14 ) , 0.0 ) ).w);
			float eyeDepth31 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPos.xy ));
			float depth39 = ( ( eyeDepth31 - ase_screenPos.w ) / _Distance );
			float4 lerpResult49 = lerp( float4(1,1,1,1) , screenColor8 , saturate( pow( depth39 , _GrabPower ) ));
			float4 lerpResult4 = lerp( _ColorShallow , _ColorDeep , saturate( pow( depth39 , _ColorPower ) ));
			o.Albedo = ( _Color * ( lerpResult49 * lerpResult4 ) ).rgb;
			float2 uv0_Foam = i.uv_texcoord * _Foam_ST.xy + _Foam_ST.zw;
			float2 panner62 = ( 1.0 * _Time.y * pannerSpeed63 + uv0_Foam);
			float4 emission60 = ( tex2D( _Foam, ( float3( panner62 ,  0.0 ) + normal26 ).xy ) * pow( ( 1.0 - saturate( depth39 ) ) , _FoamPower ) );
			o.Emission = emission60.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			float lerpResult38 = lerp( _ColorShallow.a , _ColorDeep.a , saturate( pow( depth39 , _AlphaPower ) ));
			float alpha36 = lerpResult38;
			o.Alpha = alpha36;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.5
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
				float4 tSpace0 : TEXCOORD4;
				float4 tSpace1 : TEXCOORD5;
				float4 tSpace2 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18301
323;383;1108;549;468.4236;1131.546;1;True;False
Node;AmplifyShaderEditor.ScreenPosInputsNode;34;-1575.194,40.85442;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;21;-1906.329,-636.3536;Float;False;Property;_PannerSpeed;Panner Speed;4;0;Create;True;0;0;False;0;False;0.1,0.1;0.1,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ScreenDepthNode;31;-1360.356,49.4706;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1231.885,206.8297;Float;False;Property;_Distance;Distance;0;0;Create;True;0;0;False;0;False;1;1.17;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;35;-1174.911,76.84654;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-1670.514,-803.7896;Inherit;False;0;14;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-1682.705,-605.8731;Float;False;pannerSpeed;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-1372.409,-480.5245;Float;False;Property;_NormalScale;Normal Scale;14;0;Create;True;0;0;False;0;False;0;0.28;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;19;-1443.788,-709.9117;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;40;-1035.942,77.6823;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-881.5941,77.68221;Float;False;depth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-1230.543,-751.5265;Float;False;Property;_DistortionScale;Distortion Scale;5;0;Create;True;0;0;False;0;False;1;0.22;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;14;-1198.113,-615.5841;Inherit;True;Property;_Distortion;Distortion;3;0;Create;True;0;0;False;0;False;-1;40d39758794c3de40866e615c192191d;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;44;-812.5076,-134.4525;Inherit;False;39;depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;-882.2667,-638.1017;Float;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;57;-126.7895,-1050.93;Inherit;False;0;56;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;69;447.1879,-644.1607;Inherit;False;39;depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-648.1324,-453.6692;Float;False;Property;_GrabPower;Grab Power;9;0;Create;True;0;0;False;0;False;0;-0.48;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-624.9622,-544.5931;Inherit;False;39;depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-835.6778,-43.52882;Float;False;Property;_ColorPower;Color Power;8;0;Create;True;0;0;False;0;False;0;1.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-944.8831,-732.976;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GrabScreenPosition;16;-1202.263,-936.6676;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;64;-121.6923,-911.5677;Inherit;False;63;pannerSpeed;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;45;-609.8076,-131.4555;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;68;637.1907,-655.5609;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-781.7037,-840.6;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PowerNode;52;-422.2624,-541.5961;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-809.6666,238.0238;Inherit;False;39;depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;140.3569,-819.928;Inherit;False;26;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-831.7382,327.8488;Float;False;Property;_AlphaPower;Alpha Power;10;0;Create;True;0;0;False;0;False;0;0.79;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;62;94.58542,-969.3165;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;11;-893.436,-543.887;Float;False;Property;_ColorShallow;Color Shallow;2;0;Create;True;0;0;False;0;False;1,1,1,1;0.3602938,1,0.8676471,0.066;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;8;-585.2034,-725.8464;Float;False;Global;_GrabScreen0;Grab Screen 0;1;0;Create;True;0;0;False;0;False;Object;-1;True;True;1;0;FLOAT4;0,0,0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;53;-439.8701,-935.6455;Float;False;Constant;_white;white;11;0;Create;True;0;0;False;0;False;1,1,1,1;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;47;-434.6331,-85.39337;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;330.305,-919.4246;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;12;-897.2844,-366.8768;Float;False;Property;_ColorDeep;ColorDeep;1;0;Create;True;0;0;False;0;False;0,0,0,0;0.07293455,0.5220588,0.3733831,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;72;858.0909,-513.059;Float;False;Property;_FoamPower;Foam Power;13;0;Create;True;0;0;False;0;False;1;1.04;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;70;823.3932,-594.7601;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;54;-244.4909,-486.2222;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;42;-605.8679,241.0208;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;48;-420.5026,342.0524;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;49;-204.6977,-679.2326;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;4;-413.9072,-288.9959;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;71;1011.993,-619.4606;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;56;518.6674,-961.7122;Inherit;True;Property;_Foam;Foam;11;0;Create;True;0;0;False;0;False;-1;None;9fbef4b79ca3b784ba023cb1331520d5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;38;-409.5605,127.1333;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-207.6237,-384.801;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;1091.898,-839.8634;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RelayNode;18;-9.350395,-480.8674;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-213.415,118.9444;Float;False;alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;1357.192,-929.3132;Float;False;emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;58;144.0696,-645.2385;Float;False;Property;_Color;Color;12;0;Create;True;0;0;False;0;False;1,1,1,0;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;37;126.2612,-42.36661;Inherit;False;36;alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;382.6309,-498.2478;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;301.949,-401.0348;Inherit;False;26;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;25;41.71763,-154.6477;Float;False;Property;_Smoothness;Smoothness;6;0;Create;True;0;0;False;0;False;0;0.44;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;363.6852,-301.0223;Inherit;False;60;emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;24;23.05488,-233.2981;Float;False;Property;_Metallic;Metallic;7;0;Create;True;0;0;False;0;False;0;0.701;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;790.0208,-409.16;Float;False;True;-1;3;ASEMaterialInspector;0;0;Standard;Custom/Farl/Amplify/AmplifyWater;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;True;0;Transparent;0.5;True;True;0;True;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;31;0;34;0
WireConnection;35;0;31;0
WireConnection;35;1;34;4
WireConnection;63;0;21;0
WireConnection;19;0;23;0
WireConnection;19;2;63;0
WireConnection;40;0;35;0
WireConnection;40;1;3;0
WireConnection;39;0;40;0
WireConnection;14;1;19;0
WireConnection;14;5;74;0
WireConnection;26;0;14;0
WireConnection;30;0;22;0
WireConnection;30;1;14;0
WireConnection;45;0;44;0
WireConnection;45;1;46;0
WireConnection;68;0;69;0
WireConnection;15;0;16;0
WireConnection;15;1;30;0
WireConnection;52;0;51;0
WireConnection;52;1;50;0
WireConnection;62;0;57;0
WireConnection;62;2;64;0
WireConnection;8;0;15;0
WireConnection;47;0;45;0
WireConnection;65;0;62;0
WireConnection;65;1;66;0
WireConnection;70;0;68;0
WireConnection;54;0;52;0
WireConnection;42;0;41;0
WireConnection;42;1;43;0
WireConnection;48;0;42;0
WireConnection;49;0;53;0
WireConnection;49;1;8;0
WireConnection;49;2;54;0
WireConnection;4;0;11;0
WireConnection;4;1;12;0
WireConnection;4;2;47;0
WireConnection;71;0;70;0
WireConnection;71;1;72;0
WireConnection;56;1;65;0
WireConnection;38;0;11;4
WireConnection;38;1;12;4
WireConnection;38;2;48;0
WireConnection;17;0;49;0
WireConnection;17;1;4;0
WireConnection;67;0;56;0
WireConnection;67;1;71;0
WireConnection;18;0;17;0
WireConnection;36;0;38;0
WireConnection;60;0;67;0
WireConnection;59;0;58;0
WireConnection;59;1;18;0
WireConnection;0;0;59;0
WireConnection;0;1;27;0
WireConnection;0;2;61;0
WireConnection;0;3;24;0
WireConnection;0;4;25;0
WireConnection;0;9;37;0
ASEEND*/
//CHKSM=CB423DBF389EE9F267FABCEF68C331B741412B55