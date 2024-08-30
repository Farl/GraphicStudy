#ifndef SAMPLE_REFLECTION_PROBES
#define SAMPLE_REFLECTION_PROBES

void URPReflectionProbe_float(float3 positionWS, float3 reflectVector, float3 screenspaceUV, float roughness, out float3 reflection)
{
#ifdef SHADERGRAPH_PREVIEW
    reflection = float3(0, 0, 0);
#else
    reflection = GlossyEnvironmentReflection(reflectVector, positionWS, roughness, 1.0h, screenspaceUV);
#endif
}

void URPReflectionProbe_half(float3 positionWS, half3 reflectVector, half3 screenspaceUV, half roughness, out half3 reflection)
{
#ifdef SHADERGRAPH_PREVIEW
    reflection = float3(0, 0, 0);
#else
    reflection = GlossyEnvironmentReflection(reflectVector, positionWS, roughness, 1.0h, screenspaceUV);
#endif
}

void URPReflectionProbe_BoxProjection_float(float3 ViewDirWS, float3 NormalWS, float PositionWS, float LOD, out float3 Color)
{
#ifdef SHADERGRAPH_PREVIEW
    Color = float3(0, 0, 0);
#else
    float3 viewDirWS = normalize(ViewDirWS);
    float3 normalWS = normalize(NormalWS);
    float3 reflDir = normalize(reflect(-viewDirWS, normalWS));

    float3 factors = ((reflDir > 0 ? unity_SpecCube0_BoxMax.xyz : unity_SpecCube0_BoxMin.xyz) - PositionWS) / reflDir;
    float scalar = min(min(factors.x, factors.y), factors.z);
    float3 uvw = reflDir * scalar + (PositionWS - unity_SpecCube0_ProbePosition.xyz);

    float4 sampleRefl = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, uvw, LOD);
    float3 specCol = DecodeHDREnvironment(sampleRefl, unity_SpecCube0_HDR);
    Color = specCol;
#endif
}

void URPReflectionProbe_BoxProjection_half(half3 ViewDirWS, half3 NormalWS, half3 PositionWS, half LOD, out half3 Color)
{
#ifdef SHADERGRAPH_PREVIEW
    Color = half3(0, 0, 0);
#else
    half3 viewDirWS = normalize(ViewDirWS);
    half3 normalWS = normalize(NormalWS);
    half3 reflDir = normalize(reflect(-viewDirWS, normalWS));

    half3 factors = ((reflDir > 0 ? unity_SpecCube0_BoxMax.xyz : unity_SpecCube0_BoxMin.xyz) - PositionWS) / reflDir;
    half scalar = min(min(factors.x, factors.y), factors.z);
    half3 uvw = reflDir * scalar + (PositionWS - unity_SpecCube0_ProbePosition.xyz);

    half4 sampleRefl = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, uvw, LOD);
    half3 specCol = DecodeHDREnvironment(sampleRefl, unity_SpecCube0_HDR);
    Color = specCol;
#endif
}

#endif