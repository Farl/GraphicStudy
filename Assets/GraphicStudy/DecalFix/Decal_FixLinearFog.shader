// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader  "Farl/Decal_FixLinearFog"
{
	/**
		Add Fog and Lighting options
		by Farl Lee
	**/
    Properties
    {
        [HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
        [HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
        [ASEEnd][ASEBegin]Base_Map("Base", 2D) = "white" {}
        [HideInInspector] _texcoord( "", 2D ) = "white" {}

        [HideInInspector]_DrawOrder("Draw Order", Range(-50, 50)) = 0
        [HideInInspector][Enum(Depth Bias, 0, View Bias, 1)]_DecalMeshBiasType("DecalMesh BiasType", Float) = 0
        [HideInInspector]_DecalMeshDepthBias("DecalMesh DepthBias", Float) = 0
        [HideInInspector]_DecalMeshViewBias("DecalMesh ViewBias", Float) = 0
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
        //[HideInInspector] _DecalAngleFadeSupported("Decal Angle Fade Supported", Float) = 1
    }

    SubShader
    {
		LOD 0

		


        Tags { "RenderPipeline"="UniversalPipeline" "PreviewType"="Plane" "ShaderGraphShader"="true" }

		HLSLINCLUDE
		#pragma target 3.5
		ENDHLSL
		
        Pass
        { 
			
            Name "DecalScreenSpaceProjector"
            Tags { "LightMode"="DecalScreenSpaceProjector" }
        
            Cull Front
			Blend SrcAlpha OneMinusSrcAlpha
			Lighting Off
			ZTest Greater
			ZWrite Off
        
            HLSLPROGRAM
        
			#define ASE_SRP_VERSION 999999
			#define REQUIRE_DEPTH_TEXTURE 1

        
			#pragma vertex Vert
			#pragma fragment Frag
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
        
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			//#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			//#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			//#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _CLUSTERED_RENDERING
			#pragma multi_compile _DECAL_NORMAL_BLEND_LOW _DECAL_NORMAL_BLEND_MEDIUM _DECAL_NORMAL_BLEND_HIGH
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        
            #define ATTRIBUTES_NEED_NORMAL
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define VARYINGS_NEED_SH
            #define VARYINGS_NEED_STATIC_LIGHTMAP_UV
            #define VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV
            
            #define HAVE_MESH_MODIFICATION
        
        
            #define SHADERPASS SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
        
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0


			struct SurfaceDescription
			{
				float3 BaseColor;
				float Alpha;
				float3 NormalTS;
				float NormalAlpha;
				float Metallic;
				float Occlusion;
				float Smoothness;
				float MAOSAlpha;
				float3 Emission;
			};

			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float3 viewDirectionWS : TEXCOORD1;
				float2 staticLightmapUV : TEXCOORD2;
				float2 dynamicLightmapUV : TEXCOORD3;
				float3 sh : TEXCOORD4;
#ifdef ASE_FOG
				float4 fogFactorAndVertexLight : TEXCOORD5;
#endif
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID	// Fix by Farl
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
        
            CBUFFER_START(UnityPerMaterial)
			float4 Base_Map_ST;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
			#if defined(DECAL_ANGLE_FADE)
			float _DecalAngleFadeSupported;
			#endif
			CBUFFER_END
			sampler2D Base_Map;
			uniform float4 _CameraDepthTexture_TexelSize;


			inline float ComputeFogFactorZ0ToFar3_g1( float In0 )
			{
				return  ComputeFogFactorZ0ToFar(In0);
			}
			
			inline float3 MixFogColor4_g1( float4 fragColor, float4 fogColor, float fogFactor )
			{
				return MixFogColor(fragColor, fogColor, fogFactor);
			}
			

            void GetSurfaceData( SurfaceDescription surfaceDescription, half3 viewDirectioWS, uint2 positionSS, float angleFadeFactor, out DecalSurfaceData surfaceData)
            {
                
                half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);

        
                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);
        
                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif
        
				#if defined( _MATERIAL_AFFECTS_EMISSION )
                surfaceData.emissive.rgb = half3(surfaceDescription.Emission.rgb * fadeFactor);
				#endif

                surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);
        
                #if defined(_MATERIAL_AFFECTS_NORMAL)
                    surfaceData.normalWS.xyz = mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz);
                #else
                    surfaceData.normalWS.xyz = normalToWorld[2].xyz;
                #endif

                surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;
				
				#if defined( _MATERIAL_AFFECTS_MAOS )
                surfaceData.metallic = half(surfaceDescription.Metallic);
                surfaceData.occlusion = half(surfaceDescription.Occlusion);
                surfaceData.smoothness = half(surfaceDescription.Smoothness);
                surfaceData.MAOSAlpha = half(surfaceDescription.MAOSAlpha * fadeFactor);
				#endif
            }
        

			#define DECAL_PROJECTOR
			#define DECAL_SCREEN_SPACE

			#if ((!defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_ALBEDO)) || (defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_NORMAL_BLEND))) && (defined(DECAL_SCREEN_SPACE) || defined(DECAL_GBUFFER))
			#define DECAL_RECONSTRUCT_NORMAL
			#elif defined(DECAL_ANGLE_FADE)
			#define DECAL_LOAD_NORMAL
			#endif

			#if defined(DECAL_LOAD_NORMAL)
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
			#endif

			#if defined(DECAL_PROJECTOR) || defined(DECAL_RECONSTRUCT_NORMAL)
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
			#endif

			#ifdef DECAL_MESH
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DecalMeshBiasTypeEnum.cs.hlsl"
			#endif
			#ifdef DECAL_RECONSTRUCT_NORMAL
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NormalReconstruction.hlsl"
			#endif

			void InitializeInputData( PackedVaryings input, float3 positionWS, half3 normalWS, half3 viewDirectionWS, out InputData inputData)
			{
				inputData = (InputData)0;

				inputData.positionWS = positionWS;
				inputData.normalWS = normalWS;
				inputData.viewDirectionWS = viewDirectionWS;
				inputData.shadowCoord = float4(0, 0, 0, 0);
			
#ifdef ASE_FOG
				inputData.fogCoord = half(input.fogFactorAndVertexLight.x);
				inputData.vertexLighting = half3(input.fogFactorAndVertexLight.yzw);
#endif
			

			#if defined(VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV) && defined(DYNAMICLIGHTMAP_ON)
				inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV.xy, half3(input.sh), normalWS);
			#elif defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
				inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, half3(input.sh), normalWS);
			#endif

			#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
				inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
			#endif

				#if defined(DEBUG_DISPLAY)
				#if defined(VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV) && defined(DYNAMICLIGHTMAP_ON)
				inputData.dynamicLightmapUV = input.dynamicLightmapUV.xy;
				#endif
				#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV && LIGHTMAP_ON)
				inputData.staticLightmapUV = input.staticLightmapUV;
				#elif defined(VARYINGS_NEED_SH)
				inputData.vertexSH = input.sh;
				#endif
				#endif

				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
			}

			void GetSurface(DecalSurfaceData decalSurfaceData, inout SurfaceData surfaceData)
			{
				surfaceData.albedo = decalSurfaceData.baseColor.rgb;
				surfaceData.metallic = saturate(decalSurfaceData.metallic);
				surfaceData.specular = 0;
				surfaceData.smoothness = saturate(decalSurfaceData.smoothness);
				surfaceData.occlusion = decalSurfaceData.occlusion;
				surfaceData.emission = decalSurfaceData.emissive;
				surfaceData.alpha = saturate(decalSurfaceData.baseColor.w);
				surfaceData.clearCoatMask = 0;
				surfaceData.clearCoatSmoothness = 1;
			}

			PackedVaryings Vert(Attributes inputMesh  )
			{
				PackedVaryings packedOutput;
				ZERO_INITIALIZE(PackedVaryings, packedOutput);

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, packedOutput);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(packedOutput);

				float4 ase_clipPos = TransformObjectToHClip((inputMesh.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				packedOutput.ase_texcoord6 = screenPos;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = inputMesh.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					inputMesh.positionOS.xyz = vertexValue;
				#else
					inputMesh.positionOS.xyz += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs(inputMesh.positionOS.xyz);
				float3 positionWS = TransformObjectToWorld(inputMesh.positionOS);

				float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);
				
				packedOutput.positionCS = TransformWorldToHClip(positionWS);

#ifdef ASE_FOG
				half fogFactor = 0;
			#if !defined(_FOG_FRAGMENT)
					fogFactor = ComputeFogFactor(packedOutput.positionCS.z);
			#endif
				half3 vertexLight = VertexLighting(positionWS, normalWS);
				packedOutput.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
#endif

				packedOutput.normalWS.xyz =  normalWS;
				packedOutput.viewDirectionWS.xyz =  GetWorldSpaceViewDir(positionWS);
				
				#if defined(LIGHTMAP_ON)
				OUTPUT_LIGHTMAP_UV(inputMesh.uv1, unity_LightmapST, packedOutput.staticLightmapUV);
				#endif
				
				#if defined(DYNAMICLIGHTMAP_ON)
				packedOutput.dynamicLightmapUV.xy = inputMesh.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif
				
				#if !defined(LIGHTMAP_ON)
				packedOutput.sh.xyz =  float3(SampleSHVertex(half3(normalWS)));
				#endif

				return packedOutput;
			}

			void Frag(PackedVaryings packedInput,
				out half4 outColor : SV_Target0
				 
			)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
				UNITY_SETUP_INSTANCE_ID(packedInput);

				half angleFadeFactor = 1.0;

				#if UNITY_REVERSED_Z
					float depth = LoadSceneDepth(packedInput.positionCS.xy);
				#else
					float depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, LoadSceneDepth(packedInput.positionCS.xy));
				#endif

				half3 normalWS = 0;
			#if defined(DECAL_RECONSTRUCT_NORMAL)
				#if defined(_DECAL_NORMAL_BLEND_HIGH)
					normalWS = half3(ReconstructNormalTap9(packedInput.positionCS.xy));
				#elif defined(_DECAL_NORMAL_BLEND_MEDIUM)
					normalWS = half3(ReconstructNormalTap5(packedInput.positionCS.xy));
				#else
					normalWS = half3(ReconstructNormalDerivative(packedInput.positionCS.xy));
				#endif
			#elif defined(DECAL_LOAD_NORMAL)
				normalWS = half3(LoadSceneNormals(packedInput.positionCS.xy));
			#endif

				float2 positionSS = packedInput.positionCS.xy * _ScreenSize.zw;

				float3 positionWS = ComputeWorldSpacePosition(positionSS, depth, UNITY_MATRIX_I_VP);


				float3 positionDS = TransformWorldToObject(positionWS);
				positionDS = positionDS * float3(1.0, -1.0, 1.0);

				float clipValue = 0.5 - Max3(abs(positionDS).x, abs(positionDS).y, abs(positionDS).z);
				clip(clipValue);

				float2 texCoord = positionDS.xz + float2(0.5, 0.5);


				#ifdef DECAL_ANGLE_FADE
					half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
					half2 angleFade = half2(normalToWorld[1][3], normalToWorld[2][3]);

					if (angleFade.y < 0.0f)
					{
						half3 decalNormal = half3(normalToWorld[0].z, normalToWorld[1].z, normalToWorld[2].z);
						half dotAngle = dot(normalWS, decalNormal);
						angleFadeFactor = saturate(angleFade.x + angleFade.y * (dotAngle * (dotAngle - 2.0)));
					}
				#endif

			
				half3 viewDirectionWS = half3(packedInput.viewDirectionWS);
	
				DecalSurfaceData surfaceData;

				float2 uvBase_Map = texCoord * Base_Map_ST.xy + Base_Map_ST.zw;
				float4 tex2DNode33 = tex2D( Base_Map, uvBase_Map );
				float4 fragColor4_g1 = tex2DNode33;
				float4 fogColor4_g1 = unity_FogColor;
				float4 screenPos = packedInput.ase_texcoord6;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float eyeDepth1_g1 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float In03_g1 = eyeDepth1_g1;
				float localComputeFogFactorZ0ToFar3_g1 = ComputeFogFactorZ0ToFar3_g1( In03_g1 );
				float fogFactor4_g1 = localComputeFogFactorZ0ToFar3_g1;
				float3 localMixFogColor4_g1 = MixFogColor4_g1( fragColor4_g1 , fogColor4_g1 , fogFactor4_g1 );
				
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float3 tmp = localMixFogColor4_g1;
				surfaceDescription.BaseColor = tmp;
				surfaceDescription.Alpha = tex2DNode33.a;
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.NormalAlpha = 1;
				#if defined( _MATERIAL_AFFECTS_MAOS )
				surfaceDescription.Metallic = 0;
				surfaceDescription.Occlusion = 1;
				surfaceDescription.Smoothness = 0.5;
				surfaceDescription.MAOSAlpha = 1;
				#endif
				
				#if defined( _MATERIAL_AFFECTS_EMISSION )
				surfaceDescription.Emission = float3(0, 0, 0);
				#endif

				GetSurfaceData( surfaceDescription, viewDirectionWS, (uint2)positionSS, angleFadeFactor, surfaceData);

				#ifdef DECAL_RECONSTRUCT_NORMAL
					surfaceData.normalWS.xyz = normalize(lerp(normalWS.xyz, surfaceData.normalWS.xyz, surfaceData.normalWS.w));
				#endif

				InputData inputData;
				InitializeInputData( packedInput, positionWS, surfaceData.normalWS.xyz, viewDirectionWS, inputData);

				SurfaceData surface = (SurfaceData)0;
				GetSurface(surfaceData, surface);

#ifdef ASE_PBR
				half4 color = UniversalFragmentPBR(inputData, surface);
#else
				half4 color = half4(tmp.rgb, surfaceDescription.Alpha);
#endif
#ifdef ASE_FOG
				color.rgb = MixFog(color.rgb, inputData.fogCoord);
#endif
				outColor = color;

			}

            ENDHLSL
        }

		
        Pass
        { 
            
			Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }
        
            Cull Back
			Lighting Off
            HLSLPROGRAM
        
			#define ASE_SRP_VERSION 999999
			#define REQUIRE_DEPTH_TEXTURE 1

        
			#pragma vertex Vert
			#pragma fragment Frag
			#pragma multi_compile_instancing
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        
            
            #define HAVE_MESH_MODIFICATION
        
            #define SHADERPASS SHADERPASS_DEPTHONLY
			#define SCENEPICKINGPASS 1
        
            float4 _SelectionID;
            
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
        
			

			struct Attributes
			{
				float3 positionOS : POSITION;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
            CBUFFER_START(UnityPerMaterial)
			float4 Base_Map_ST;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
			#if defined(DECAL_ANGLE_FADE)
			float _DecalAngleFadeSupported;
			#endif
			CBUFFER_END
        
			sampler2D Base_Map;
			uniform float4 _CameraDepthTexture_TexelSize;


			inline float ComputeFogFactorZ0ToFar3_g1( float In0 )
			{
				return  ComputeFogFactorZ0ToFar(In0);
			}
			
			inline float3 MixFogColor4_g1( float4 fragColor, float4 fogColor, float fogFactor )
			{
				return MixFogColor(fragColor, fogColor, fogFactor);
			}
			

			#if ((!defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_ALBEDO)) || (defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_NORMAL_BLEND))) && (defined(DECAL_SCREEN_SPACE) || defined(DECAL_GBUFFER))
			#define DECAL_RECONSTRUCT_NORMAL
			#elif defined(DECAL_ANGLE_FADE)
			#define DECAL_LOAD_NORMAL
			#endif

			#if defined(DECAL_LOAD_NORMAL)
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
			#endif

			#if defined(DECAL_PROJECTOR) || defined(DECAL_RECONSTRUCT_NORMAL)
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
			#endif

			#ifdef DECAL_MESH
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DecalMeshBiasTypeEnum.cs.hlsl"
			#endif
			#ifdef DECAL_RECONSTRUCT_NORMAL
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NormalReconstruction.hlsl"
			#endif

			PackedVaryings Vert(Attributes inputMesh  )
			{
				PackedVaryings packedOutput;
				ZERO_INITIALIZE(PackedVaryings, packedOutput);
				
				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, packedOutput);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(packedOutput);

				float4 ase_clipPos = TransformObjectToHClip((inputMesh.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				packedOutput.ase_texcoord1 = screenPos;
				
				packedOutput.ase_texcoord.xy = inputMesh.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				packedOutput.ase_texcoord.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = inputMesh.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					inputMesh.positionOS.xyz = vertexValue;
				#else
					inputMesh.positionOS.xyz += vertexValue;
				#endif

				float3 positionWS = TransformObjectToWorld(inputMesh.positionOS);				
				packedOutput.positionCS = TransformWorldToHClip(positionWS);
				return packedOutput;
			}

			void Frag(PackedVaryings packedInput,
				out float4 outColor : SV_Target0
				 
			)
			{
				float2 uvBase_Map = packedInput.ase_texcoord.xy * Base_Map_ST.xy + Base_Map_ST.zw;
				float4 tex2DNode33 = tex2D( Base_Map, uvBase_Map );
				float4 fragColor4_g1 = tex2DNode33;
				float4 fogColor4_g1 = unity_FogColor;
				float4 screenPos = packedInput.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float eyeDepth1_g1 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float In03_g1 = eyeDepth1_g1;
				float localComputeFogFactorZ0ToFar3_g1 = ComputeFogFactorZ0ToFar3_g1( In03_g1 );
				float fogFactor4_g1 = localComputeFogFactorZ0ToFar3_g1;
				float3 localMixFogColor4_g1 = MixFogColor4_g1( fragColor4_g1 , fogColor4_g1 , fogFactor4_g1 );
				
				float3 BaseColor = localMixFogColor4_g1;
				outColor = _SelectionID;
			}

            ENDHLSL
        }
    }
    CustomEditor "UnityEditor.Rendering.Universal.DecalShaderGraphGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
	
	
}
/*ASEBEGIN
Version=18935
77;209;1129;780;782.7659;658.1283;1.3;True;False
Node;AmplifyShaderEditor.SamplerNode;33;-322.8297,-99.68636;Inherit;True;Property;Base_Map;Base;0;0;Create;False;0;0;0;False;0;False;-1;None;585bde8594ad8ff42aff7be60e3ee6f4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;162;-0.3087807,-92.60016;Inherit;False;MixFogColor;-1;;1;bc888e9063971cf4186b65b379755f45;0;2;5;COLOR;1,1,1,0;False;6;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;112;596.3119,-379.2313;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;17;New Amplify Shader;bfb99909870d2d44abfd23be253e6fab;True;DecalProjectorForwardEmissive;0;1;DecalProjectorForwardEmissive;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;PreviewType=Plane;ShaderGraphShader=true;True;3;False;0;False;True;8;5;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;2;False;-1;False;True;1;LightMode=DecalProjectorForwardEmissive;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;117;596.3119,-370.9311;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;17;New Amplify Shader;bfb99909870d2d44abfd23be253e6fab;True;DecalScreenSpaceMesh;0;6;DecalScreenSpaceMesh;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;PreviewType=Plane;ShaderGraphShader=true;True;3;False;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;3;False;-1;False;True;1;LightMode=DecalScreenSpaceMesh;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;111;596.3119,-379.2313;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;17;New Amplify Shader;bfb99909870d2d44abfd23be253e6fab;True;DBufferProjector;0;0;DBufferProjector;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;PreviewType=Plane;ShaderGraphShader=true;True;3;False;0;False;True;2;5;False;-1;10;False;-1;1;0;False;-1;10;False;-1;False;False;True;2;5;False;-1;10;False;-1;1;0;False;-1;10;False;-1;False;False;True;2;5;False;-1;10;False;-1;1;0;False;-1;10;False;-1;False;False;False;False;False;False;True;1;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;True;2;False;-1;True;2;False;-1;False;True;1;LightMode=DBufferProjector;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;119;596.3119,-370.9311;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;17;New Amplify Shader;bfb99909870d2d44abfd23be253e6fab;True;ScenePickingPass;0;8;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;PreviewType=Plane;ShaderGraphShader=true;True;3;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;115;596.3119,-370.9311;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;17;New Amplify Shader;bfb99909870d2d44abfd23be253e6fab;True;DBufferMesh;0;4;DBufferMesh;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;PreviewType=Plane;ShaderGraphShader=true;True;3;False;0;False;True;2;5;False;-1;10;False;-1;1;0;False;-1;10;False;-1;False;False;True;2;5;False;-1;10;False;-1;1;0;False;-1;10;False;-1;False;False;True;2;5;False;-1;10;False;-1;1;0;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;True;2;False;-1;True;3;False;-1;False;True;1;LightMode=DBufferMesh;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;118;596.3119,-379.2313;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;17;New Amplify Shader;bfb99909870d2d44abfd23be253e6fab;True;DecalGBufferMesh;0;7;DecalGBufferMesh;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;PreviewType=Plane;ShaderGraphShader=true;True;3;False;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;False;False;False;False;0;False;-1;False;True;True;True;True;False;0;False;-1;False;False;False;True;2;False;-1;False;False;True;1;LightMode=DecalGBufferMesh;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;116;596.3119,-370.9311;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;17;New Amplify Shader;bfb99909870d2d44abfd23be253e6fab;True;DecalMeshForwardEmissive;0;5;DecalMeshForwardEmissive;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;PreviewType=Plane;ShaderGraphShader=true;True;3;False;0;False;True;8;5;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;3;False;-1;False;True;1;LightMode=DecalMeshForwardEmissive;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;114;596.3119,-370.9311;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;17;New Amplify Shader;bfb99909870d2d44abfd23be253e6fab;True;DecalGBufferProjector;0;3;DecalGBufferProjector;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;PreviewType=Plane;ShaderGraphShader=true;True;3;False;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;True;1;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;True;False;False;False;False;0;False;-1;False;True;True;True;True;False;0;False;-1;False;False;False;True;2;False;-1;True;2;False;-1;False;True;1;LightMode=DecalGBufferProjector;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;113;275.0255,-24.68726;Float;False;True;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;16;Farl/Decal_FixLinearFog;bfb99909870d2d44abfd23be253e6fab;True;DecalScreenSpaceProjector;0;2;DecalScreenSpaceProjector;10;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;PreviewType=Plane;ShaderGraphShader=true;True;3;False;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;False;False;False;False;False;False;False;False;True;True;2;False;-1;True;2;False;-1;False;True;1;LightMode=DecalScreenSpaceProjector;False;False;0;;0;0;Standard;10;Lighting On;0;637879722546886176;Built-in Fog;0;637879715553671442;Affect BaseColor;0;637878743104738422;Affect Normal;0;637878743099114874;Blend;0;637878743110404309;Affect MAOS;0;0;Affect Emission;0;0;Support LOD CrossFade;0;0;Angle Fade;0;0;Vertex Position,InvertActionOnDeselection;1;0;0;9;False;False;True;False;False;False;False;False;True;False;;False;0
WireConnection;162;5;33;0
WireConnection;113;0;162;0
WireConnection;113;1;33;4
ASEEND*/
//CHKSM=A93D3EEFED7CE73764E5176E8C95718B42A52270