// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Farl/Char_NPPBR (Complex)"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull Mode", Float) = 2
		_Cutoff("Alpha Clip", Range( 0 , 1)) = 0
		[SingleLineTexture][MainTexture]_BaseMap("Albedo", 2D) = "white" {}
		_BaseColor("Color", Color) = (1,1,1,1)
		[SingleLineTexture]_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("Normal Scale", Float) = 1
		[SingleLineTexture]_MetallicGlossMap("Metallic Gloss Map", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 1
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.5
		_MetallicSmoothnessClamp("Metallic Smoothness Clamp", Vector) = (0,1,0,1)
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,0)
		[SingleLineTexture]_EmissionMap("Emission Map", 2D) = "black" {}
		_Lambert("Lambert", Range( -1 , 1)) = -1
		_AmbientColor("Ambient Color", Color) = (0,0,0,0)
		_AmbientandLightProberatio("Ambient and Light Probe ratio", Range( 0 , 1)) = 1
		[Header(Diffuse Radiance)][SingleLineTexture]_AlbedoRadianceTex("Diffuse Radiance", 2D) = "white" {}
		_DiffuseRadianceScale("Diffuse Radiance Scale", Range( 0 , 2)) = 0.25
		[Header(Matcap)][SingleLineTexture]_MatcapSpecular("Matcap Specular", 2D) = "gray" {}
		_MatcapScale("Matcap Scale", Range( 0 , 1)) = 1
		[Header(____ Fresnel FX ____)][Toggle]_FresnelFX("Fresnel FX", Float) = 0
		[HDR]_FresnelFXColor("Fresnel FX Color", Color) = (0,0,0,0)
		_FresnelFXTex("Fresnel FX Texture", 2D) = "white" {}
		[NoScaleOffset]_FresnelFXMask("Fresnel FX Mask", 2D) = "white" {}
		_FresnelFXParameter("Fresnel FX (Bias, Scale, Power)", Vector) = (0,1,5,0)
		_FresnelFXAnimated("Fresnel FX (UV Speed)", Vector) = (0,0,0,0)
		[Header(____Fade FX____)]_FadeFXOffset("Fade FX Offset", Range( -1 , 1)) = 1
		_FadeFXDivide("Fade FX Divide", Range( 0 , 1)) = 1
		[Toggle]_FadeFXInvert("Fade FX Invert", Float) = 0
		[Toggle]_EnvironmentReflections("Environment Reflection", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("Src Blend", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("Dst Blend", Float) = 10
		[Toggle]_ZWrite("ZWrite", Float) = 1
		_DepthOffsetUnits("Depth Offset Units", Float) = 0
		_DepthOffsetFactor("Depth Offset Factor", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

		[HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull [_Cull]
		AlphaToMask Off
		
		HLSLINCLUDE
		#pragma target 3.0

		#pragma prefer_hlslcc gles
		

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}
		
		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS

		ENDHLSL

		
		Pass
		{
			Name "ExtraPrePass"
			
			
			Blend One Zero
			Cull Back
			ZWrite On
			ZTest LEqual
			Offset [_DepthOffsetFactor] , [_DepthOffsetUnits]
			ColorMask 0
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#pragma multi_compile _ _ADDITIONAL_LIGHTS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _AmbientColor;
			float4 _EmissionMap_ST;
			float4 _EmissionColor;
			float4 _BumpMap_ST;
			float4 _FresnelFXColor;
			float4 _MetallicSmoothnessClamp;
			float4 _FresnelFXParameter;
			float4 _MetallicGlossMap_ST;
			float4 _BaseMap_ST;
			float4 _FresnelFXAnimated;
			float4 _FresnelFXTex_ST;
			float4 _BaseColor;
			float4 _AlbedoRadianceTex_ST;
			float _DiffuseRadianceScale;
			float _MatcapScale;
			float _FresnelFX;
			float _FadeFXInvert;
			float _FadeFXOffset;
			float _SrcBlend;
			float _AmbientandLightProberatio;
			float _FadeFXDivide;
			float _Lambert;
			float _BumpScale;
			float _Smoothness;
			float _Metallic;
			float _DepthOffsetUnits;
			float _ZWrite;
			float _DstBlend;
			float _DepthOffsetFactor;
			float _Cull;
			float _EnvironmentReflections;
			float _Cutoff;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			

			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				
				float3 Color = float3( 0, 0, 0 );
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" }
			
			Blend [_SrcBlend] [_DstBlend], [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]
			ZTest LEqual
			Offset [_DepthOffsetFactor] , [_DepthOffsetUnits]
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999

			
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma shader_feature _ _SAMPLE_GI
			#pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile _ DEBUG_DISPLAY
			#define SHADERPASS SHADERPASS_UNLIT


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"


			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_tangent : TANGENT;
				float4 lightmapUVOrVertexSH : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _AmbientColor;
			float4 _EmissionMap_ST;
			float4 _EmissionColor;
			float4 _BumpMap_ST;
			float4 _FresnelFXColor;
			float4 _MetallicSmoothnessClamp;
			float4 _FresnelFXParameter;
			float4 _MetallicGlossMap_ST;
			float4 _BaseMap_ST;
			float4 _FresnelFXAnimated;
			float4 _FresnelFXTex_ST;
			float4 _BaseColor;
			float4 _AlbedoRadianceTex_ST;
			float _DiffuseRadianceScale;
			float _MatcapScale;
			float _FresnelFX;
			float _FadeFXInvert;
			float _FadeFXOffset;
			float _SrcBlend;
			float _AmbientandLightProberatio;
			float _FadeFXDivide;
			float _Lambert;
			float _BumpScale;
			float _Smoothness;
			float _Metallic;
			float _DepthOffsetUnits;
			float _ZWrite;
			float _DstBlend;
			float _DepthOffsetFactor;
			float _Cull;
			float _EnvironmentReflections;
			float _Cutoff;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _BaseMap;
			sampler2D _MetallicGlossMap;
			sampler2D _BumpMap;
			sampler2D _AlbedoRadianceTex;
			sampler2D _EmissionMap;
			sampler2D _FresnelFXTex;
			sampler2D _FresnelFXMask;
			sampler2D _MatcapSpecular;


			half OneMinusReflectivityMetallic17_g654( half metallic, half kDielectricSpecA )
			{
				    // We'll need oneMinusReflectivity, so
				    //   1-reflectivity = 1-lerp(dielectricSpec, 1, metallic) = lerp(1-dielectricSpec, 0, metallic)
				    // store (1-dielectricSpec) in kDielectricSpec.a, then
				    //   1-reflectivity = lerp(alpha, 0, metallic) = alpha + metallic*(0 - alpha) =
				    //                  = alpha - metallic * alpha
				    half oneMinusDielectricSpec = kDielectricSpecA;
				    return oneMinusDielectricSpec - metallic * oneMinusDielectricSpec;
			}
			
			float3 TangentToWorld( float3 NormalTS, float3x3 TBN )
			{
				float3 NormalWS = TransformTangentToWorld(NormalTS, TBN);
				NormalWS = NormalizeNormalPerPixel(NormalWS);
				return NormalWS;
			}
			
			real3 ASESafeNormalize(float3 inVec)
			{
				real dp3 = max(FLT_MIN, dot(inVec, inVec));
				return inVec* rsqrt( dp3);
			}
			
			float3 ASEIndirectDiffuse( float2 uvStaticLightmap, float3 normalWS )
			{
			#ifdef LIGHTMAP_ON
				return SampleLightmap( uvStaticLightmap, normalWS );
			#else
				return SampleSH(normalWS);
			#endif
			}
			
			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord4.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord5.xyz = ase_worldNormal;
				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( ase_worldNormal, o.lightmapUVOrVertexSH.xyz );
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord7.xyz = ase_worldBitangent;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_tangent = v.ase_tangent;
				o.ase_texcoord3.zw = v.texcoord1.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord7.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				o.texcoord1 = v.texcoord1;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float2 uv_BaseMap = IN.ase_texcoord3.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;
				float4 albedo54 = ( tex2D( _BaseMap, uv_BaseMap ) * _BaseColor );
				float3 temp_output_50_0_g654 = albedo54.rgb;
				float2 uv_MetallicGlossMap = IN.ase_texcoord3.xy * _MetallicGlossMap_ST.xy + _MetallicGlossMap_ST.zw;
				float4 tex2DNode4_g652 = tex2D( _MetallicGlossMap, uv_MetallicGlossMap );
				float clampResult859 = clamp( ( tex2DNode4_g652.r * _Metallic ) , _MetallicSmoothnessClamp.x , _MetallicSmoothnessClamp.y );
				float metallic69 = clampResult859;
				float temp_output_24_0_g654 = metallic69;
				half metallic17_g654 = temp_output_24_0_g654;
				float4 _kDielectricSpec = float4(0.04,0.04,0.04,0.96);
				half kDielectricSpecA17_g654 = _kDielectricSpec.w;
				half localOneMinusReflectivityMetallic17_g654 = OneMinusReflectivityMetallic17_g654( metallic17_g654 , kDielectricSpecA17_g654 );
				float3 brdfDiffuse762 = ( temp_output_50_0_g654 * localOneMinusReflectivityMetallic17_g654 );
				float3 lerpResult39_g654 = lerp( (_kDielectricSpec).xyz , temp_output_50_0_g654 , temp_output_24_0_g654);
				float3 brdfSpecular697 = lerpResult39_g654;
				float clampResult861 = clamp( ( tex2DNode4_g652.a * _Smoothness ) , _MetallicSmoothnessClamp.z , _MetallicSmoothnessClamp.w );
				float smoothness68 = clampResult861;
				float temp_output_23_0_g654 = smoothness68;
				float temp_output_4_0_g654 = ( 1.0 - temp_output_23_0_g654 );
				float temp_output_1_0_g656 = temp_output_4_0_g654;
				float temp_output_13_0_g654 = max( ( temp_output_1_0_g656 * temp_output_1_0_g656 ) , 0.0078125 );
				float temp_output_1_0_g655 = temp_output_13_0_g654;
				float temp_output_16_0_g654 = max( ( temp_output_1_0_g655 * temp_output_1_0_g655 ) , 6.103516E-05 );
				float roughness2669 = temp_output_16_0_g654;
				float2 uv_BumpMap = IN.ase_texcoord3.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				float3 unpack4_g653 = UnpackNormalScale( tex2D( _BumpMap, uv_BumpMap ), _BumpScale );
				unpack4_g653.z = lerp( 1, unpack4_g653.z, saturate(_BumpScale) );
				float3 tex2DNode4_g653 = unpack4_g653;
				float3 NormalTS19_g653 = tex2DNode4_g653;
				float3 ase_worldTangent = IN.ase_texcoord4.xyz;
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 Binormal10_g653 = ( cross( ase_worldNormal , ase_worldTangent ) * sign( IN.ase_tangent.w ) );
				float3x3 TBN19_g653 = float3x3(ase_worldTangent, Binormal10_g653, ase_worldNormal);
				float3 localTangentToWorld19_g653 = TangentToWorld( NormalTS19_g653 , TBN19_g653 );
				float3 normalizeResult25_g653 = normalize( localTangentToWorld19_g653 );
				float3 N157 = normalizeResult25_g653;
				float3 temp_output_26_0_g663 = N157;
				float3 temp_output_27_0_g663 = SafeNormalize(_MainLightPosition.xyz);
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float3 V551 = ase_worldViewDir;
				float3 temp_output_28_0_g663 = V551;
				float3 normalizeResult22_g663 = ASESafeNormalize( ( temp_output_27_0_g663 + temp_output_28_0_g663 ) );
				float dotResult13_g663 = dot( temp_output_26_0_g663 , normalizeResult22_g663 );
				float NoH22_g658 = saturate( dotResult13_g663 );
				float temp_output_1_0_g661 = NoH22_g658;
				float roughness2MinusOne678 = ( temp_output_16_0_g654 - 1.0 );
				float temp_output_1_0_g660 = ( ( ( temp_output_1_0_g661 * temp_output_1_0_g661 ) * roughness2MinusOne678 ) + 1.00001 );
				float dotResult14_g663 = dot( temp_output_27_0_g663 , normalizeResult22_g663 );
				half LoH24_g658 = saturate( dotResult14_g663 );
				float temp_output_1_0_g662 = LoH24_g658;
				float normalizationTerm677 = (temp_output_13_0_g654*4.0 + 2.0);
				float temp_output_38_0_g658 = ( roughness2669 / ( ( temp_output_1_0_g660 * temp_output_1_0_g660 ) * max( ( temp_output_1_0_g662 * temp_output_1_0_g662 ) , 0.1 ) * normalizationTerm677 ) );
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float dotResult12_g663 = dot( temp_output_26_0_g663 , temp_output_27_0_g663 );
				float NdotL23_g658 = dotResult12_g663;
				float3 mainLight767 = ( ( brdfDiffuse762 + ( brdfSpecular697 * temp_output_38_0_g658 ) ) * ( ( _MainLightColor.rgb * ase_lightAtten ) * (_Lambert + (NdotL23_g658 - -1.0) * (1.0 - _Lambert) / (1.0 - -1.0)) ) );
				float3 bakedGI177 = ASEIndirectDiffuse( IN.lightmapUVOrVertexSH.xy, N157);
				MixRealtimeAndBakedGI(ase_mainLight, N157, bakedGI177, half4(0,0,0,0));
				float4 lerpResult328 = lerp( _AmbientColor , float4( bakedGI177 , 0.0 ) , _AmbientandLightProberatio);
				ase_worldViewDir = normalize(ase_worldViewDir);
				half3 reflectVector917 = reflect( -ase_worldViewDir, N157 );
				float3 indirectSpecular917 = GlossyEnvironmentReflection( reflectVector917, 1.0 - smoothness68, 1.0 );
				float temp_output_18_0_g654 = ( 1.0 - localOneMinusReflectivityMetallic17_g654 );
				float grazingTerm676 = saturate( ( temp_output_23_0_g654 + temp_output_18_0_g654 ) );
				float3 temp_cast_6 = (grazingTerm676).xxx;
				float3 temp_output_26_0_g665 = N157;
				float3 temp_output_28_0_g665 = V551;
				float dotResult8_g665 = dot( temp_output_26_0_g665 , temp_output_28_0_g665 );
				float NoV1_g664 = saturate( dotResult8_g665 );
				float temp_output_8_0_g664 = ( 1.0 - NoV1_g664 );
				float temp_output_7_0_g664 = ( temp_output_8_0_g664 * temp_output_8_0_g664 );
				float fresnelTerm5_g664 = ( temp_output_7_0_g664 * temp_output_7_0_g664 );
				float3 lerpResult15_g664 = lerp( brdfSpecular697 , temp_cast_6 , fresnelTerm5_g664);
				float4 indirectLight828 = ( float4( ( lerpResult328.rgb * brdfDiffuse762 ) , 0.0 ) + ( (( _EnvironmentReflections )?( float4( indirectSpecular917 , 0.0 ) ):( _GlossyEnvironmentColor )) * ( 1.0 / ( roughness2669 + 1.0 ) ) * float4( lerpResult15_g664 , 0.0 ) ) );
				float2 uv_AlbedoRadianceTex = IN.ase_texcoord3.xy * _AlbedoRadianceTex_ST.xy + _AlbedoRadianceTex_ST.zw;
				float4 albedoRadiance236 = saturate( ( albedo54 * tex2D( _AlbedoRadianceTex, uv_AlbedoRadianceTex ).r * _DiffuseRadianceScale * _MainLightColor.a ) );
				float2 uv_EmissionMap = IN.ase_texcoord3.xy * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
				float3 ase_worldBitangent = IN.ase_texcoord7.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal34_g657 = float3( 0,0,1 );
				float fresnelNdotV34_g657 = dot( float3(dot(tanToWorld0,tanNormal34_g657), dot(tanToWorld1,tanNormal34_g657), dot(tanToWorld2,tanNormal34_g657)), ase_worldViewDir );
				float fresnelNode34_g657 = ( _FresnelFXParameter.x + _FresnelFXParameter.y * pow( max( 1.0 - fresnelNdotV34_g657 , 0.0001 ), _FresnelFXParameter.z ) );
				float2 uv_FresnelFXTex = IN.ase_texcoord3.xy * _FresnelFXTex_ST.xy + _FresnelFXTex_ST.zw;
				float2 panner6_g657 = ( 1.0 * _Time.y * (_FresnelFXAnimated).xy + uv_FresnelFXTex);
				float2 uv_FresnelFXMask54_g657 = IN.ase_texcoord3.xy;
				float4 matcap289 = ( (tex2D( _MatcapSpecular, (mul( UNITY_MATRIX_V, float4( N157 , 0.0 ) ).xyz*0.5 + 0.5).xy )*2.0 + -1.0) * _MatcapScale );
				
				float2 texCoord1_g585 = IN.ase_texcoord3.zw * float2( 1,1 ) + float2( 0,0 );
				float temp_output_9_0_g585 = saturate( ( ( texCoord1_g585.y + _FadeFXOffset ) / _FadeFXDivide ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( max( ( float4( saturate( mainLight767 ) , 0.0 ) + indirectLight828 ) , albedoRadiance236 ) + ( tex2D( _EmissionMap, uv_EmissionMap ) * _EmissionColor ) + (( _FresnelFX )?( ( _FresnelFXColor * saturate( fresnelNode34_g657 ) * tex2D( _FresnelFXTex, panner6_g657 ).r * tex2D( _FresnelFXMask, uv_FresnelFXMask54_g657 ).g ) ):( float4( 0,0,0,0 ) )) + matcap289 ).rgb;
				float Alpha = ( (albedo54).a * (( _FadeFXInvert )?( ( 1.0 - temp_output_9_0_g585 ) ):( temp_output_9_0_g585 )) );
				float AlphaClipThreshold = _Cutoff;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif


				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999

			
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#pragma multi_compile _ _ADDITIONAL_LIGHTS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _AmbientColor;
			float4 _EmissionMap_ST;
			float4 _EmissionColor;
			float4 _BumpMap_ST;
			float4 _FresnelFXColor;
			float4 _MetallicSmoothnessClamp;
			float4 _FresnelFXParameter;
			float4 _MetallicGlossMap_ST;
			float4 _BaseMap_ST;
			float4 _FresnelFXAnimated;
			float4 _FresnelFXTex_ST;
			float4 _BaseColor;
			float4 _AlbedoRadianceTex_ST;
			float _DiffuseRadianceScale;
			float _MatcapScale;
			float _FresnelFX;
			float _FadeFXInvert;
			float _FadeFXOffset;
			float _SrcBlend;
			float _AmbientandLightProberatio;
			float _FadeFXDivide;
			float _Lambert;
			float _BumpScale;
			float _Smoothness;
			float _Metallic;
			float _DepthOffsetUnits;
			float _ZWrite;
			float _DstBlend;
			float _DepthOffsetFactor;
			float _Cull;
			float _EnvironmentReflections;
			float _Cutoff;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _BaseMap;


			
			float3 _LightDirection;
			float3 _LightPosition;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord2.zw = v.ase_texcoord1.xy;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				float3 normalWS = TransformObjectToWorldDir( v.ase_normal );

			#if _CASTING_PUNCTUAL_LIGHT_SHADOW
				float3 lightDirectionWS = normalize(_LightPosition - positionWS);
			#else
				float3 lightDirectionWS = _LightDirection;
			#endif
				float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
			#if UNITY_REVERSED_Z
				clipPos.z = min(clipPos.z, UNITY_NEAR_CLIP_VALUE);
			#else
				clipPos.z = max(clipPos.z, UNITY_NEAR_CLIP_VALUE);
			#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;

				return o;
			}
			
			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_BaseMap = IN.ase_texcoord2.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;
				float4 albedo54 = ( tex2D( _BaseMap, uv_BaseMap ) * _BaseColor );
				float2 texCoord1_g585 = IN.ase_texcoord2.zw * float2( 1,1 ) + float2( 0,0 );
				float temp_output_9_0_g585 = saturate( ( ( texCoord1_g585.y + _FadeFXOffset ) / _FadeFXDivide ) );
				
				float Alpha = ( (albedo54).a * (( _FadeFXInvert )?( ( 1.0 - temp_output_9_0_g585 ) ):( temp_output_9_0_g585 )) );
				float AlphaClipThreshold = _Cutoff;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#pragma multi_compile _ _ADDITIONAL_LIGHTS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _AmbientColor;
			float4 _EmissionMap_ST;
			float4 _EmissionColor;
			float4 _BumpMap_ST;
			float4 _FresnelFXColor;
			float4 _MetallicSmoothnessClamp;
			float4 _FresnelFXParameter;
			float4 _MetallicGlossMap_ST;
			float4 _BaseMap_ST;
			float4 _FresnelFXAnimated;
			float4 _FresnelFXTex_ST;
			float4 _BaseColor;
			float4 _AlbedoRadianceTex_ST;
			float _DiffuseRadianceScale;
			float _MatcapScale;
			float _FresnelFX;
			float _FadeFXInvert;
			float _FadeFXOffset;
			float _SrcBlend;
			float _AmbientandLightProberatio;
			float _FadeFXDivide;
			float _Lambert;
			float _BumpScale;
			float _Smoothness;
			float _Metallic;
			float _DepthOffsetUnits;
			float _ZWrite;
			float _DstBlend;
			float _DepthOffsetFactor;
			float _Cull;
			float _EnvironmentReflections;
			float _Cutoff;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _BaseMap;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord2.zw = v.ase_texcoord1.xy;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_BaseMap = IN.ase_texcoord2.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;
				float4 albedo54 = ( tex2D( _BaseMap, uv_BaseMap ) * _BaseColor );
				float2 texCoord1_g585 = IN.ase_texcoord2.zw * float2( 1,1 ) + float2( 0,0 );
				float temp_output_9_0_g585 = saturate( ( ( texCoord1_g585.y + _FadeFXOffset ) / _FadeFXDivide ) );
				
				float Alpha = ( (albedo54).a * (( _FadeFXInvert )?( ( 1.0 - temp_output_9_0_g585 ) ):( temp_output_9_0_g585 )) );
				float AlphaClipThreshold = _Cutoff;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

	
	}
	
	CustomEditor "ASEMaterialInspector"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18935
523;53;519;964;-1063.509;2606.94;1.442121;True;False
Node;AmplifyShaderEditor.CommentaryNode;50;-1758.278,-2100.938;Inherit;False;454.7003;178.6946;;2;54;852;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;852;-1716.956,-2029.017;Inherit;False;AlbedoMap;2;;531;b35e8330e63694ba0b5348c6741e58ca;0;0;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;976;-551.8229,-2153.713;Inherit;False;1330.264;738.1746;;20;958;646;707;856;735;829;843;830;834;734;968;986;987;988;989;995;997;998;999;1000;Final;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-1531.244,-2039.679;Inherit;False;albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;999;-27.60059,-1775.03;Inherit;False;54;albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;292;-2188.463,-310.7531;Inherit;False;942.5427;268.2085;;6;289;863;279;282;864;865;Matcap Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;150;-2209.069,-1222.163;Inherit;False;1015.333;697.3307;;7;236;31;101;277;30;241;335;Albedo Radiance;1,1,1,1;0;0
Node;AmplifyShaderEditor.SwizzleNode;1000;148.3994,-1774.03;Inherit;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;844;-1113.883,-1740.346;Inherit;False;459.8059;234;;2;551;359;View;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;62;-1872.807,-1784.221;Inherit;False;659.3615;372.3374;;5;68;69;861;859;860;Metallic Gloss;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;1005;148.905,-1692.441;Inherit;False;FadeFX;31;;585;e6183ca63d0c04b53ad514b2b2a873b6;0;0;1;FLOAT;8
Node;AmplifyShaderEditor.CommentaryNode;741;-1146.529,937.4319;Inherit;False;1666.115;819.5583;;19;812;828;802;801;818;813;815;338;177;215;327;328;917;918;920;921;922;923;924;Indirect Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;845;-1099.585,-1275.952;Inherit;False;979.8447;540.6426;;10;697;762;676;678;669;677;760;642;659;886;BRDF Init;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;553;-1094.611,-458.2941;Inherit;False;1422.544;1166.286;;13;767;354;528;252;703;768;698;196;182;687;777;356;884;Main Light PBR;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;47;-1108.435,-2159.777;Inherit;False;493.7338;342.9893;;2;977;157;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;735;194.0551,-1963.608;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewMatrixNode;279;-2059.987,-258.7521;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.FunctionNode;865;-1946.364,-239.5689;Inherit;False;MatcapMap;21;;666;33ae9a654969a4880b5507151dc5827f;0;2;7;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;8;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;335;-1545.578,-866.4691;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;997;554.8581,-1505.301;Inherit;False;Property;_DepthOffsetFactor;Depth Offset Factor;41;0;Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;968;482.8487,-2088.941;Inherit;False;Property;_Cull;Cull Mode;0;1;[Enum];Create;False;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;864;-1899.153,-122.1452;Inherit;False;Property;_MatcapScale;Matcap Scale;23;0;Create;True;0;0;0;False;0;False;1;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;975;-93.91793,1087.187;Inherit;False;SimpleGI;35;;664;74c561fa744af42a083e185e11fea894;0;8;25;FLOAT3;0,0,0;False;26;FLOAT3;0,0,0;False;27;FLOAT3;0,0,0;False;36;FLOAT3;0,0,0;False;30;FLOAT3;0,0,0;False;31;FLOAT3;0,0,0;False;29;FLOAT;0;False;32;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;277;-2183.779,-1064.307;Inherit;True;Property;_AlbedoRadianceTex;Diffuse Radiance;19;2;[Header];[SingleLineTexture];Create;False;1;Diffuse Radiance;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;988;482.4664,-2002.631;Inherit;False;Property;_SrcBlend;Src Blend;37;1;[Enum];Create;False;0;0;1;UnityEngine.Rendering.BlendMode;True;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;828;267.9837,1077.431;Inherit;False;indirectLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;762;-376.1945,-921.8636;Inherit;False;brdfDiffuse;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;818;-414.4266,1419.863;Inherit;False;669;roughness2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;884;-487.7285,-24.71724;Inherit;False;PhysicalBasedRendering;-1;;658;0e63354748fa141ddb2218a9f0244b40;0;11;25;FLOAT3;0,0,0;False;26;FLOAT3;0,0,0;False;27;FLOAT3;0,0,0;False;28;FLOAT3;0,0,0;False;29;FLOAT;0;False;30;FLOAT3;0,0,0;False;31;FLOAT3;0,0,0;False;33;FLOAT;0;False;34;FLOAT;0;False;35;FLOAT;0;False;37;FLOAT;-1;False;2;FLOAT3;0;FLOAT;41
Node;AmplifyShaderEditor.GetLocalVarNode;802;-394.6493,1091.811;Inherit;False;551;V;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1674.339,-866.327;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;923;-504.1346,1230.035;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;241;-2047.209,-752.7859;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;282;-2100.463,-167.6511;Inherit;False;157;N;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;863;-1616.641,-227.215;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;734;-396.5282,-1922.179;Inherit;False;236;albedoRadiance;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;813;-413.7845,1327.537;Inherit;False;697;brdfSpecular;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;829;-386.8489,-2020.03;Inherit;False;828;indirectLight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;856;-371.5332,-1834.093;Inherit;False;EmissionMap;13;;667;fcedce769a1434cf9a60e1c49ef7e555;0;0;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;995;360.298,-1506.786;Inherit;False;Property;_DepthOffsetUnits;Depth Offset Units;40;0;Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;707;-358.7982,-1534.2;Inherit;False;289;matcap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;987;641.4664,-2089.631;Inherit;False;Property;_ZWrite;ZWrite;39;1;[Toggle];Create;True;0;0;1;;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;989;637.4664,-1999.631;Inherit;False;Property;_DstBlend;Dst Blend;38;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;843;27.90908,-2029.444;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;998;293.3355,-1774.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-2166.646,-859.9171;Inherit;False;Property;_DiffuseRadianceScale;Diffuse Radiance Scale;20;0;Create;True;0;0;0;False;0;False;0.25;0.4;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;986;160.9557,-1591.079;Inherit;False;Property;_Cutoff;Alpha Clip;1;0;Create;False;0;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;830;-130.1379,-2047.94;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;-2054.984,-1149.035;Inherit;False;54;albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;328;-667.2019,1131.342;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;1003;-411.7193,-1732.792;Inherit;False;FresnelFX;24;;657;218b4e5458f21824f890b3d55fc451e2;1,12,0;6;47;SAMPLER2D;;False;28;COLOR;0,0,0,0;False;30;FLOAT;0;False;31;FLOAT;0;False;32;FLOAT;0;False;33;FLOAT3;0,0,1;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;815;-411.2782,1513.429;Inherit;False;676;grazingTerm;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;289;-1468.875,-220.8689;Inherit;False;matcap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;834;-321.8458,-2097.238;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;646;-501.8229,-2103.713;Inherit;False;767;mainLight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;767;-149.2678,-24.56357;Inherit;False;mainLight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;236;-1405.327,-870.628;Inherit;False;albedoRadiance;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;327;-1122.832,1235.68;Inherit;False;Property;_AmbientandLightProberatio;Ambient and Light Probe ratio;18;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;356;-836.776,-193.9883;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;659;-1042.47,-1140.529;Inherit;False;69;metallic;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;921;-531.7673,1359.6;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;359;-1063.883,-1690.347;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.IndirectSpecularLight;917;-919.3683,1342.171;Inherit;False;World;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;642;-1040.523,-1225.952;Inherit;False;54;albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;760;-1052.585,-1058.918;Inherit;False;68;smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;920;-1119.636,1329.533;Inherit;False;157;N;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;-1417.941,-1718.82;Inherit;False;metallic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;677;-377.7384,-1218.251;Inherit;False;normalizationTerm;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;801;-398.5103,1006.863;Inherit;False;157;N;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;977;-1088.993,-2117.899;Inherit;False;NormalMap;5;;653;b0ef4d48b16014f17b95574653749cce;0;0;8;FLOAT3;0;FLOAT3;26;FLOAT3;48;FLOAT3;49;FLOAT3;5;FLOAT3;24;FLOAT3;34;FLOAT3;35
Node;AmplifyShaderEditor.Vector4Node;860;-1834.327,-1605.715;Inherit;False;Property;_MetallicSmoothnessClamp;Metallic Smoothness Clamp;12;0;Create;True;0;0;0;False;0;False;0,1,0,1;0,1,0,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;887;-1838.206,-1715.439;Inherit;False;MetallicSmoothnessMap;8;;652;b081518771e9345b185fb949e9a644ae;0;0;2;FLOAT;0;FLOAT;8
Node;AmplifyShaderEditor.RegisterLocalVarNode;669;-378.9935,-1145.105;Inherit;False;roughness2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;922;-502.8412,1330.674;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;-1416.609,-1604.933;Inherit;False;smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;861;-1558.85,-1598.383;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;157;-809.8495,-2097.915;Inherit;False;N;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;918;-1122.487,1406.061;Inherit;False;68;smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;177;-928.1228,1158.421;Inherit;False;World;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;697;-374.6176,-844.5397;Inherit;False;brdfSpecular;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;924;-477.3512,1204.323;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;777;-781.38,-300.2989;Inherit;False;551;V;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;215;-1121.458,1155.276;Inherit;False;157;N;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;812;-416.6603,1241.315;Inherit;False;762;brdfDiffuse;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;528;-807.1443,245.5271;Inherit;False;697;brdfSpecular;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;886;-810.1823,-1173.712;Inherit;False;BRDF Init;-1;;654;330a2c58aedcf4b89af4dfa60c2d14f2;0;3;50;FLOAT3;0,0,0;False;24;FLOAT;0;False;23;FLOAT;0;False;11;FLOAT;27;FLOAT;28;FLOAT;29;FLOAT;0;FLOAT;20;FLOAT;31;FLOAT;21;FLOAT;22;FLOAT3;33;FLOAT3;34;FLOAT4;62
Node;AmplifyShaderEditor.GetLocalVarNode;698;-807.152,344.4714;Inherit;False;669;roughness2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;182;-778.1108,-54.39796;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;551;-878.0777,-1689.208;Inherit;False;V;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;687;-861.1863,415.4416;Inherit;False;678;roughness2MinusOne;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;354;-779.9482,-375.6524;Inherit;False;157;N;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightAttenuation;196;-814.4169,65.23985;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;768;-798.5348,174.37;Inherit;False;762;brdfDiffuse;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;252;-897.2119,601.0315;Inherit;False;Property;_Lambert;Lambert;16;0;Create;True;0;0;0;False;0;False;-1;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;338;-1117.04,982.4319;Inherit;False;Property;_AmbientColor;Ambient Color;17;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;678;-379.8004,-1073.345;Inherit;False;roughness2MinusOne;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;676;-377.3756,-997.314;Inherit;False;grazingTerm;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;703;-845.8019,483.8404;Inherit;False;677;normalizationTerm;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;859;-1560.85,-1716.383;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;962;1044.586,-1554.445;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;9a54fbfe5a07e9e44b580fb887c56c32;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;966;1044.586,-1554.445;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;9a54fbfe5a07e9e44b580fb887c56c32;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthNormalsOnly;False;True;15;d3d9;d3d11_9x;d3d11;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;965;1044.586,-1554.445;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;9a54fbfe5a07e9e44b580fb887c56c32;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthNormalsOnly;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;959;1044.586,-1554.445;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;9a54fbfe5a07e9e44b580fb887c56c32;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;961;1044.586,-1554.445;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;9a54fbfe5a07e9e44b580fb887c56c32;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;963;1044.586,-1554.445;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;9a54fbfe5a07e9e44b580fb887c56c32;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;960;1044.586,-1554.445;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;9a54fbfe5a07e9e44b580fb887c56c32;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;964;1044.586,-1554.445;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;9a54fbfe5a07e9e44b580fb887c56c32;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;958;492.6941,-1894.916;Float;False;True;-1;2;ASEMaterialInspector;0;17;Farl/Char_NPPBR (Complex);9a54fbfe5a07e9e44b580fb887c56c32;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;0;True;968;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;True;18;all;0;True;True;2;5;True;988;10;True;989;1;0;True;988;0;True;989;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;0;True;987;True;3;False;-1;True;True;0;True;997;0;True;995;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;637926774979246410;  Blend;0;637926777035472050;Two Sided;1;0;Cast Shadows;1;637963881462402670;  Use Shadow Threshold;0;0;Receive Shadows;0;637922533829268240;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;1;637963889129577840;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,-1;0;  Type;0;0;  Tess;16,False,-1;0;  Min;10,False,-1;0;  Max;25,False,-1;0;  Edge Length;16,False,-1;0;  Max Displacement;25,False,-1;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;True;True;True;True;False;False;False;False;False;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;957;542.5861,-1335.445;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;17;New Amplify Shader;9a54fbfe5a07e9e44b580fb887c56c32;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;1;False;-1;True;3;False;-1;True;True;0;True;997;0;True;995;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;54;0;852;0
WireConnection;1000;0;999;0
WireConnection;735;0;843;0
WireConnection;735;1;856;0
WireConnection;735;2;1003;0
WireConnection;735;3;707;0
WireConnection;865;7;279;0
WireConnection;865;8;282;0
WireConnection;335;0;30;0
WireConnection;975;25;801;0
WireConnection;975;26;802;0
WireConnection;975;27;328;0
WireConnection;975;36;924;0
WireConnection;975;30;812;0
WireConnection;975;31;813;0
WireConnection;975;29;818;0
WireConnection;975;32;815;0
WireConnection;828;0;975;0
WireConnection;762;0;886;33
WireConnection;884;25;354;0
WireConnection;884;26;777;0
WireConnection;884;27;356;0
WireConnection;884;28;182;1
WireConnection;884;29;196;0
WireConnection;884;30;768;0
WireConnection;884;31;528;0
WireConnection;884;33;698;0
WireConnection;884;34;687;0
WireConnection;884;35;703;0
WireConnection;884;37;252;0
WireConnection;30;0;101;0
WireConnection;30;1;277;1
WireConnection;30;2;31;0
WireConnection;30;3;241;2
WireConnection;923;0;922;0
WireConnection;863;0;865;0
WireConnection;863;1;864;0
WireConnection;843;0;830;0
WireConnection;843;1;734;0
WireConnection;998;0;1000;0
WireConnection;998;1;1005;8
WireConnection;830;0;834;0
WireConnection;830;1;829;0
WireConnection;328;0;338;0
WireConnection;328;1;177;0
WireConnection;328;2;327;0
WireConnection;289;0;863;0
WireConnection;834;0;646;0
WireConnection;767;0;884;0
WireConnection;236;0;335;0
WireConnection;921;0;917;0
WireConnection;917;0;920;0
WireConnection;917;1;918;0
WireConnection;69;0;859;0
WireConnection;677;0;886;0
WireConnection;669;0;886;20
WireConnection;922;0;921;0
WireConnection;68;0;861;0
WireConnection;861;0;887;8
WireConnection;861;1;860;3
WireConnection;861;2;860;4
WireConnection;157;0;977;26
WireConnection;177;0;215;0
WireConnection;697;0;886;34
WireConnection;924;0;923;0
WireConnection;886;50;642;0
WireConnection;886;24;659;0
WireConnection;886;23;760;0
WireConnection;551;0;359;0
WireConnection;678;0;886;31
WireConnection;676;0;886;21
WireConnection;859;0;887;0
WireConnection;859;1;860;1
WireConnection;859;2;860;2
WireConnection;958;2;735;0
WireConnection;958;3;998;0
WireConnection;958;4;986;0
ASEEND*/
//CHKSM=2AE64C647AD057DF6769B6A081B0CAABB79B613F