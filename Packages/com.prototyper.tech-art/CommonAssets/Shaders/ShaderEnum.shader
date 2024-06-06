Shader "Hidden/SS/Example/ShaderPropertyDrawer (Code)"
{
    
    Properties
    {
        [Header(Custom)]

        [Enum(CustomEnum1,1,CustomEnum2,2)]  _CustomEnum ("CustomEnum", Float) = 1
 
        [Header(Option)]
        [Enum(UnityEngine.Rendering.BlendOp)]  _BlendOp  ("BlendOp", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("SrcBlend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("DstBlend", Float) = 0
        [Enum(Off, 0, On, 1)]_ZWriteMode ("ZWriteMode", float) = 1
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode ("CullMode", float) = 2
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode ("ZTestMode", Float) = 4
        //[Enum(None,0,R,8,G,4,B,2,A,1,All,15)]_ColorMask ("ColorMask", Float) = 15
        [Enum(UnityEngine.Rendering.ColorWriteMask)]_ColorMask ("ColorMask", Float) = 15
 
        [Header(Stencil)]
        [Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp ("Stencil Comparison", Float) = 8
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilPass ("Stencil Pass", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilFail ("Stencil Fail", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilZFail ("Stencil ZFail", Float) = 0
        // Slider
        [Header(Slider)]
        [IntRange]_StencilWriteMask ("Stencil Write Mask", Range(0,255)) = 255
        [IntRange]_StencilReadMask ("Stencil Read Mask", Range(0,255)) = 255
        [IntRange]_Stencil ("Stencil ID", Range(0,255)) = 0
        [PowerSlider(3.0)] _Shininess ("Shininess", Range (0.01, 1)) = 0.08
 
        // Toggle
        [Header(Toggle)]
        [Toggle] _Toggle("Toggle", Float) = 0
        [MaterialToggle] _MaterialToggle("Material Toggle", Float) = 0
        
        [Header(KeywordEnum)]
        // Support _OVERLAY_NONE, _OVERLAY_ADD, _OVERLAY_MULTIPLY shader keywords.
        // Used with multi_compile. keyward name will be {Property name}_{Enum name} in uppercase. Support max 9 enum.
        [KeywordEnum(None, Add, Multiply)] _Overlay ("Overlay mode", Float) = 0
 
        // Insert space
        [Space] _Prop1 ("Prop1", Float) = 0
        [Space(50)] _Prop2 ("Prop2", Float) = 0
 
 
        [Header(Texture)]
        // Hide tilling/offset properties in inspect
        [NoScaleOffset]_MainTex ("No Scale Offset", 2D) = "white" {}
        // Normal map
        [Normal]_NormalTex ("NormalTex", 2D) = "white" {}
        // high-dynamic range(HDR) texture
        [HDR]_HDRTex ("HDRTex", 2D) = "white" {}
 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
 
        BlendOp [_BlendOp]
        Blend [_SrcBlend] [_DstBlend]
        ZWrite [_ZWriteMode]
        ZTest [_ZTestMode]
        Cull [_CullMode]
        ColorMask [_ColorMask]
        Pass
        {
            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
                Pass [_StencilPass]
                Fail [_StencilFail]
                ZFail [_StencilZFail]
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            // ...later on in CGPROGRAM code:
            #pragma multi_compile _OVERLAY_NONE _OVERLAY_ADD _OVERLAY_MULTIPLY
 
            #include "UnityCG.cginc"
 
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
 
            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };
 
            sampler2D _MainTex;
            float4 _MainTex_ST;
 
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
 
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
 