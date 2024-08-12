Shader "SS/Unlit Color (Code)"
{
    Properties
    {
        [Enum(Mask0, 0, RGB, 16)] _ColorMask("Color Mask", Float) = 16
        _Color("Base Color", Color) = (1,1,1,1)

        [HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("ZTest", Float) = 4
        //[ToggleUI] _ZWrite("ZWrite", Float) = 1
        [HideInInspector] _ZWrite("ZWrite", Float) = 1

        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("SrcBlend", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("DstBlend", Float) = 10


        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull", Float) = 2

        // keyword use vertex color
        [Toggle] _Use_Vertex_Color("Use Vertex Color", Float) = 0

        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1

        [HideInInspector]_Blend("_Blend", Float) = 2
        //[HideInInspector]_AlphaClip("_AlphaClip", Float) = 0
        //[HideInInspector]_ZWriteControl("_ZWriteControl", Float) = 0

        // Surface control (Opaque / Transparent)
        [HideInInspector]_Surface("_Surface", Float) = 0
        [HideInInspector]_ZWriteControl("_ZWriteControl", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        Blend [_SrcBlend] [_DstBlend]
        Cull [_Cull]
        ColorMask [_ColorMask]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma shader_feature_local _USE_VERTEX_COLOR_ON

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 vertexColor : COLOR;
            };

            v2f vert (appdata v)
            {
                v2f o;
                // initialize
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.vertexColor = v.color;
                return o;
            }

            fixed4 _Color;

            fixed4 frag (v2f i) : SV_Target
            {
                #if _USE_VERTEX_COLOR_ON
                return _Color * i.vertexColor;
                #else
                return _Color;
                #endif
            }
            ENDCG
        }
    }
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphUnlitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
}
