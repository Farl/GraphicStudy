// Made with Amplify Shader Editor v1.9.3.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Farl/DisneyBRDF"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[SingleLineTexture][MainTexture]_BaseMap("Albedo", 2D) = "white" {}
		_BaseColor("Color", Color) = (1,1,1,1)
		[SingleLineTexture]_MetallicGlossMap("Metallic Gloss Map", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 1
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.5
		[SingleLineTexture]_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("Normal Scale", Float) = 1
		_subsurface("subsurface", Range( 0 , 1)) = 0
		_specular("specular", Range( 0 , 1)) = 0
		_specularTint("specularTint", Range( 0 , 1)) = 0
		_sheen("sheen", Range( 0 , 1)) = 0
		_sheenTint("sheenTint", Range( 0 , 1)) = 0.5
		_anisotropic("anisotropic", Range( 0 , 1)) = 0
		_clearcoat("clearcoat", Range( 0 , 1)) = 0.5
		_clearcoatGloss("clearcoatGloss", Range( 0 , 1)) = 1
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

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		
		Cull Back
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
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" }
			
			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 140011

			
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
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ _FORWARD_PLUS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BumpMap_ST;
			float4 _MetallicGlossMap_ST;
			float4 _BaseMap_ST;
			float4 _BaseColor;
			float _BumpScale;
			float _Smoothness;
			float _subsurface;
			float _sheen;
			float _sheenTint;
			float _Metallic;
			float _specular;
			float _specularTint;
			float _anisotropic;
			float _clearcoat;
			float _clearcoatGloss;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _BumpMap;
			sampler2D _MetallicGlossMap;
			sampler2D _BaseMap;


			float3 TangentToWorld( float3 NormalTS, float3x3 TBN )
			{
				float3 NormalWS = TransformTangentToWorld(NormalTS, TBN);
				NormalWS = NormalizeNormalPerPixel(NormalWS);
				return NormalWS;
			}
			
			float3 ASESafeNormalize(float3 inVec)
			{
				float dp3 = max(1.175494351e-38, dot(inVec, inVec));
				return inVec* rsqrt(dp3);
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
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_tangent = v.ase_tangent;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
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
				float2 uv_BumpMap = IN.ase_texcoord3.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				float3 unpack4_g705 = UnpackNormalScale( tex2D( _BumpMap, uv_BumpMap ), _BumpScale );
				unpack4_g705.z = lerp( 1, unpack4_g705.z, saturate(_BumpScale) );
				float3 tex2DNode4_g705 = unpack4_g705;
				float3 NormalTS2_g706 = tex2DNode4_g705;
				float3 ase_worldTangent = IN.ase_texcoord4.xyz;
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 Binormal10_g705 = ( cross( ase_worldNormal , ase_worldTangent ) * sign( IN.ase_tangent.w ) );
				float3x3 TBN2_g706 = float3x3(ase_worldTangent, Binormal10_g705, ase_worldNormal);
				float3 localTangentToWorld2_g706 = TangentToWorld( NormalTS2_g706 , TBN2_g706 );
				float3 normalizeResult5_g706 = normalize( localTangentToWorld2_g706 );
				float3 temp_output_66_6_g705 = normalizeResult5_g706;
				float3 N157 = temp_output_66_6_g705;
				float3 temp_output_26_0_g695 = N157;
				float3 L549 = SafeNormalize(_MainLightPosition.xyz);
				float3 temp_output_27_0_g695 = L549;
				float dotResult12_g695 = dot( temp_output_26_0_g695 , temp_output_27_0_g695 );
				float NdotL357 = dotResult12_g695;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float3 V551 = ase_worldViewDir;
				float3 temp_output_28_0_g695 = V551;
				float3 normalizeResult22_g695 = ASESafeNormalize( ( temp_output_27_0_g695 + temp_output_28_0_g695 ) );
				float dotResult14_g695 = dot( temp_output_27_0_g695 , normalizeResult22_g695 );
				float LdotH367 = dotResult14_g695;
				float temp_output_1_0_g716 = LdotH367;
				float2 uv_MetallicGlossMap = IN.ase_texcoord3.xy * _MetallicGlossMap_ST.xy + _MetallicGlossMap_ST.zw;
				float4 tex2DNode4_g717 = tex2D( _MetallicGlossMap, uv_MetallicGlossMap );
				float smoothness68 = ( tex2DNode4_g717.a * _Smoothness );
				float roughness570 = ( 1.0 - smoothness68 );
				float Fss9014_g709 = ( ( temp_output_1_0_g716 * temp_output_1_0_g716 ) * roughness570 );
				float Fd9021_g709 = ( ( Fss9014_g709 * 2.0 ) + 0.5 );
				float temp_output_67_0_g709 = NdotL357;
				float clampResult3_g710 = clamp( ( 1.0 - temp_output_67_0_g709 ) , 0.0 , 1.0 );
				float temp_output_1_0_g711 = clampResult3_g710;
				float temp_output_1_0_g712 = ( temp_output_1_0_g711 * temp_output_1_0_g711 );
				float FL22_g709 = ( ( temp_output_1_0_g712 * temp_output_1_0_g712 ) * clampResult3_g710 );
				float lerpResult29_g709 = lerp( 1.0 , Fd9021_g709 , FL22_g709);
				float dotResult8_g695 = dot( temp_output_26_0_g695 , temp_output_28_0_g695 );
				float NdotV360 = dotResult8_g695;
				float temp_output_68_0_g709 = NdotV360;
				float clampResult3_g713 = clamp( ( 1.0 - temp_output_68_0_g709 ) , 0.0 , 1.0 );
				float temp_output_1_0_g714 = clampResult3_g713;
				float temp_output_1_0_g715 = ( temp_output_1_0_g714 * temp_output_1_0_g714 );
				float FV6_g709 = ( ( temp_output_1_0_g715 * temp_output_1_0_g715 ) * clampResult3_g713 );
				float lerpResult23_g709 = lerp( 1.0 , Fd9021_g709 , FV6_g709);
				float temp_output_24_0_g709 = ( lerpResult29_g709 * lerpResult23_g709 );
				float Fd76_g709 = temp_output_24_0_g709;
				float lerpResult10_g709 = lerp( 1.0 , Fss9014_g709 , FL22_g709);
				float lerpResult8_g709 = lerp( 1.0 , Fss9014_g709 , FV6_g709);
				float temp_output_34_0_g709 = ( lerpResult10_g709 * lerpResult8_g709 );
				float Fss15_g709 = temp_output_34_0_g709;
				float ss39_g709 = ( 1.25 * ( ( Fss15_g709 * ( ( 1.0 / ( temp_output_67_0_g709 + temp_output_68_0_g709 ) ) - 0.5 ) ) + 0.5 ) );
				float lerpResult44_g709 = lerp( Fd76_g709 , ss39_g709 , _subsurface);
				float2 uv_BaseMap = IN.ase_texcoord3.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;
				float4 albedo54 = ( tex2D( _BaseMap, uv_BaseMap ) * _BaseColor );
				float3 Cdlin3_g726 = (albedo54).rgb;
				float3 Cdlin756 = Cdlin3_g726;
				float clampResult3_g665 = clamp( ( 1.0 - LdotH367 ) , 0.0 , 1.0 );
				float temp_output_1_0_g666 = clampResult3_g665;
				float temp_output_1_0_g667 = ( temp_output_1_0_g666 * temp_output_1_0_g666 );
				float temp_output_83_0_g660 = ( ( temp_output_1_0_g667 * temp_output_1_0_g667 ) * clampResult3_g665 );
				float FH460 = temp_output_83_0_g660;
				float3 _vec3one = float3(1,1,1);
				float3 break37_g726 = ( Cdlin3_g726 * float3( 0.3,0.6,0.1 ) );
				float Cdlum7_g726 = ( break37_g726.x + break37_g726.y + break37_g726.z );
				float3 _Vector4 = float3(1,1,1);
				float3 ifLocalVar4_g726 = 0;
				if( Cdlum7_g726 <= 0.0 )
				ifLocalVar4_g726 = _Vector4;
				else
				ifLocalVar4_g726 = ( Cdlin3_g726 / Cdlum7_g726 );
				float3 Ctint12_g726 = ifLocalVar4_g726;
				float3 lerpResult25_g726 = lerp( _vec3one , Ctint12_g726 , _sheenTint);
				float3 Csheen17_g726 = lerpResult25_g726;
				float3 Csheen434 = Csheen17_g726;
				float3 Fsheen485 = ( FH460 * _sheen * Csheen434 );
				float metallic771 = ( tex2DNode4_g717.r * _Metallic );
				float3 lerpResult13_g726 = lerp( _vec3one , Ctint12_g726 , _specularTint);
				float3 lerpResult15_g726 = lerp( ( ( _specular * 0.08 ) * lerpResult13_g726 ) , Cdlin3_g726 , metallic771);
				float3 Cspec020_g726 = lerpResult15_g726;
				float3 Cspec0417 = Cspec020_g726;
				float FH22_g660 = temp_output_83_0_g660;
				float3 lerpResult3_g660 = lerp( Cspec0417 , float3( 1,1,1 ) , FH22_g660);
				float3 Fs71_g660 = lerpResult3_g660;
				float3 temp_output_56_0_g660 = L549;
				float3 NormalTS2_g707 = float3(1,0,0);
				float3x3 TBN2_g707 = float3x3(ase_worldTangent, Binormal10_g705, ase_worldNormal);
				float3 localTangentToWorld2_g707 = TangentToWorld( NormalTS2_g707 , TBN2_g707 );
				float3 normalizeResult5_g707 = normalize( localTangentToWorld2_g707 );
				float3 normalizeResult44_g705 = normalize( cross( temp_output_66_6_g705 , normalizeResult5_g707 ) );
				float3 X410 = cross( normalizeResult44_g705 , temp_output_66_6_g705 );
				float3 temp_output_54_0_g660 = X410;
				float dotResult13_g660 = dot( temp_output_56_0_g660 , temp_output_54_0_g660 );
				float temp_output_1_0_g668 = roughness570;
				float temp_output_62_0_g660 = ( temp_output_1_0_g668 * temp_output_1_0_g668 );
				float temp_output_19_0_g660 = sqrt( ( 1.0 - ( _anisotropic * 0.9 ) ) );
				float2 appendResult63_g660 = (float2(max( 0.001 , ( temp_output_62_0_g660 / temp_output_19_0_g660 ) ) , max( 0.001 , ( temp_output_62_0_g660 * temp_output_19_0_g660 ) )));
				float2 a25_g660 = appendResult63_g660;
				float2 break67_g660 = a25_g660;
				float temp_output_1_0_g664 = ( dotResult13_g660 * break67_g660.x );
				float3 Y407 = normalizeResult44_g705;
				float3 temp_output_55_0_g660 = Y407;
				float dotResult26_g660 = dot( temp_output_56_0_g660 , temp_output_55_0_g660 );
				float temp_output_1_0_g663 = ( dotResult26_g660 * break67_g660.y );
				float temp_output_2_0_g661 = NdotL357;
				float temp_output_1_0_g662 = temp_output_2_0_g661;
				float3 temp_output_57_0_g660 = V551;
				float dotResult20_g660 = dot( temp_output_57_0_g660 , temp_output_54_0_g660 );
				float2 break69_g660 = a25_g660;
				float temp_output_1_0_g681 = ( dotResult20_g660 * break69_g660.x );
				float dotResult27_g660 = dot( temp_output_57_0_g660 , temp_output_55_0_g660 );
				float temp_output_1_0_g680 = ( dotResult27_g660 * break69_g660.y );
				float temp_output_2_0_g678 = NdotV360;
				float temp_output_1_0_g679 = temp_output_2_0_g678;
				float Gs72_g660 = ( ( 1.0 / ( sqrt( ( ( temp_output_1_0_g664 * temp_output_1_0_g664 ) + ( temp_output_1_0_g663 * temp_output_1_0_g663 ) + ( temp_output_1_0_g662 * temp_output_1_0_g662 ) ) ) + temp_output_2_0_g661 ) ) * ( 1.0 / ( sqrt( ( ( temp_output_1_0_g681 * temp_output_1_0_g681 ) + ( temp_output_1_0_g680 * temp_output_1_0_g680 ) + ( temp_output_1_0_g679 * temp_output_1_0_g679 ) ) ) + temp_output_2_0_g678 ) ) );
				float2 break65_g660 = a25_g660;
				float temp_output_5_0_g673 = break65_g660.x;
				float temp_output_6_0_g673 = break65_g660.y;
				float3 H204 = normalizeResult22_g695;
				float3 temp_output_53_0_g660 = H204;
				float dotResult4_g660 = dot( temp_output_53_0_g660 , temp_output_54_0_g660 );
				float temp_output_1_0_g676 = ( dotResult4_g660 / temp_output_5_0_g673 );
				float dotResult33_g660 = dot( temp_output_53_0_g660 , temp_output_55_0_g660 );
				float temp_output_1_0_g675 = ( dotResult33_g660 / temp_output_6_0_g673 );
				float dotResult13_g695 = dot( temp_output_26_0_g695 , normalizeResult22_g695 );
				float NdotH366 = dotResult13_g695;
				float temp_output_52_0_g660 = NdotH366;
				float temp_output_1_0_g677 = temp_output_52_0_g660;
				float temp_output_1_0_g674 = ( ( temp_output_1_0_g676 * temp_output_1_0_g676 ) + ( temp_output_1_0_g675 * temp_output_1_0_g675 ) + ( temp_output_1_0_g677 * temp_output_1_0_g677 ) );
				float Ds73_g660 = ( 1.0 / ( ( temp_output_5_0_g673 * temp_output_6_0_g673 * ( temp_output_1_0_g674 * temp_output_1_0_g674 ) ) * PI ) );
				float temp_output_2_0_g692 = NdotL357;
				float temp_output_1_0_g694 = temp_output_2_0_g692;
				float temp_output_4_0_g692 = ( temp_output_1_0_g694 * temp_output_1_0_g694 );
				float temp_output_1_0_g693 = 0.25;
				float temp_output_5_0_g692 = ( temp_output_1_0_g693 * temp_output_1_0_g693 );
				float temp_output_2_0_g686 = NdotV360;
				float temp_output_1_0_g688 = temp_output_2_0_g686;
				float temp_output_4_0_g686 = ( temp_output_1_0_g688 * temp_output_1_0_g688 );
				float temp_output_1_0_g687 = 0.25;
				float temp_output_5_0_g686 = ( temp_output_1_0_g687 * temp_output_1_0_g687 );
				float temp_output_3_0_g685 = ( ( 1.0 / ( temp_output_2_0_g692 + sqrt( ( ( temp_output_4_0_g692 + temp_output_5_0_g692 ) - ( temp_output_4_0_g692 * temp_output_5_0_g692 ) ) ) ) ) * ( 1.0 / ( temp_output_2_0_g686 + sqrt( ( ( temp_output_4_0_g686 + temp_output_5_0_g686 ) - ( temp_output_4_0_g686 * temp_output_5_0_g686 ) ) ) ) ) );
				float lerpResult9_g685 = lerp( 0.04 , 1.0 , FH460);
				float lerpResult14_g685 = lerp( 0.1 , 0.001 , _clearcoatGloss);
				float temp_output_3_0_g689 = lerpResult14_g685;
				float temp_output_5_0_g689 = ( 1.0 / PI );
				float temp_output_1_0_g690 = temp_output_3_0_g689;
				float temp_output_7_0_g689 = ( temp_output_1_0_g690 * temp_output_1_0_g690 );
				float a2Minus112_g689 = ( temp_output_7_0_g689 - 1.0 );
				float temp_output_1_0_g691 = NdotH366;
				float ifLocalVar4_g689 = 0;
				if( temp_output_3_0_g689 >= 1.0 )
				ifLocalVar4_g689 = temp_output_5_0_g689;
				else
				ifLocalVar4_g689 = ( a2Minus112_g689 / ( ( ( a2Minus112_g689 * ( temp_output_1_0_g691 * temp_output_1_0_g691 ) ) + 1.0 ) * ( log( temp_output_7_0_g689 ) * PI ) ) );
				float temp_output_19_0_g685 = ifLocalVar4_g689;
				float3 temp_output_515_0 = ( ( ( ( ( 1.0 / PI ) * lerpResult44_g709 * Cdlin756 ) + Fsheen485 ) * ( 1.0 - metallic771 ) ) + ( Fs71_g660 * Gs72_g660 * Ds73_g660 ) + ( 0.25 * _clearcoat * temp_output_3_0_g685 * lerpResult9_g685 * temp_output_19_0_g685 ) );
				float3 ifLocalVar769 = 0;
				if( NdotL357 >= 0.0 )
				ifLocalVar769 = temp_output_515_0;
				else
				ifLocalVar769 = float3(0,0,0);
				float3 brdf527 = ifLocalVar769;
				float ase_lightIntensity = max( max( _MainLightColor.r, _MainLightColor.g ), _MainLightColor.b );
				float4 ase_lightColor = float4( _MainLightColor.rgb / ase_lightIntensity, ase_lightIntensity );
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( brdf527 * ( ase_lightColor.rgb * ase_lightAtten ) * NdotL357 * PI );
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
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
			#define ASE_SRP_VERSION 140011

			
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

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
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BumpMap_ST;
			float4 _MetallicGlossMap_ST;
			float4 _BaseMap_ST;
			float4 _BaseColor;
			float _BumpScale;
			float _Smoothness;
			float _subsurface;
			float _sheen;
			float _sheenTint;
			float _Metallic;
			float _specular;
			float _specularTint;
			float _anisotropic;
			float _clearcoat;
			float _clearcoatGloss;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			

			
			float3 _LightDirection;
			float3 _LightPosition;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				
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

				
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
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
			#define ASE_SRP_VERSION 140011

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

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
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BumpMap_ST;
			float4 _MetallicGlossMap_ST;
			float4 _BaseMap_ST;
			float4 _BaseColor;
			float _BumpScale;
			float _Smoothness;
			float _subsurface;
			float _sheen;
			float _sheenTint;
			float _Metallic;
			float _specular;
			float _specularTint;
			float _anisotropic;
			float _clearcoat;
			float _clearcoatGloss;
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

				
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

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

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }
			
			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 140011

			
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
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ _FORWARD_PLUS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BumpMap_ST;
			float4 _MetallicGlossMap_ST;
			float4 _BaseMap_ST;
			float4 _BaseColor;
			float _BumpScale;
			float _Smoothness;
			float _subsurface;
			float _sheen;
			float _sheenTint;
			float _Metallic;
			float _specular;
			float _specularTint;
			float _anisotropic;
			float _clearcoat;
			float _clearcoatGloss;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _BumpMap;
			sampler2D _MetallicGlossMap;
			sampler2D _BaseMap;


			float3 TangentToWorld( float3 NormalTS, float3x3 TBN )
			{
				float3 NormalWS = TransformTangentToWorld(NormalTS, TBN);
				NormalWS = NormalizeNormalPerPixel(NormalWS);
				return NormalWS;
			}
			
			float3 ASESafeNormalize(float3 inVec)
			{
				float dp3 = max(1.175494351e-38, dot(inVec, inVec));
				return inVec* rsqrt(dp3);
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
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_tangent = v.ase_tangent;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
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
				float2 uv_BumpMap = IN.ase_texcoord3.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				float3 unpack4_g705 = UnpackNormalScale( tex2D( _BumpMap, uv_BumpMap ), _BumpScale );
				unpack4_g705.z = lerp( 1, unpack4_g705.z, saturate(_BumpScale) );
				float3 tex2DNode4_g705 = unpack4_g705;
				float3 NormalTS2_g706 = tex2DNode4_g705;
				float3 ase_worldTangent = IN.ase_texcoord4.xyz;
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 Binormal10_g705 = ( cross( ase_worldNormal , ase_worldTangent ) * sign( IN.ase_tangent.w ) );
				float3x3 TBN2_g706 = float3x3(ase_worldTangent, Binormal10_g705, ase_worldNormal);
				float3 localTangentToWorld2_g706 = TangentToWorld( NormalTS2_g706 , TBN2_g706 );
				float3 normalizeResult5_g706 = normalize( localTangentToWorld2_g706 );
				float3 temp_output_66_6_g705 = normalizeResult5_g706;
				float3 N157 = temp_output_66_6_g705;
				float3 temp_output_26_0_g695 = N157;
				float3 L549 = SafeNormalize(_MainLightPosition.xyz);
				float3 temp_output_27_0_g695 = L549;
				float dotResult12_g695 = dot( temp_output_26_0_g695 , temp_output_27_0_g695 );
				float NdotL357 = dotResult12_g695;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float3 V551 = ase_worldViewDir;
				float3 temp_output_28_0_g695 = V551;
				float3 normalizeResult22_g695 = ASESafeNormalize( ( temp_output_27_0_g695 + temp_output_28_0_g695 ) );
				float dotResult14_g695 = dot( temp_output_27_0_g695 , normalizeResult22_g695 );
				float LdotH367 = dotResult14_g695;
				float temp_output_1_0_g716 = LdotH367;
				float2 uv_MetallicGlossMap = IN.ase_texcoord3.xy * _MetallicGlossMap_ST.xy + _MetallicGlossMap_ST.zw;
				float4 tex2DNode4_g717 = tex2D( _MetallicGlossMap, uv_MetallicGlossMap );
				float smoothness68 = ( tex2DNode4_g717.a * _Smoothness );
				float roughness570 = ( 1.0 - smoothness68 );
				float Fss9014_g709 = ( ( temp_output_1_0_g716 * temp_output_1_0_g716 ) * roughness570 );
				float Fd9021_g709 = ( ( Fss9014_g709 * 2.0 ) + 0.5 );
				float temp_output_67_0_g709 = NdotL357;
				float clampResult3_g710 = clamp( ( 1.0 - temp_output_67_0_g709 ) , 0.0 , 1.0 );
				float temp_output_1_0_g711 = clampResult3_g710;
				float temp_output_1_0_g712 = ( temp_output_1_0_g711 * temp_output_1_0_g711 );
				float FL22_g709 = ( ( temp_output_1_0_g712 * temp_output_1_0_g712 ) * clampResult3_g710 );
				float lerpResult29_g709 = lerp( 1.0 , Fd9021_g709 , FL22_g709);
				float dotResult8_g695 = dot( temp_output_26_0_g695 , temp_output_28_0_g695 );
				float NdotV360 = dotResult8_g695;
				float temp_output_68_0_g709 = NdotV360;
				float clampResult3_g713 = clamp( ( 1.0 - temp_output_68_0_g709 ) , 0.0 , 1.0 );
				float temp_output_1_0_g714 = clampResult3_g713;
				float temp_output_1_0_g715 = ( temp_output_1_0_g714 * temp_output_1_0_g714 );
				float FV6_g709 = ( ( temp_output_1_0_g715 * temp_output_1_0_g715 ) * clampResult3_g713 );
				float lerpResult23_g709 = lerp( 1.0 , Fd9021_g709 , FV6_g709);
				float temp_output_24_0_g709 = ( lerpResult29_g709 * lerpResult23_g709 );
				float Fd76_g709 = temp_output_24_0_g709;
				float lerpResult10_g709 = lerp( 1.0 , Fss9014_g709 , FL22_g709);
				float lerpResult8_g709 = lerp( 1.0 , Fss9014_g709 , FV6_g709);
				float temp_output_34_0_g709 = ( lerpResult10_g709 * lerpResult8_g709 );
				float Fss15_g709 = temp_output_34_0_g709;
				float ss39_g709 = ( 1.25 * ( ( Fss15_g709 * ( ( 1.0 / ( temp_output_67_0_g709 + temp_output_68_0_g709 ) ) - 0.5 ) ) + 0.5 ) );
				float lerpResult44_g709 = lerp( Fd76_g709 , ss39_g709 , _subsurface);
				float2 uv_BaseMap = IN.ase_texcoord3.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;
				float4 albedo54 = ( tex2D( _BaseMap, uv_BaseMap ) * _BaseColor );
				float3 Cdlin3_g726 = (albedo54).rgb;
				float3 Cdlin756 = Cdlin3_g726;
				float clampResult3_g665 = clamp( ( 1.0 - LdotH367 ) , 0.0 , 1.0 );
				float temp_output_1_0_g666 = clampResult3_g665;
				float temp_output_1_0_g667 = ( temp_output_1_0_g666 * temp_output_1_0_g666 );
				float temp_output_83_0_g660 = ( ( temp_output_1_0_g667 * temp_output_1_0_g667 ) * clampResult3_g665 );
				float FH460 = temp_output_83_0_g660;
				float3 _vec3one = float3(1,1,1);
				float3 break37_g726 = ( Cdlin3_g726 * float3( 0.3,0.6,0.1 ) );
				float Cdlum7_g726 = ( break37_g726.x + break37_g726.y + break37_g726.z );
				float3 _Vector4 = float3(1,1,1);
				float3 ifLocalVar4_g726 = 0;
				if( Cdlum7_g726 <= 0.0 )
				ifLocalVar4_g726 = _Vector4;
				else
				ifLocalVar4_g726 = ( Cdlin3_g726 / Cdlum7_g726 );
				float3 Ctint12_g726 = ifLocalVar4_g726;
				float3 lerpResult25_g726 = lerp( _vec3one , Ctint12_g726 , _sheenTint);
				float3 Csheen17_g726 = lerpResult25_g726;
				float3 Csheen434 = Csheen17_g726;
				float3 Fsheen485 = ( FH460 * _sheen * Csheen434 );
				float metallic771 = ( tex2DNode4_g717.r * _Metallic );
				float3 lerpResult13_g726 = lerp( _vec3one , Ctint12_g726 , _specularTint);
				float3 lerpResult15_g726 = lerp( ( ( _specular * 0.08 ) * lerpResult13_g726 ) , Cdlin3_g726 , metallic771);
				float3 Cspec020_g726 = lerpResult15_g726;
				float3 Cspec0417 = Cspec020_g726;
				float FH22_g660 = temp_output_83_0_g660;
				float3 lerpResult3_g660 = lerp( Cspec0417 , float3( 1,1,1 ) , FH22_g660);
				float3 Fs71_g660 = lerpResult3_g660;
				float3 temp_output_56_0_g660 = L549;
				float3 NormalTS2_g707 = float3(1,0,0);
				float3x3 TBN2_g707 = float3x3(ase_worldTangent, Binormal10_g705, ase_worldNormal);
				float3 localTangentToWorld2_g707 = TangentToWorld( NormalTS2_g707 , TBN2_g707 );
				float3 normalizeResult5_g707 = normalize( localTangentToWorld2_g707 );
				float3 normalizeResult44_g705 = normalize( cross( temp_output_66_6_g705 , normalizeResult5_g707 ) );
				float3 X410 = cross( normalizeResult44_g705 , temp_output_66_6_g705 );
				float3 temp_output_54_0_g660 = X410;
				float dotResult13_g660 = dot( temp_output_56_0_g660 , temp_output_54_0_g660 );
				float temp_output_1_0_g668 = roughness570;
				float temp_output_62_0_g660 = ( temp_output_1_0_g668 * temp_output_1_0_g668 );
				float temp_output_19_0_g660 = sqrt( ( 1.0 - ( _anisotropic * 0.9 ) ) );
				float2 appendResult63_g660 = (float2(max( 0.001 , ( temp_output_62_0_g660 / temp_output_19_0_g660 ) ) , max( 0.001 , ( temp_output_62_0_g660 * temp_output_19_0_g660 ) )));
				float2 a25_g660 = appendResult63_g660;
				float2 break67_g660 = a25_g660;
				float temp_output_1_0_g664 = ( dotResult13_g660 * break67_g660.x );
				float3 Y407 = normalizeResult44_g705;
				float3 temp_output_55_0_g660 = Y407;
				float dotResult26_g660 = dot( temp_output_56_0_g660 , temp_output_55_0_g660 );
				float temp_output_1_0_g663 = ( dotResult26_g660 * break67_g660.y );
				float temp_output_2_0_g661 = NdotL357;
				float temp_output_1_0_g662 = temp_output_2_0_g661;
				float3 temp_output_57_0_g660 = V551;
				float dotResult20_g660 = dot( temp_output_57_0_g660 , temp_output_54_0_g660 );
				float2 break69_g660 = a25_g660;
				float temp_output_1_0_g681 = ( dotResult20_g660 * break69_g660.x );
				float dotResult27_g660 = dot( temp_output_57_0_g660 , temp_output_55_0_g660 );
				float temp_output_1_0_g680 = ( dotResult27_g660 * break69_g660.y );
				float temp_output_2_0_g678 = NdotV360;
				float temp_output_1_0_g679 = temp_output_2_0_g678;
				float Gs72_g660 = ( ( 1.0 / ( sqrt( ( ( temp_output_1_0_g664 * temp_output_1_0_g664 ) + ( temp_output_1_0_g663 * temp_output_1_0_g663 ) + ( temp_output_1_0_g662 * temp_output_1_0_g662 ) ) ) + temp_output_2_0_g661 ) ) * ( 1.0 / ( sqrt( ( ( temp_output_1_0_g681 * temp_output_1_0_g681 ) + ( temp_output_1_0_g680 * temp_output_1_0_g680 ) + ( temp_output_1_0_g679 * temp_output_1_0_g679 ) ) ) + temp_output_2_0_g678 ) ) );
				float2 break65_g660 = a25_g660;
				float temp_output_5_0_g673 = break65_g660.x;
				float temp_output_6_0_g673 = break65_g660.y;
				float3 H204 = normalizeResult22_g695;
				float3 temp_output_53_0_g660 = H204;
				float dotResult4_g660 = dot( temp_output_53_0_g660 , temp_output_54_0_g660 );
				float temp_output_1_0_g676 = ( dotResult4_g660 / temp_output_5_0_g673 );
				float dotResult33_g660 = dot( temp_output_53_0_g660 , temp_output_55_0_g660 );
				float temp_output_1_0_g675 = ( dotResult33_g660 / temp_output_6_0_g673 );
				float dotResult13_g695 = dot( temp_output_26_0_g695 , normalizeResult22_g695 );
				float NdotH366 = dotResult13_g695;
				float temp_output_52_0_g660 = NdotH366;
				float temp_output_1_0_g677 = temp_output_52_0_g660;
				float temp_output_1_0_g674 = ( ( temp_output_1_0_g676 * temp_output_1_0_g676 ) + ( temp_output_1_0_g675 * temp_output_1_0_g675 ) + ( temp_output_1_0_g677 * temp_output_1_0_g677 ) );
				float Ds73_g660 = ( 1.0 / ( ( temp_output_5_0_g673 * temp_output_6_0_g673 * ( temp_output_1_0_g674 * temp_output_1_0_g674 ) ) * PI ) );
				float temp_output_2_0_g692 = NdotL357;
				float temp_output_1_0_g694 = temp_output_2_0_g692;
				float temp_output_4_0_g692 = ( temp_output_1_0_g694 * temp_output_1_0_g694 );
				float temp_output_1_0_g693 = 0.25;
				float temp_output_5_0_g692 = ( temp_output_1_0_g693 * temp_output_1_0_g693 );
				float temp_output_2_0_g686 = NdotV360;
				float temp_output_1_0_g688 = temp_output_2_0_g686;
				float temp_output_4_0_g686 = ( temp_output_1_0_g688 * temp_output_1_0_g688 );
				float temp_output_1_0_g687 = 0.25;
				float temp_output_5_0_g686 = ( temp_output_1_0_g687 * temp_output_1_0_g687 );
				float temp_output_3_0_g685 = ( ( 1.0 / ( temp_output_2_0_g692 + sqrt( ( ( temp_output_4_0_g692 + temp_output_5_0_g692 ) - ( temp_output_4_0_g692 * temp_output_5_0_g692 ) ) ) ) ) * ( 1.0 / ( temp_output_2_0_g686 + sqrt( ( ( temp_output_4_0_g686 + temp_output_5_0_g686 ) - ( temp_output_4_0_g686 * temp_output_5_0_g686 ) ) ) ) ) );
				float lerpResult9_g685 = lerp( 0.04 , 1.0 , FH460);
				float lerpResult14_g685 = lerp( 0.1 , 0.001 , _clearcoatGloss);
				float temp_output_3_0_g689 = lerpResult14_g685;
				float temp_output_5_0_g689 = ( 1.0 / PI );
				float temp_output_1_0_g690 = temp_output_3_0_g689;
				float temp_output_7_0_g689 = ( temp_output_1_0_g690 * temp_output_1_0_g690 );
				float a2Minus112_g689 = ( temp_output_7_0_g689 - 1.0 );
				float temp_output_1_0_g691 = NdotH366;
				float ifLocalVar4_g689 = 0;
				if( temp_output_3_0_g689 >= 1.0 )
				ifLocalVar4_g689 = temp_output_5_0_g689;
				else
				ifLocalVar4_g689 = ( a2Minus112_g689 / ( ( ( a2Minus112_g689 * ( temp_output_1_0_g691 * temp_output_1_0_g691 ) ) + 1.0 ) * ( log( temp_output_7_0_g689 ) * PI ) ) );
				float temp_output_19_0_g685 = ifLocalVar4_g689;
				float3 temp_output_515_0 = ( ( ( ( ( 1.0 / PI ) * lerpResult44_g709 * Cdlin756 ) + Fsheen485 ) * ( 1.0 - metallic771 ) ) + ( Fs71_g660 * Gs72_g660 * Ds73_g660 ) + ( 0.25 * _clearcoat * temp_output_3_0_g685 * lerpResult9_g685 * temp_output_19_0_g685 ) );
				float3 ifLocalVar769 = 0;
				if( NdotL357 >= 0.0 )
				ifLocalVar769 = temp_output_515_0;
				else
				ifLocalVar769 = float3(0,0,0);
				float3 brdf527 = ifLocalVar769;
				float ase_lightIntensity = max( max( _MainLightColor.r, _MainLightColor.g ), _MainLightColor.b );
				float4 ase_lightColor = float4( _MainLightColor.rgb / ase_lightIntensity, ase_lightIntensity );
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( brdf527 * ( ase_lightColor.rgb * ase_lightAtten ) * NdotL357 * PI );
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
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
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }
        
			Cull Off

			HLSLPROGRAM
        
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 140011

        
			#pragma only_renderers d3d11 glcore gles gles3 ps5 
			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _BumpMap_ST;
			float4 _MetallicGlossMap_ST;
			float4 _BaseMap_ST;
			float4 _BaseColor;
			float _BumpScale;
			float _Smoothness;
			float _subsurface;
			float _sheen;
			float _sheenTint;
			float _Metallic;
			float _specular;
			float _specularTint;
			float _anisotropic;
			float _clearcoat;
			float _clearcoatGloss;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			

			
			int _ObjectId;
			int _PassValue;

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

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
				o.clipPos = TransformWorldToHClip(positionWS);
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
			
			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				
				surfaceDescription.Alpha = 1;
				surfaceDescription.AlphaClipThreshold = 0.5;


				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				return outColor;
			}

			ENDHLSL
        }

		
        Pass
        {
			
            Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }
        
			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 140011


			#pragma only_renderers d3d11 glcore gles gles3 ps5 
			#pragma vertex vert
			#pragma fragment frag

        
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY
			

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _BumpMap_ST;
			float4 _MetallicGlossMap_ST;
			float4 _BaseMap_ST;
			float4 _BaseColor;
			float _BumpScale;
			float _Smoothness;
			float _subsurface;
			float _sheen;
			float _sheenTint;
			float _Metallic;
			float _specular;
			float _specularTint;
			float _anisotropic;
			float _clearcoat;
			float _clearcoatGloss;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			

			
        
			float4 _SelectionID;

        
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

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
				o.clipPos = TransformWorldToHClip(positionWS);
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

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				
				surfaceDescription.Alpha = 1;
				surfaceDescription.AlphaClipThreshold = 0.5;


				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;
				outColor = _SelectionID;
				
				return outColor;
			}
        
			ENDHLSL
        }
		
		
        Pass
        {
			
            Name "DepthNormals"
            Tags { "LightMode"="DepthNormalsOnly" }

			ZTest LEqual
			ZWrite On

        
			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 140011

			
			#pragma only_renderers d3d11 glcore gles gles3 ps5 
			#pragma multi_compile_fog
			#pragma instancing_options renderinglayer
			#pragma vertex vert
			#pragma fragment frag

        
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define VARYINGS_NEED_NORMAL_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _BumpMap_ST;
			float4 _MetallicGlossMap_ST;
			float4 _BaseMap_ST;
			float4 _BaseColor;
			float _BumpScale;
			float _Smoothness;
			float _subsurface;
			float _sheen;
			float _sheenTint;
			float _Metallic;
			float _specular;
			float _specularTint;
			float _anisotropic;
			float _clearcoat;
			float _clearcoatGloss;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			

			      
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

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
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;

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

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				
				surfaceDescription.Alpha = 1;
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 normalWS = IN.normalWS;
				return half4(NormalizeNormalPerPixel(normalWS), 0.0);

			}
        
			ENDHLSL
        }

		
        Pass
        {
			
            Name "DepthNormalsOnly"
            Tags { "LightMode"="DepthNormalsOnly" }
        
			ZTest LEqual
			ZWrite On
        
        
			HLSLPROGRAM
        
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 140011

        
			#pragma exclude_renderers glcore gles gles3 
			#pragma vertex vert
			#pragma fragment frag
        
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD1
			#define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TANGENT_WS
        
			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _BumpMap_ST;
			float4 _MetallicGlossMap_ST;
			float4 _BaseMap_ST;
			float4 _BaseColor;
			float _BumpScale;
			float _Smoothness;
			float _subsurface;
			float _sheen;
			float _sheenTint;
			float _Metallic;
			float _specular;
			float _specularTint;
			float _anisotropic;
			float _clearcoat;
			float _clearcoatGloss;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			

			
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
      
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

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
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;
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

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				
				surfaceDescription.Alpha = 1;
				surfaceDescription.AlphaClipThreshold = 0.5;
				
				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 normalWS = IN.normalWS;
				return half4(NormalizeNormalPerPixel(normalWS), 0.0);

			}

			ENDHLSL
        }
		
	}
	
	CustomEditor "ASEMaterialInspector"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=19303
Node;AmplifyShaderEditor.CommentaryNode;734;-719.5773,-771.3005;Inherit;False;1303.8;568.2081;Comment;11;356;366;354;357;204;360;359;549;727;551;367;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;733;-727.2612,-1353.138;Inherit;False;622.14;330.7514;Comment;3;407;157;410;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;731;-752.1053,-1944.884;Inherit;False;440.0282;166.6353;Comment;2;728;54;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;732;-743.4272,-1730.612;Inherit;False;1408.564;348.2839;Comment;5;729;570;68;569;771;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;777;1502.344,-591.0737;Inherit;False;Disney BRDF Specular;-1;;660;36a0b41cf43f5b340af899aa45c19a67;0;12;57;FLOAT3;0,0,0;False;56;FLOAT3;0,0,0;False;53;FLOAT3;0,0,0;False;59;FLOAT;0;False;58;FLOAT;0;False;52;FLOAT;0;False;49;FLOAT;0;False;54;FLOAT3;0,0,0;False;55;FLOAT3;0,0,0;False;50;FLOAT3;0,0,0;False;60;FLOAT;0;False;61;FLOAT;0;False;5;FLOAT3;77;FLOAT;51;FLOAT;0;FLOAT3;47;FLOAT;44
Node;AmplifyShaderEditor.FunctionNode;746;1859.693,-1803.385;Inherit;False;Disney BRDF Sheen;-1;;682;c915a5fe22443744fa58b32272615eeb;0;3;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;509;1562.446,-1111.383;Inherit;False;756;Cdlin;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;515;2531.082,-642.1909;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;394;1019.042,-64.67679;Inherit;False;Property;_anisotropic;anisotropic;15;0;Create;True;0;0;0;False;0;False;0;0.791;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;398;1548.151,349.2343;Inherit;False;Property;_clearcoatGloss;clearcoatGloss;17;0;Create;True;0;0;0;False;0;False;1;0.823;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;410;-360.1966,-1213.408;Inherit;False;X;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;527;2982.787,-662.8423;Inherit;False;brdf;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;157;-359.7741,-1293.285;Inherit;False;N;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;579;2534.872,-740.835;Inherit;False;357;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;393;1518.336,-760.4116;Inherit;False;Property;_subsurface;subsurface;10;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;511;1557.896,-1032.924;Inherit;False;485;Fsheen;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;499;1666.48,-142.3743;Inherit;False;360;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;514;1554.803,-929.1888;Inherit;False;771;metallic;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;369;1039.279,-488.9718;Inherit;False;367;LdotH;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;756;2165.086,-2327.004;Inherit;False;Cdlin;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;567;1023.601,-560.5417;Inherit;False;366;NdotH;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;767;1149.3,688.8455;Inherit;False;527;brdf;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;771;-328.1299,-1625.542;Inherit;False;metallic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;774;1426.065,-2497.277;Inherit;False;771;metallic;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;584;1569.316,-1290.156;Inherit;False;357;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;549;-214.421,-435.9432;Inherit;False;L;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;770;2527.28,-309.5823;Inherit;False;Constant;_zero;zero;14;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;396;1380.363,-2119.526;Inherit;False;Property;_sheenTint;sheenTint;14;0;Create;True;0;0;0;False;0;False;0.5;0.522;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;540;1031.76,-157.5717;Inherit;False;417;Cspec0;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;571;1048.666,36.84109;Inherit;False;570;roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;585;1571.412,-1368.309;Inherit;False;360;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;434;2164.131,-2156.988;Inherit;False;Csheen;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;544;1026.984,-726.3867;Inherit;False;360;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;576;1538.454,-851.981;Inherit;False;570;roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;558;1018.105,-966.8997;Inherit;False;551;V;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;561;1007.756,-282.3337;Inherit;False;407;Y;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ConditionalIfNode;769;2766.968,-698.7419;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;460;1787.07,-507.5378;Inherit;False;FH;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;554;1031.03,-886.4198;Inherit;False;549;L;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;366;349.7451,-473.2453;Inherit;False;NdotH;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;367;360.2228,-386.2465;Inherit;False;LdotH;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;491;1666.791,29.11312;Inherit;False;366;NdotH;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;354;-198.8518,-672.6219;Inherit;False;157;N;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;781;940.6451,776.0521;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.FunctionNode;778;1977.007,-38.13974;Inherit;False;Disney BRDF Clearcoat;-1;;685;7d09539dbd4914e43a22489690ec8714;0;6;23;FLOAT;0;False;24;FLOAT;0;False;20;FLOAT;0;False;22;FLOAT;0;False;27;FLOAT;0;False;21;FLOAT;0;False;4;FLOAT;26;FLOAT;0;FLOAT;17;FLOAT;18
Node;AmplifyShaderEditor.RegisterLocalVarNode;485;2103.437,-1793.994;Inherit;False;Fsheen;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;-309.2835,-1498.328;Inherit;False;smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;569;-54.75815,-1494.378;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;488;1591.105,-1682.733;Inherit;False;434;Csheen;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;754;1603.281,-1885.909;Inherit;False;460;FH;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;417;2165.444,-2247.494;Inherit;True;Cspec0;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;204;341.5894,-626.5013;Inherit;False;H;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;397;1555.206,253.1293;Inherit;False;Property;_clearcoat;clearcoat;16;0;Create;True;0;0;0;False;0;False;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;718;1376.897,741.3845;Inherit;False;4;4;0;FLOAT3;1,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;566;1022.941,-823.5609;Inherit;False;204;H;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;543;1029.834,-634.4118;Inherit;False;357;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;422;1572.888,-1195.166;Inherit;False;367;LdotH;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;727;31.08525,-623.4333;Inherit;False;Prepare Vector Dot;-1;;695;2f780be88ea50455a83dc8bc41b86762;0;3;26;FLOAT3;0,0,0;False;28;FLOAT3;0,0,0;False;27;FLOAT3;0,0,0;False;7;FLOAT;0;FLOAT3;4;FLOAT;29;FLOAT;3;FLOAT;30;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;391;1380.186,-2212.87;Inherit;False;Property;_specularTint;specularTint;12;0;Create;True;0;0;0;False;0;False;0;0.769;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;494;1668.475,117.66;Inherit;False;460;FH;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;551;-213.0071,-587.2619;Inherit;False;V;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;782;1172.645,817.6519;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;395;1551.498,-1770.777;Inherit;False;Property;_sheen;sheen;13;0;Create;True;0;0;0;False;0;False;0;0.324;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;798;1140.772,1059.501;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;360;339.6786,-716.2441;Inherit;False;NdotV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;560;1017.059,-383.6758;Inherit;False;410;X;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;719;1150.099,958.8653;Inherit;False;357;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;780;906.2905,899.5372;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;357;346.9094,-548.8211;Inherit;False;NdotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;356;-424.3094,-430.8531;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;377;1426.215,-2413.397;Inherit;False;54;albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;811;-691.561,-1306.917;Inherit;False;NormalMap;7;;705;b0ef4d48b16014f17b95574653749cce;0;0;8;FLOAT3;0;FLOAT3;26;FLOAT3;48;FLOAT3;49;FLOAT3;5;FLOAT3;24;FLOAT3;34;FLOAT3;35
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-536.0771,-1894.248;Inherit;False;albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;407;-359.2206,-1135.253;Inherit;False;Y;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;359;-396.4868,-600.0368;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;498;1663.982,-53.21054;Inherit;False;357;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;788;1901.335,-1066.235;Inherit;False;Disney BRDF Diffuse;-1;;709;60560db886c1d174080a69c82b4c1c15;0;8;68;FLOAT;0;False;67;FLOAT;0;False;65;FLOAT;0;False;62;FLOAT3;0,0,0;False;61;FLOAT3;0,0,0;False;60;FLOAT;0;False;66;FLOAT;0;False;64;FLOAT;0;False;4;FLOAT3;59;FLOAT;0;FLOAT;56;FLOAT;58
Node;AmplifyShaderEditor.FunctionNode;729;-693.4272,-1589.815;Inherit;False;MetallicSmoothnessMap;3;;717;b081518771e9345b185fb949e9a644ae;0;0;2;FLOAT;0;FLOAT;8
Node;AmplifyShaderEditor.RegisterLocalVarNode;570;98.89215,-1502.346;Inherit;False;roughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;728;-702.1053,-1894.884;Inherit;False;AlbedoMap;0;;718;b35e8330e63694ba0b5348c6741e58ca;0;0;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;820;1831.438,-2265.082;Inherit;False;Disney BRDF Init;-1;;726;97c53e24e6f9fa5488c75a3886189e92;0;5;34;FLOAT;0;False;32;COLOR;1,1,1,1;False;31;FLOAT;0.5;False;30;FLOAT;0;False;29;FLOAT;0.5;False;4;FLOAT3;0;FLOAT3;33;FLOAT3;27;FLOAT3;28
Node;AmplifyShaderEditor.RangedFloatNode;389;1377.905,-2302.45;Inherit;False;Property;_specular;specular;11;0;Create;True;0;0;0;False;0;False;0;0.469;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;317;2546.219,316.5667;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;17;New Amplify Shader;9a54fbfe5a07e9e44b580fb887c56c32;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;314;1623.409,740.1063;Float;False;True;-1;2;ASEMaterialInspector;0;18;Farl/DisneyBRDF;9a54fbfe5a07e9e44b580fb887c56c32;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;0;0;  Blend;0;0;Two Sided;1;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;0;637904730196918264;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;True;True;False;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;318;2546.219,316.5667;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;17;New Amplify Shader;9a54fbfe5a07e9e44b580fb887c56c32;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;321;2546.219,316.5667;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;17;New Amplify Shader;9a54fbfe5a07e9e44b580fb887c56c32;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;5;d3d11;glcore;gles;gles3;ps5;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;322;2546.219,316.5667;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;17;New Amplify Shader;9a54fbfe5a07e9e44b580fb887c56c32;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;316;2546.219,316.5667;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;17;New Amplify Shader;9a54fbfe5a07e9e44b580fb887c56c32;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;320;2546.219,316.5667;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;17;New Amplify Shader;9a54fbfe5a07e9e44b580fb887c56c32;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;True;5;d3d11;glcore;gles;gles3;ps5;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;313;2094.871,523.803;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;17;New Amplify Shader;9a54fbfe5a07e9e44b580fb887c56c32;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;319;2546.219,316.5667;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;17;New Amplify Shader;9a54fbfe5a07e9e44b580fb887c56c32;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;True;5;d3d11;glcore;gles;gles3;ps5;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;315;2546.219,316.5667;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;17;New Amplify Shader;9a54fbfe5a07e9e44b580fb887c56c32;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;777;57;558;0
WireConnection;777;56;554;0
WireConnection;777;53;566;0
WireConnection;777;59;544;0
WireConnection;777;58;543;0
WireConnection;777;52;567;0
WireConnection;777;49;369;0
WireConnection;777;54;560;0
WireConnection;777;55;561;0
WireConnection;777;50;540;0
WireConnection;777;60;394;0
WireConnection;777;61;571;0
WireConnection;746;6;754;0
WireConnection;746;7;395;0
WireConnection;746;8;488;0
WireConnection;515;0;788;59
WireConnection;515;1;777;77
WireConnection;515;2;778;26
WireConnection;410;0;811;48
WireConnection;527;0;769;0
WireConnection;157;0;811;26
WireConnection;756;0;820;33
WireConnection;771;0;729;0
WireConnection;549;0;356;0
WireConnection;434;0;820;28
WireConnection;769;0;579;0
WireConnection;769;2;515;0
WireConnection;769;3;515;0
WireConnection;769;4;770;0
WireConnection;460;0;777;51
WireConnection;366;0;727;3
WireConnection;367;0;727;1
WireConnection;778;23;499;0
WireConnection;778;24;498;0
WireConnection;778;20;491;0
WireConnection;778;22;494;0
WireConnection;778;27;397;0
WireConnection;778;21;398;0
WireConnection;485;0;746;0
WireConnection;68;0;729;8
WireConnection;569;0;68;0
WireConnection;417;0;820;27
WireConnection;204;0;727;4
WireConnection;718;0;767;0
WireConnection;718;1;782;0
WireConnection;718;2;719;0
WireConnection;718;3;798;0
WireConnection;727;26;354;0
WireConnection;727;28;551;0
WireConnection;727;27;549;0
WireConnection;551;0;359;0
WireConnection;782;0;781;1
WireConnection;782;1;780;0
WireConnection;360;0;727;0
WireConnection;357;0;727;29
WireConnection;54;0;728;0
WireConnection;407;0;811;49
WireConnection;788;68;585;0
WireConnection;788;67;584;0
WireConnection;788;65;422;0
WireConnection;788;62;509;0
WireConnection;788;61;511;0
WireConnection;788;60;514;0
WireConnection;788;66;576;0
WireConnection;788;64;393;0
WireConnection;570;0;569;0
WireConnection;820;34;774;0
WireConnection;820;32;377;0
WireConnection;820;31;389;0
WireConnection;820;30;391;0
WireConnection;820;29;396;0
WireConnection;314;2;718;0
ASEEND*/
//CHKSM=3EA67D64683044B911FCF3356D9962D831C8DAA0