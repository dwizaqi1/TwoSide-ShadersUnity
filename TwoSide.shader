Shader "Unlit/TwoSide"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _Brightness ("Brightness", Range(0, 2)) = 1
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ NORMAL_MAP_ON

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            fixed4 _BaseColor;
            float _Brightness;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = v.normal;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _BaseColor;
                col.rgb *= _Brightness;

                #ifdef NORMAL_MAP_ON
                fixed3 normal = UnpackNormal(tex2D(_NormalMap, i.uv));
                #else
                fixed3 normal = i.normal;
                #endif

                // Basic lighting
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = saturate(dot(normal, lightDir));

                col.rgb *= diffuse;
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
