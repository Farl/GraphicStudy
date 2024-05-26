// Signed Distance Functions

float sdf_sphere(float3 p, float3 center, float radius)
{
	return distance(p, center) - radius;
}

float vmax(float3 v)
{
	return max(max(v.x, v.y), v.z);
}

float sdf_boxcheap(float3 p, float3 c, float3 s)
{
	return vmax(abs(p-c) - s);
}

float sdf_cylinder(float3 p, float3 c)
{
	return length(p.xz - c.xy) - c.z;
}

float sdf_cone( float3 p, float3 c, float3 s )
{
	float2 q = float2( length(p.xz - c.xz), p.y - c.y );
	float d1 = -(p.y - c.y) - s.z;
	float d2 = max( dot(q, s.xy), (p.y - c.y));
	return length(max(float2(d1, d2), 0.0)) + min(max(d1, d2), 0.0);
}

float sdf_union(float sdf1, float sdf2)
{
	return min(sdf1, sdf2);
}

float sdf_intersection(float sdf1, float sdf2)
{
	return max(sdf1, sdf2);
}

float sdf_difference(float sdf1, float sdf2)
{
	return max(sdf1, -sdf2);
}

float sdf_lerp(float sdf1, float sdf2, float t)
{
	return sdf1 * (1 - t) + sdf2 * t;
}

float sdfRange(float sdfValue, float edge, float fallOff)
{
    float v = sdfValue - edge + fallOff;
    if (fallOff == 0)
    {
        if (v > 0)
            return 1;
        else
            return v;
    }
    fallOff = abs(fallOff);
    return saturate(v / fallOff);
}