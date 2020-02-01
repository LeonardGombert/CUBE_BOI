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
		_Width("Width", float) = 5
    }
    SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 100		

			Pass
			{
				Name "OUTLINE"

				Cull Front
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				// make fog work
				#pragma multi_compile_fog

				#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 normal: NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			float _Value;
			float _Speed;
			float _Width;
			float4 _OutlineColor;
			sampler2D _NoiseTex;

			v2f vert(appdata v)
			{
				v2f o;

				if (_Width == 0)
					_Width = 5;

				float3 cameraForwardWorld = mul((float3x3)unity_CameraToWorld, float3(0, 0, 1));
				float3 cameraForwardObject = mul((float3x3)unity_WorldToObject, cameraForwardWorld);

				float3 tangent = cross(cameraForwardObject, v.normal);
				float3 projectedNormal = cross(cameraForwardObject, tangent);

				float4 n = tex2Dlod(_NoiseTex, float4(v.uv.xy, 0, 0));
				v.vertex.xyz += v.normal * ((sin(_Time.y * _Speed * n) + 1) * 0.5) * _Value;

				projectedNormal = normalize(-projectedNormal) * _Width * length(mul(unity_ObjectToWorld, v.vertex) - _WorldSpaceCameraPos) / max(_ScreenParams.x, _ScreenParams.y);

				v.vertex += float4(projectedNormal, 0);

				o.vertex = UnityObjectToClipPos(v.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = _OutlineColor;
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
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

