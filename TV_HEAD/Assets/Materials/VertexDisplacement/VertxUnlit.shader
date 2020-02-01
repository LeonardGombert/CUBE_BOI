// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Vertex/VertxUnlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_NoiseTex("_NoiseTex (RGB)", 2D) = "white" {}
		_Value("Value", Float) = 1
		_Speed("_Speed", Float) = 1
		_Color("_Color", Color) = (0,0,0,1)
		_Outline("_Outline", Range(0,1)) = 0
		_OutlineColor("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 100			

			Pass
			{
				Cull Front
				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				struct v2f {
					float4 pos : SV_POSITION;
				};

				float _Outline;
				float4 _OutlineColor;
				sampler2D _NoiseTex;
				float _Value;
				float _Speed;

				float4 vert(appdata_base v) : SV_POSITION {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					float3 normal = mul((float3x3) UNITY_MATRIX_MV, v.normal);
					normal.x *= UNITY_MATRIX_P[0][0];
					normal.y *= UNITY_MATRIX_P[1][1];
					//o.pos.xyz += normal.xyz * _Outline;

					float4 n = tex2Dlod(_NoiseTex, float4(v.texcoord.xy, 0, 0));
					o.pos.xyz += (normal.xyz * _Outline * 0.001) * ((sin(_Time.y * _Speed * n) + 1) * 0.5);

					return o.pos;
				}

				half4 frag(v2f i) : COLOR {
					return _OutlineColor;
				}

				ENDCG
			}

			Pass
			{
				Cull Off

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 4.0

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
					float4 vertex : SV_POSITION;
					float3 normal : NORMAL;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				float _Value;
				float _Speed;
				float4 _Color;
				sampler2D _NoiseTex;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);

					float4 n = tex2Dlod(_NoiseTex, float4(v.uv.xy, 0, 0));
					o.vertex.xyz += v.normal * ((sin(_Time.y * _Speed * n) + 1) * 0.5) * _Value;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					// sample the texture
					fixed4 col = tex2D(_MainTex, i.uv);
					//_Color = float4(_Color.r * ((sin(_Time.y) + 1) * 0.5), _Color.g * ((cos(_Time.y) + 1) * 0.5), _Color.b ,1);
					return col * _Color;
				}
				ENDCG
			}



		}

    }

