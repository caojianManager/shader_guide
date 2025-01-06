Shader "Unlit/AirWall"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MulTex ("Texture", 2D) = "white" {}
        [HDR]_Color("Color",Color) = (1,1,1,1)
        _EdgeRange("EdageRange",Vector) = (2,6,0,0)         //边缘渐变区域范围。
        _uvSpeed("uvSpeed",Vector) = (1,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        
        ZTest Off
        ZWrite Off
        Blend One One
        Cull Off
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
                float3 vertexWorldPos : TEXCOORD1;
                //float3 vertexWorldPos1 : TEXCOORD3;
            };

            sampler2D _MainTex;
            sampler2D _MulTex;
            float4 _MainTex_ST;
            float4 _MulTex_ST;
            float4 _EdgeRange;
            float4 _Color;
            float4 _uvSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // float x = length(unity_ObjectToWorld._m00_m10_m20) * v.vertex.x;
                // float z = length(unity_ObjectToWorld._m02_m12_m22) * v.vertex.z;
                // float y = length(unity_ObjectToWorld._m01_m11_m21) * v.vertex.y;
                // float2 uv = float2(x + z, y);
                o.uv = TRANSFORM_TEX(v.uv , _MainTex);
                o.vertexWorldPos = mul(unity_ObjectToWorld,v.vertex);
                //o.vertexWorldPos1 = float3(length(unity_ObjectToWorld._m00_m10_m20) * v.vertex.x, length(unity_ObjectToWorld._m01_m11_m21) * v.vertex.y, length(unity_ObjectToWorld._m02_m12_m22) * v.vertex.z);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float dis = abs(distance(i.vertexWorldPos, _WorldSpaceCameraPos));
                fixed4 tex = tex2D(_MainTex, i.uv);
                tex.a *= (1 - smoothstep(_EdgeRange.x,_EdgeRange.y, dis) );
                return tex * _Color * tex.a ;
            }
            ENDCG
        }
    }
}
