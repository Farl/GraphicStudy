Shader "SS/RenderFeature/GaussianBlur3x1"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float4 _MainTex_ST;
            
            float2 _offset;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f input) : SV_Target
            {
                _offset = _offset * _MainTex_TexelSize;
                fixed4 col = tex2D( _MainTex, input.uv ) * 0.5;
                col.rgb += tex2D( _MainTex, input.uv + _offset ).rgb * 0.25;
                col.rgb += tex2D( _MainTex, input.uv - _offset ).rgb * 0.25;
                
                return col;
            }
            ENDCG
        }
    }
}
