Shader "Custom/Vertex/VertxUnlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
			_NoiseTex("_NoiseTex (RGB)", 2D) = "white" {}
		_Value("Value", Float) = 1
		_Speed("_Speed", Float) = 1
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
            #pragma target 4.0
            // make fog work
            #pragma multi_compile_fog

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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _Value;
			float _Speed;
			sampler2D _NoiseTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float4 n = tex2Dlod(_NoiseTex, float4(v.uv.xy, 0, 0));
				//v.vertex.xyz += v.normal * _Value * (sin(_Time.y * n) + 1) * 0.001;
				o.vertex.xyz += v.normal * ((sin(_Time.y * _Speed * n) + 1) * 0.5) *_Value;
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
