// Made with Amplify Shader Editor v1.9.3.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Farl/LiveWaving2D"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_Count("Count", Int) = 30
		_GradientTexA("Gradient Tex A", 2D) = "white" {}
		_LineAHalfWidth("Line A Half Width", Range( 0 , 0.1)) = 0.01
		_LineATimeScaleAmpAlphaIntensity("Line A (TimeScale, Amp, Alpha, Intensity)", Vector) = (0,0,0,0)
		_LineA1FrequencySpeed("Line A1 (Frequency, Speed)", Vector) = (2,4,3,5)
		_LineA2FrequencySpeed("Line A2 (Frequency, Speed)", Vector) = (2,4,3,5)
		_GradientTexB("Gradient Tex B", 2D) = "white" {}
		_LineBHalfWidth("Line B Half Width", Range( 0 , 0.1)) = 0.01
		_LineBTimeScaleAmpAlphaIntensity("Line B (TimeScale, Amp, Alpha, Intensity)", Vector) = (0,0,0,0)
		_LineB1FrequencySpeed("Line B1 (Frequency, Speed)", Vector) = (2,4,3,5)
		_LineB2FrequencySpeed("Line B2 (Frequency, Speed)", Vector) = (2,4,3,5)
		_GradientTexC("Gradient Tex C", 2D) = "white" {}
		_LineCHalfWidth("Line C Half Width", Range( 0 , 0.1)) = 0.01
		_LineCTimeScaleAmpAlphaIntensity("Line C (TimeScale, Amp, Alpha, Intensity)", Vector) = (0,0,0,0)
		_LineC1FrequencySpeed("Line C1 (Frequency, Speed)", Vector) = (2,4,3,5)
		_LineC2FrequencySpeed("Line C2 (Frequency, Speed)", Vector) = (2,4,3,5)
		_WarpFreqAmpSpeed("Warp (Freq, Amp, Speed)", Vector) = (0,0,0,0)
		[NoScaleOffset][SingleLineTexture]_Position("Position", 2D) = "black" {}
		_ClickForce("Click Force", Float) = 1
		[Toggle]_Debug("Debug", Float) = 1
		_OverallAmplitude("Overall Amplitude", Float) = 0
		_DesityFrequence("Desity Frequence", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}


		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}

		[HideInInspector][ToggleOff] _ReceiveShadows("Receive Shadows", Float) = 1.0
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" "UniversalMaterialType"="Unlit" }

		Cull Back
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 4.5
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

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
			#pragma instancing_options renderinglayer
			#define ASE_SRP_VERSION 140011


			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3

			

			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fragment _ DEBUG_DISPLAY

			

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_UNLIT

			
            #if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#endif
		

			
			#if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#endif
		

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			

			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 positionWS : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
					float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _GradientTexA_ST;
			float4 _LineC2FrequencySpeed;
			float4 _LineC1FrequencySpeed;
			float4 _LineCTimeScaleAmpAlphaIntensity;
			float4 _GradientTexB_ST;
			float4 _LineB2FrequencySpeed;
			float4 _LineB1FrequencySpeed;
			float4 _LineBTimeScaleAmpAlphaIntensity;
			float4 _GradientTexC_ST;
			float4 _LineA2FrequencySpeed;
			float4 _LineA1FrequencySpeed;
			float4 _LineATimeScaleAmpAlphaIntensity;
			float3 _WarpFreqAmpSpeed;
			float _DesityFrequence;
			float _LineCHalfWidth;
			float _ClickForce;
			float _LineBHalfWidth;
			float _OverallAmplitude;
			int _Count;
			float _LineAHalfWidth;
			float _Debug;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Position;
			sampler2D _GradientTexA;
			sampler2D _GradientTexB;
			sampler2D _GradientTexC;


			float SmoothLine( float t, float pos, float halfWidth )
			{
				//return smoothstep(halfWidth, 0, abs(t - pos));
				float tmp = abs(t - pos);
				return 1 * exp(-pow(tmp,0.5) / halfWidth);
			}
			
			float FourierRandom( float t, float2 v )
			{
				return  (cos(t) + cos(t * v.x + v.x) + cos(t * v.y + v.y)) / 3;
			}
			
			float2 Warp37_g40( float2 pos, float amplitude, float frequency, float speed, float2 randSeed, float t )
			{
				pos.x += FourierRandom(pos.y * frequency + t * speed, randSeed) * amplitude;
				pos.y += FourierRandom(pos.x * frequency + t * speed, randSeed) * amplitude;
				return pos;
			}
			
			float DrawLine1_g40( int count, float2 pos, float2 randSeed1, float2 randSeed2, float2 frequency1, float2 frequency2, float2 speed1, float2 speed2, float t, float amplitude, float Intensity, float minAlpha, float halfWidth, float densityFrequency )
			{
				float l = 0;
				float f = 0;
				float2 rand1;
				float2 rand2;
				float fade = 0;
				float fade2 = 0;
				for (int i = 0; i < count; i++)
				{
					f = (float)i / (float)(count -1.0);
					f = smoothstep(0.0, 1.0, f);
					fade = abs(f * 2.0 - 1.0);
					fade2 = fade * (1 - minAlpha) + minAlpha;
					fade2 *= 1 - (1 - fade) * (FourierRandom(f * densityFrequency, randSeed1) * 0.5 + 0.5);
					rand1.x = FourierRandom(pos.x * frequency1.x + t * speed1.x, randSeed1);
					rand1.y = FourierRandom(pos.x * frequency1.y + t * speed1.y, randSeed1);
					rand2.x = FourierRandom(pos.x * frequency2.x + t * speed2.x, randSeed2);
					rand2.y = FourierRandom(pos.x * frequency2.y + t * speed2.y, randSeed2);
					
					float v = lerp( rand1.x + rand1.y, rand2.x + rand2.y, f );
					v *= amplitude;
					l += SmoothLine(pos.y, v, halfWidth) * Intensity * fade2;
				}
				return l / count;
			}
			
			float2 Warp37_g41( float2 pos, float amplitude, float frequency, float speed, float2 randSeed, float t )
			{
				pos.x += FourierRandom(pos.y * frequency + t * speed, randSeed) * amplitude;
				pos.y += FourierRandom(pos.x * frequency + t * speed, randSeed) * amplitude;
				return pos;
			}
			
			float DrawLine1_g41( int count, float2 pos, float2 randSeed1, float2 randSeed2, float2 frequency1, float2 frequency2, float2 speed1, float2 speed2, float t, float amplitude, float Intensity, float minAlpha, float halfWidth, float densityFrequency )
			{
				float l = 0;
				float f = 0;
				float2 rand1;
				float2 rand2;
				float fade = 0;
				float fade2 = 0;
				for (int i = 0; i < count; i++)
				{
					f = (float)i / (float)(count -1.0);
					f = smoothstep(0.0, 1.0, f);
					fade = abs(f * 2.0 - 1.0);
					fade2 = fade * (1 - minAlpha) + minAlpha;
					fade2 *= 1 - (1 - fade) * (FourierRandom(f * densityFrequency, randSeed1) * 0.5 + 0.5);
					rand1.x = FourierRandom(pos.x * frequency1.x + t * speed1.x, randSeed1);
					rand1.y = FourierRandom(pos.x * frequency1.y + t * speed1.y, randSeed1);
					rand2.x = FourierRandom(pos.x * frequency2.x + t * speed2.x, randSeed2);
					rand2.y = FourierRandom(pos.x * frequency2.y + t * speed2.y, randSeed2);
					
					float v = lerp( rand1.x + rand1.y, rand2.x + rand2.y, f );
					v *= amplitude;
					l += SmoothLine(pos.y, v, halfWidth) * Intensity * fade2;
				}
				return l / count;
			}
			
			float2 Warp37_g42( float2 pos, float amplitude, float frequency, float speed, float2 randSeed, float t )
			{
				pos.x += FourierRandom(pos.y * frequency + t * speed, randSeed) * amplitude;
				pos.y += FourierRandom(pos.x * frequency + t * speed, randSeed) * amplitude;
				return pos;
			}
			
			float DrawLine1_g42( int count, float2 pos, float2 randSeed1, float2 randSeed2, float2 frequency1, float2 frequency2, float2 speed1, float2 speed2, float t, float amplitude, float Intensity, float minAlpha, float halfWidth, float densityFrequency )
			{
				float l = 0;
				float f = 0;
				float2 rand1;
				float2 rand2;
				float fade = 0;
				float fade2 = 0;
				for (int i = 0; i < count; i++)
				{
					f = (float)i / (float)(count -1.0);
					f = smoothstep(0.0, 1.0, f);
					fade = abs(f * 2.0 - 1.0);
					fade2 = fade * (1 - minAlpha) + minAlpha;
					fade2 *= 1 - (1 - fade) * (FourierRandom(f * densityFrequency, randSeed1) * 0.5 + 0.5);
					rand1.x = FourierRandom(pos.x * frequency1.x + t * speed1.x, randSeed1);
					rand1.y = FourierRandom(pos.x * frequency1.y + t * speed1.y, randSeed1);
					rand2.x = FourierRandom(pos.x * frequency2.x + t * speed2.x, randSeed2);
					rand2.y = FourierRandom(pos.x * frequency2.y + t * speed2.y, randSeed2);
					
					float v = lerp( rand1.x + rand1.y, rand2.x + rand2.y, f );
					v *= amplitude;
					l += SmoothLine(pos.y, v, halfWidth) * Intensity * fade2;
				}
				return l / count;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				float3 positionWS = TransformObjectToWorld( v.positionOS.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.positionWS = positionWS;
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

				o.positionCS = positionCS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

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
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.ase_texcoord = v.ase_texcoord;
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
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
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

			half4 frag ( VertexOutput IN
				#ifdef _WRITE_RENDERING_LAYERS
				, out float4 outRenderingLayers : SV_Target1
				#endif
				 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				int lineCount106 = _Count;
				int count1_g40 = lineCount106;
				float2 texCoord145 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 pos155 = (float2( -1,-1 ) + (texCoord145 - float2( 0,0 )) * (float2( 1,1 ) - float2( -1,-1 )) / (float2( 1,1 ) - float2( 0,0 )));
				float2 pos37_g40 = pos155;
				float amp198 = _OverallAmplitude;
				float3 appendResult207 = (float3(_WarpFreqAmpSpeed.x , ( _WarpFreqAmpSpeed.y * amp198 ) , _WarpFreqAmpSpeed.z));
				float3 warp208 = appendResult207;
				float3 break211 = warp208;
				float amplitude37_g40 = break211.y;
				float frequency37_g40 = break211.x;
				float speed37_g40 = break211.z;
				float2 randSeed37_g40 = float2( 1.3,1.4 );
				float mulTime52 = _TimeParameters.x * _LineATimeScaleAmpAlphaIntensity.x;
				float t32_g40 = mulTime52;
				float t37_g40 = t32_g40;
				float2 localWarp37_g40 = Warp37_g40( pos37_g40 , amplitude37_g40 , frequency37_g40 , speed37_g40 , randSeed37_g40 , t37_g40 );
				float2 pos1_g40 = localWarp37_g40;
				float2 randSeed11_g40 = float2( 1.3,1.4 );
				float2 randSeed21_g40 = float2( 1.5,1.6 );
				float2 appendResult84 = (float2(_LineA1FrequencySpeed.x , _LineA1FrequencySpeed.y));
				float2 frequency11_g40 = appendResult84;
				float2 appendResult87 = (float2(_LineA2FrequencySpeed.x , _LineA2FrequencySpeed.y));
				float2 frequency21_g40 = appendResult87;
				float2 appendResult85 = (float2(_LineA1FrequencySpeed.z , _LineA1FrequencySpeed.w));
				float2 uv_Position134 = IN.ase_texcoord3.xy;
				float temp_output_150_0 = (-1.0 + (tex2D( _Position, uv_Position134 ).g - 0.0) * (1.0 - -1.0) / (1.0 - 0.0));
				float2 interact190 = (( temp_output_150_0 * _ClickForce )).xx;
				float2 speed11_g40 = ( appendResult85 + interact190 );
				float2 appendResult88 = (float2(_LineA2FrequencySpeed.z , _LineA2FrequencySpeed.w));
				float2 speed21_g40 = ( appendResult88 + interact190 );
				float t1_g40 = t32_g40;
				float amplitude1_g40 = ( _LineATimeScaleAmpAlphaIntensity.y * amp198 );
				float Intensity1_g40 = _LineATimeScaleAmpAlphaIntensity.w;
				float minAlpha1_g40 = _LineATimeScaleAmpAlphaIntensity.z;
				float halfWidth1_g40 = _LineAHalfWidth;
				float densityFreq289 = _DesityFrequence;
				float densityFrequency1_g40 = densityFreq289;
				float localDrawLine1_g40 = DrawLine1_g40( count1_g40 , pos1_g40 , randSeed11_g40 , randSeed21_g40 , frequency11_g40 , frequency21_g40 , speed11_g40 , speed21_g40 , t1_g40 , amplitude1_g40 , Intensity1_g40 , minAlpha1_g40 , halfWidth1_g40 , densityFrequency1_g40 );
				float lineA59 = localDrawLine1_g40;
				float2 uv_GradientTexA = IN.ase_texcoord3.xy * _GradientTexA_ST.xy + _GradientTexA_ST.zw;
				int count1_g41 = lineCount106;
				float2 pos37_g41 = pos155;
				float3 break213 = warp208;
				float amplitude37_g41 = break213.y;
				float frequency37_g41 = break213.x;
				float speed37_g41 = break213.z;
				float2 randSeed37_g41 = float2( 1.3,1.4 );
				float mulTime115 = _TimeParameters.x * _LineBTimeScaleAmpAlphaIntensity.x;
				float t32_g41 = mulTime115;
				float t37_g41 = t32_g41;
				float2 localWarp37_g41 = Warp37_g41( pos37_g41 , amplitude37_g41 , frequency37_g41 , speed37_g41 , randSeed37_g41 , t37_g41 );
				float2 pos1_g41 = localWarp37_g41;
				float2 randSeed11_g41 = float2( 1.3,1.4 );
				float2 randSeed21_g41 = float2( 1.5,1.6 );
				float2 appendResult97 = (float2(_LineB1FrequencySpeed.x , _LineB1FrequencySpeed.y));
				float2 frequency11_g41 = appendResult97;
				float2 appendResult100 = (float2(_LineB2FrequencySpeed.x , _LineB2FrequencySpeed.y));
				float2 frequency21_g41 = appendResult100;
				float2 appendResult98 = (float2(_LineB1FrequencySpeed.z , _LineB1FrequencySpeed.w));
				float2 speed11_g41 = ( appendResult98 + interact190 );
				float2 appendResult101 = (float2(_LineB2FrequencySpeed.z , _LineB2FrequencySpeed.w));
				float2 speed21_g41 = ( appendResult101 + interact190 );
				float t1_g41 = t32_g41;
				float amplitude1_g41 = ( _LineBTimeScaleAmpAlphaIntensity.y * amp198 );
				float Intensity1_g41 = _LineBTimeScaleAmpAlphaIntensity.w;
				float minAlpha1_g41 = _LineBTimeScaleAmpAlphaIntensity.z;
				float halfWidth1_g41 = _LineBHalfWidth;
				float densityFrequency1_g41 = densityFreq289;
				float localDrawLine1_g41 = DrawLine1_g41( count1_g41 , pos1_g41 , randSeed11_g41 , randSeed21_g41 , frequency11_g41 , frequency21_g41 , speed11_g41 , speed21_g41 , t1_g41 , amplitude1_g41 , Intensity1_g41 , minAlpha1_g41 , halfWidth1_g41 , densityFrequency1_g41 );
				float lineB93 = localDrawLine1_g41;
				float2 uv_GradientTexB = IN.ase_texcoord3.xy * _GradientTexB_ST.xy + _GradientTexB_ST.zw;
				int count1_g42 = lineCount106;
				float2 pos37_g42 = pos155;
				float3 break215 = warp208;
				float amplitude37_g42 = break215.y;
				float frequency37_g42 = break215.x;
				float speed37_g42 = break215.z;
				float2 randSeed37_g42 = float2( 1.3,1.4 );
				float mulTime180 = _TimeParameters.x * _LineCTimeScaleAmpAlphaIntensity.x;
				float t32_g42 = mulTime180;
				float t37_g42 = t32_g42;
				float2 localWarp37_g42 = Warp37_g42( pos37_g42 , amplitude37_g42 , frequency37_g42 , speed37_g42 , randSeed37_g42 , t37_g42 );
				float2 pos1_g42 = localWarp37_g42;
				float2 randSeed11_g42 = float2( 1.3,1.4 );
				float2 randSeed21_g42 = float2( 1.5,1.6 );
				float2 appendResult182 = (float2(_LineC1FrequencySpeed.x , _LineC1FrequencySpeed.y));
				float2 frequency11_g42 = appendResult182;
				float2 appendResult185 = (float2(_LineC2FrequencySpeed.x , _LineC2FrequencySpeed.y));
				float2 frequency21_g42 = appendResult185;
				float2 appendResult183 = (float2(_LineC1FrequencySpeed.z , _LineC1FrequencySpeed.w));
				float2 speed11_g42 = ( appendResult183 + interact190 );
				float2 appendResult187 = (float2(_LineC2FrequencySpeed.z , _LineC2FrequencySpeed.w));
				float2 speed21_g42 = ( appendResult187 + interact190 );
				float t1_g42 = t32_g42;
				float amplitude1_g42 = ( _LineCTimeScaleAmpAlphaIntensity.y * amp198 );
				float Intensity1_g42 = _LineCTimeScaleAmpAlphaIntensity.w;
				float minAlpha1_g42 = _LineCTimeScaleAmpAlphaIntensity.z;
				float halfWidth1_g42 = _LineCHalfWidth;
				float densityFrequency1_g42 = densityFreq289;
				float localDrawLine1_g42 = DrawLine1_g42( count1_g42 , pos1_g42 , randSeed11_g42 , randSeed21_g42 , frequency11_g42 , frequency21_g42 , speed11_g42 , speed21_g42 , t1_g42 , amplitude1_g42 , Intensity1_g42 , minAlpha1_g42 , halfWidth1_g42 , densityFrequency1_g42 );
				float lineC184 = localDrawLine1_g42;
				float2 uv_GradientTexC = IN.ase_texcoord3.xy * _GradientTexC_ST.xy + _GradientTexC_ST.zw;
				float4 temp_cast_0 = (temp_output_150_0).xxxx;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = (( _Debug )?( temp_cast_0 ):( ( ( lineA59 * tex2D( _GradientTexA, uv_GradientTexA ) ) + ( lineB93 * tex2D( _GradientTexB, uv_GradientTexB ) ) + ( lineC184 * tex2D( _GradientTexC, uv_GradientTexC ) ) ) )).rgb;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.positionCS, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.positionCS );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
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
			#define ASE_SRP_VERSION 140011


			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

			

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			
            #if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#endif
		

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			

			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 positionWS : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _GradientTexA_ST;
			float4 _LineC2FrequencySpeed;
			float4 _LineC1FrequencySpeed;
			float4 _LineCTimeScaleAmpAlphaIntensity;
			float4 _GradientTexB_ST;
			float4 _LineB2FrequencySpeed;
			float4 _LineB1FrequencySpeed;
			float4 _LineBTimeScaleAmpAlphaIntensity;
			float4 _GradientTexC_ST;
			float4 _LineA2FrequencySpeed;
			float4 _LineA1FrequencySpeed;
			float4 _LineATimeScaleAmpAlphaIntensity;
			float3 _WarpFreqAmpSpeed;
			float _DesityFrequence;
			float _LineCHalfWidth;
			float _ClickForce;
			float _LineBHalfWidth;
			float _OverallAmplitude;
			int _Count;
			float _LineAHalfWidth;
			float _Debug;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			

			float SmoothLine( float t, float pos, float halfWidth )
			{
				//return smoothstep(halfWidth, 0, abs(t - pos));
				float tmp = abs(t - pos);
				return 1 * exp(-pow(tmp,0.5) / halfWidth);
			}
			
			float FourierRandom( float t, float2 v )
			{
				return  (cos(t) + cos(t * v.x + v.x) + cos(t * v.y + v.y)) / 3;
			}
			

			float3 _LightDirection;
			float3 _LightPosition;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				float3 positionWS = TransformObjectToWorld( v.positionOS.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.positionWS = positionWS;
				#endif

				float3 normalWS = TransformObjectToWorldDir( v.normalOS );

				#if _CASTING_PUNCTUAL_LIGHT_SHADOW
					float3 lightDirectionWS = normalize(_LightPosition - positionWS);
				#else
					float3 lightDirectionWS = _LightDirection;
				#endif

				float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

				#if UNITY_REVERSED_Z
					positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
				#else
					positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.positionCS = positionCS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				
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
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				
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
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
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
					float3 WorldPosition = IN.positionWS;
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
					LODFadeCrossFade( IN.positionCS );
				#endif

				return 0;
			}
			ENDHLSL
		}

	
	}
	
	CustomEditor "UnityEditor.ShaderGraphUnlitGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback "Hidden/InternalErrorShader"
}
/*ASEBEGIN
Version=19303
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;825.3606,-491.1763;Inherit;False;lineA;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;83;-365.4697,-508.3014;Inherit;False;Property;_LineA1FrequencySpeed;Line A1 (Frequency, Speed);4;0;Create;True;0;0;0;False;0;False;2,4,3,5;6,8,10,-15;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;213;355.0952,232.7169;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;175;-186.2939,2180.79;Inherit;False;Property;_LineCHalfWidth;Line C Half Width;12;0;Create;True;0;0;0;False;0;False;0.01;0.045;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;-32.03406,2273.575;Inherit;False;198;amp;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;211;363.7805,-681.671;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;98;-139.2334,520.0802;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;193;-174.2798,840.2676;Inherit;False;190;interact;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;212;188.3459,246.8484;Inherit;False;208;warp;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;99;-396.9787,627.2992;Inherit;False;Property;_LineB2FrequencySpeed;Line B2 (Frequency, Speed);10;0;Create;True;0;0;0;False;0;False;2,4,3,5;2,10,10,-17;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;138;1751.588,-84.47549;Inherit;False;Property;_ClickForce;Click Force;18;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;205;1820.767,-824.3467;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-210.758,1145.176;Inherit;False;Property;_LineBHalfWidth;Line B Half Width;7;0;Create;True;0;0;0;False;0;False;0.01;0.041;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;291.8416,-559.9865;Inherit;False;106;lineCount;1;0;OBJECT;;False;1;INT;0
Node;AmplifyShaderEditor.TFHCRemapNode;146;-172.7823,-850.0023;Inherit;False;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;3;FLOAT2;-1,-1;False;4;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;108;-297.315,-48.55897;Inherit;False;Property;_LineATimeScaleAmpAlphaIntensity;Line A (TimeScale, Amp, Alpha, Intensity);3;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.03,1,0.2,20;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;176;217.0467,1391.284;Inherit;False;106;lineCount;1;0;OBJECT;;False;1;INT;0
Node;AmplifyShaderEditor.GetLocalVarNode;291;265.519,1152.704;Inherit;False;289;densityFreq;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;200;-120.976,218.4771;Inherit;False;198;amp;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;209;197.0314,-667.5396;Inherit;False;208;warp;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;201;225.5896,1034.125;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;168;-135.9904,-110.575;Inherit;False;190;interact;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;114;-228.537,952.3979;Inherit;False;Property;_LineBTimeScaleAmpAlphaIntensity;Line B (TimeScale, Amp, Alpha, Intensity);8;0;Create;True;0;0;0;False;0;False;0,0,0,0;-0.04,0.59,0.5,3.25;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;115;86.90655,799.4987;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-291.4833,134.2489;Inherit;False;Property;_LineAHalfWidth;Line A Half Width;2;0;Create;True;0;0;0;False;0;False;0.01;0.02;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;290;296.2267,43.2182;Inherit;False;289;densityFreq;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;289;1877.011,-458.7879;Inherit;False;densityFreq;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;288;1661.853,-455.2285;Inherit;False;Property;_DesityFrequence;Desity Frequence;21;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;101;-135.9787,712.2992;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;187;-111.5146,1747.914;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;97;-138.2334,427.0802;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;1428.7,463.5552;Inherit;False;93;lineB;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;287;546.6411,-495.4838;Inherit;False;LineWaving2D;-1;;40;ce9f2b5efc1f0b440b81179c80f401a4;0;17;22;FLOAT;1;False;23;FLOAT;0.1;False;24;FLOAT;0;False;5;INT;10;False;7;FLOAT2;0,0;False;10;FLOAT2;1.3,1.4;False;11;FLOAT2;1.5,1.6;False;12;FLOAT2;2,4;False;13;FLOAT2;3,5;False;14;FLOAT2;3,5;False;15;FLOAT2;2,4;False;6;FLOAT;0;False;16;FLOAT;1;False;17;FLOAT;0.5;False;18;FLOAT;1;False;8;FLOAT;0.05;False;38;FLOAT;500;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;180;111.3707,1835.114;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;181;-371.7693,1471.637;Inherit;False;Property;_LineC1FrequencySpeed;Line C1 (Frequency, Speed);14;0;Create;True;0;0;0;False;0;False;2,4,3,5;7,8,10,-10;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;177;-204.0729,1988.013;Inherit;False;Property;_LineCTimeScaleAmpAlphaIntensity;Line C (TimeScale, Amp, Alpha, Intensity);13;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.05,1,0.55,0.8;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;199;84.02405,-6.522949;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;179;-372.5146,1662.914;Inherit;False;Property;_LineC2FrequencySpeed;Line C2 (Frequency, Speed);15;0;Create;True;0;0;0;False;0;False;2,4,3,5;4,8,20,-21;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;738.1515,400.8507;Inherit;False;lineB;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;174;1439.662,815.3507;Inherit;False;184;lineC;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;1928.021,-194.4501;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;173;1312.063,927.6773;Inherit;True;Property;_GradientTexC;Gradient Tex C;11;0;Create;True;0;0;0;False;0;False;-1;None;74c90bc2aedb0a745bbef8c3a2cdaf8d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;116;271.0201,361.9439;Inherit;False;106;lineCount;1;0;OBJECT;;False;1;INT;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;230.8692,441.657;Inherit;False;155;pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;203;172.966,2048.574;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;169;96.72487,-410.2424;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;91;1300.785,543.2852;Inherit;True;Property;_GradientTexB;Gradient Tex B;6;0;Create;True;0;0;0;False;0;False;-1;None;44acf5ca3a05fc04f848a3b49128bff7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;202;20.58955,1259.125;Inherit;False;198;amp;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;1622.573,4.940077;Inherit;False;lineCount;-1;True;1;0;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;191;58.43536,540.6002;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;1622.623,446.1689;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;84;-112.4697,-490.3014;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;286;483.6656,404.048;Inherit;False;LineWaving2D;-1;;41;ce9f2b5efc1f0b440b81179c80f401a4;0;17;22;FLOAT;1;False;23;FLOAT;0.1;False;24;FLOAT;0;False;5;INT;10;False;7;FLOAT2;0,0;False;10;FLOAT2;1.3,1.4;False;11;FLOAT2;1.5,1.6;False;12;FLOAT2;2,4;False;13;FLOAT2;3,5;False;14;FLOAT2;3,5;False;15;FLOAT2;2,4;False;6;FLOAT;0;False;16;FLOAT;1;False;17;FLOAT;0.5;False;18;FLOAT;1;False;8;FLOAT;0.05;False;38;FLOAT;500;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;155;56.17017,-842.0204;Inherit;False;pos;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;196;-182.8326,1856.72;Inherit;False;190;interact;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;1411.961,129.8148;Inherit;False;59;lineA;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;86;-369.0517,-317.9474;Inherit;False;Property;_LineA2FrequencySpeed;Line A2 (Frequency, Speed);5;0;Create;True;0;0;0;False;0;False;2,4,3,5;5,7.54,19,-21.05;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;184;762.6155,1436.465;Inherit;False;lineC;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;96;-396.2334,436.0226;Inherit;False;Property;_LineB1FrequencySpeed;Line B1 (Frequency, Speed);9;0;Create;True;0;0;0;False;0;False;2,4,3,5;14.57,13.85,20,-10;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;85;-113.4697,-398.3014;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;215;359.0048,1288.841;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;160;1152.074,-182.0009;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;185;-110.5146,1654.914;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;100;-134.9787,619.2992;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;92;1862.601,280.3849;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;183;-114.7693,1555.695;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;153;2062.583,270.0689;Inherit;False;Property;_Debug;Debug;19;0;Create;True;0;0;0;False;0;False;1;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;88;-117.0517,-206.9474;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;197;1660.914,-540.7579;Inherit;False;Property;_OverallAmplitude;Overall Amplitude;20;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;198;1874.995,-540.3427;Inherit;False;amp;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;188;1643.782,864.4509;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;182;-113.7693,1462.695;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;285;508.1297,1439.663;Inherit;False;LineWaving2D;-1;;42;ce9f2b5efc1f0b440b81179c80f401a4;0;17;22;FLOAT;1;False;23;FLOAT;0.1;False;24;FLOAT;0;False;5;INT;10;False;7;FLOAT2;0,0;False;10;FLOAT2;1.3,1.4;False;11;FLOAT2;1.5,1.6;False;12;FLOAT2;2,4;False;13;FLOAT2;3,5;False;14;FLOAT2;3,5;False;15;FLOAT2;2,4;False;6;FLOAT;0;False;16;FLOAT;1;False;17;FLOAT;0.5;False;18;FLOAT;1;False;8;FLOAT;0.05;False;38;FLOAT;500;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;192;69.7393,664.4941;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;194;49.88261,1557.053;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;170;108.0288,-286.3485;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;150;1727.723,-276.6132;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;87;-116.0517,-299.9474;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;189;2194.49,-158.3342;Inherit;False;FLOAT2;0;0;2;3;1;0;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;145;-437.1956,-850.0021;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;129;1532.541,-888.7354;Inherit;False;Property;_WarpFreqAmpSpeed;Warp (Freq, Amp, Speed);16;0;Create;True;0;0;0;False;0;False;0,0,0;3.51,-0.5,0.53;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;206;1613.978,-736.5731;Inherit;False;198;amp;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;190;2366.49,-150.3342;Inherit;False;interact;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;207;1956.146,-857.0757;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IntNode;50;1468.187,3.263926;Inherit;False;Property;_Count;Count;0;0;Create;True;0;0;0;False;0;False;30;60;False;0;1;INT;0
Node;AmplifyShaderEditor.GetLocalVarNode;178;176.8957,1470.997;Inherit;False;155;pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;214;192.2559,1302.972;Inherit;False;208;warp;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;195;61.18655,1680.947;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;292;193.4224,2155.38;Inherit;False;289;densityFreq;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;1654.806,124.7955;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;64;1332.968,221.9117;Inherit;True;Property;_GradientTexA;Gradient Tex A;1;0;Create;True;0;0;0;False;0;False;-1;None;26bbdd0b7061e7941a61e06a8d96dca3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;52;134.6281,-173.756;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;2082.598,-843.6866;Inherit;False;warp;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;156;283.3689,-487.9732;Inherit;False;155;pos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;152;1859.631,417.4903;Inherit;False;190;interact;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;159;900.6575,-213.8684;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;134;1342.438,-264.3382;Inherit;True;Property;_Position;Position;17;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;7;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;6;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;5;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;9;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;8;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;2322.407,240.9238;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;Farl/LiveWaving2D;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;21;Surface;0;0;  Blend;0;0;Two Sided;1;0;Forward Only;0;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;True;False;False;False;False;False;False;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;59;0;287;0
WireConnection;213;0;212;0
WireConnection;211;0;209;0
WireConnection;98;0;96;3
WireConnection;98;1;96;4
WireConnection;205;0;129;2
WireConnection;205;1;206;0
WireConnection;146;0;145;0
WireConnection;201;0;114;2
WireConnection;201;1;202;0
WireConnection;115;0;114;1
WireConnection;289;0;288;0
WireConnection;101;0;99;3
WireConnection;101;1;99;4
WireConnection;187;0;179;3
WireConnection;187;1;179;4
WireConnection;97;0;96;1
WireConnection;97;1;96;2
WireConnection;287;22;211;0
WireConnection;287;23;211;1
WireConnection;287;24;211;2
WireConnection;287;5;107;0
WireConnection;287;7;156;0
WireConnection;287;12;84;0
WireConnection;287;13;87;0
WireConnection;287;14;169;0
WireConnection;287;15;170;0
WireConnection;287;6;52;0
WireConnection;287;16;199;0
WireConnection;287;17;108;3
WireConnection;287;18;108;4
WireConnection;287;8;30;0
WireConnection;287;38;290;0
WireConnection;180;0;177;1
WireConnection;199;0;108;2
WireConnection;199;1;200;0
WireConnection;93;0;286;0
WireConnection;137;0;150;0
WireConnection;137;1;138;0
WireConnection;203;0;177;2
WireConnection;203;1;204;0
WireConnection;169;0;85;0
WireConnection;169;1;168;0
WireConnection;106;0;50;0
WireConnection;191;0;98;0
WireConnection;191;1;193;0
WireConnection;90;0;94;0
WireConnection;90;1;91;0
WireConnection;84;0;83;1
WireConnection;84;1;83;2
WireConnection;286;22;213;0
WireConnection;286;23;213;1
WireConnection;286;24;213;2
WireConnection;286;5;116;0
WireConnection;286;7;157;0
WireConnection;286;12;97;0
WireConnection;286;13;100;0
WireConnection;286;14;191;0
WireConnection;286;15;192;0
WireConnection;286;6;115;0
WireConnection;286;16;201;0
WireConnection;286;17;114;3
WireConnection;286;18;114;4
WireConnection;286;8;113;0
WireConnection;286;38;291;0
WireConnection;155;0;146;0
WireConnection;184;0;285;0
WireConnection;85;0;83;3
WireConnection;85;1;83;4
WireConnection;215;0;214;0
WireConnection;160;0;159;1
WireConnection;160;1;159;2
WireConnection;185;0;179;1
WireConnection;185;1;179;2
WireConnection;100;0;99;1
WireConnection;100;1;99;2
WireConnection;92;0;65;0
WireConnection;92;1;90;0
WireConnection;92;2;188;0
WireConnection;183;0;181;3
WireConnection;183;1;181;4
WireConnection;153;0;92;0
WireConnection;153;1;150;0
WireConnection;88;0;86;3
WireConnection;88;1;86;4
WireConnection;198;0;197;0
WireConnection;188;0;174;0
WireConnection;188;1;173;0
WireConnection;182;0;181;1
WireConnection;182;1;181;2
WireConnection;285;22;215;0
WireConnection;285;23;215;1
WireConnection;285;24;215;2
WireConnection;285;5;176;0
WireConnection;285;7;178;0
WireConnection;285;12;182;0
WireConnection;285;13;185;0
WireConnection;285;14;194;0
WireConnection;285;15;195;0
WireConnection;285;6;180;0
WireConnection;285;16;203;0
WireConnection;285;17;177;3
WireConnection;285;18;177;4
WireConnection;285;8;175;0
WireConnection;285;38;292;0
WireConnection;192;0;101;0
WireConnection;192;1;193;0
WireConnection;194;0;183;0
WireConnection;194;1;196;0
WireConnection;170;0;88;0
WireConnection;170;1;168;0
WireConnection;150;0;134;2
WireConnection;87;0;86;1
WireConnection;87;1;86;2
WireConnection;189;0;137;0
WireConnection;190;0;189;0
WireConnection;207;0;129;1
WireConnection;207;1;205;0
WireConnection;207;2;129;3
WireConnection;195;0;187;0
WireConnection;195;1;196;0
WireConnection;65;0;60;0
WireConnection;65;1;64;0
WireConnection;52;0;108;1
WireConnection;208;0;207;0
WireConnection;1;2;153;0
ASEEND*/
//CHKSM=C6983A526692FAA9627CBCE102BBC6FC127D56BB