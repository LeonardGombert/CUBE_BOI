Shader "Custom/Outline/OutlineBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_DepthValue("_DepthValue", Range(0,0.1)) = 0.05
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
            sampler2D _CameraDepthNormalsTexture;
			float4 _CameraDepthNormalsTexture_TexelSize;
            float4 _MainTex_ST;
			float _DepthValue;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float4 depthnormal = tex2D(_CameraDepthNormalsTexture, i.uv);
				float3 normal;
				float depth;
				DecodeDepthNormal(depthnormal, depth, normal);

				depth = depth * _ProjectionParams.z;
				depth *= _DepthValue;


                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return depth;
            }
            ENDCG
        }
    }
}
