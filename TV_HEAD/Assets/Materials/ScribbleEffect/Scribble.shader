Shader "Custom/Shadow/Scribble"
{
		//show values to edit in inspector
		Properties{
			_Color("Tint", Color) = (0, 0, 0, 1)
			_MainTex("Texture", 2D) = "white" {}
			[HDR] _Emission("Emission", color) = (0,0,0)

			_HalftonePattern("Halftone Pattern", 2D) = "white" {}

			_RemapInputMin("Remap input min value", Range(0, 1)) = 0
			_RemapInputMax("Remap input max value", Range(0, 1)) = 1
			_RemapOutputMin("Remap output min value", Range(0, 1)) = 0
			_RemapOutputMax("Remap output max value", Range(0, 1)) = 1


		_NoiseTex("_NoiseTex (RGB)", 2D) = "white" {}
		_Value("Value", Float) = 1
		_Speed("_Speed", Float) = 1
		_Outline("_Outline", Range(0,0.01)) = 0
		_OutlineColor("Color", Color) = (1, 1, 1, 1)
		_Width("Width", float) = 5

		}
			SubShader{
				//the material is completely non-transparent and is rendered at the same time as the other opaque geometry
				Tags{ "RenderType" = "Opaque" "Queue" = "Geometry"}

				Name "SCRIBBLE"

				CGPROGRAM

				//the shader is a surface shader, meaning that it will be extended by unity in the background to have fancy lighting and other features
				//our surface shader function is called surf and we use our custom lighting model
				//fullforwardshadows makes sure unity adds the shadow passes the shader might need

				#include "UnityCG.cginc"
				#pragma surface surf Halftone fullforwardshadows vertex:vert addshadow
				//#pragma surface surf Lambert vertex:vert
				//#pragma addshadow 
				#pragma target 5.0

				//basic properties
				sampler2D _MainTex;
				fixed4 _Color;
				half3 _Emission;

				//shading properties
				sampler2D _HalftonePattern;
				float4 _HalftonePattern_ST;

				///remapping values
				float _RemapInputMin;
				float _RemapInputMax;
				float _RemapOutputMin;
				float _RemapOutputMax;



				//struct that holds information that gets transferred from surface to lighting function
				struct HalftoneSurfaceOutput {
					fixed3 Albedo;
					float2 ScreenPos;
					half3 Emission;
					fixed Alpha;
					fixed3 Normal;
				};

				// This function remaps values from a input to a output range
				float map(float input, float inMin, float inMax, float outMin,  float outMax)
				{
					//inverse lerp with input range
					float relativeValue = (input - inMin) / (inMax - inMin);
					//lerp with output range
					return lerp(outMin, outMax, relativeValue);
				}

				//our lighting function. Will be called once per light
				float4 LightingHalftone(HalftoneSurfaceOutput s, float3 lightDir, float atten) {
					//how much does the normal point towards the light?
					float towardsLight = dot(s.Normal, lightDir);
					//remap the value from -1 to 1 to between 0 and 1
					towardsLight = towardsLight * 0.5 + 0.5;
					//combine shadow and light and clamp the result between 0 and 1
					float lightIntensity = saturate(towardsLight * atten).r;

					//get halftone comparison value
					float halftoneValue = tex2D(_HalftonePattern, s.ScreenPos).r;

					//make lightness binary between fully lit and fully shadow based on halftone pattern (with a bit of antialiasing between)
					halftoneValue = map(halftoneValue, _RemapInputMin, _RemapInputMax, _RemapOutputMin, _RemapOutputMax);
					float halftoneChange = fwidth(halftoneValue) * 0.5;
					lightIntensity = smoothstep(halftoneValue - halftoneChange, halftoneValue + halftoneChange, lightIntensity);

					//combine the color
					float4 col;
					//intensity we calculated previously, diffuse color, light falloff and shadowcasting, color of the light
					col.rgb = lightIntensity * s.Albedo * _LightColor0.rgb;
					//in case we want to make the shader transparent in the future - irrelevant right now
					col.a = s.Alpha;

					return col;
				}

				//input struct which is automatically filled by unity
				struct Input {
					float2 uv_MainTex;
					float4 screenPos;
				};

				float _Value;
				float _Speed;
				float _Width;
				float4 _OutlineColor;
				sampler2D _NoiseTex;

				void vert(inout appdata_full v) {
					float4 n = tex2Dlod(_NoiseTex, float4(v.texcoord.xy, 0, 0));
					v.vertex.xyz += v.normal * ((sin(_Time.y * _Speed * n) + 1) * 0.5) * _Value;
				}

				//the surface shader function which sets parameters the lighting function then uses
				void surf(Input i, inout HalftoneSurfaceOutput o) {
					//set surface colors
					fixed4 col = tex2D(_MainTex, i.uv_MainTex);
					col *= _Color;
					o.Albedo = col.rgb;

					o.Emission = _Emission;

					//setup screenspace UVs for lighing function
					float aspect = _ScreenParams.x / _ScreenParams.y;
					o.ScreenPos = i.screenPos.xy / i.screenPos.w;
					o.ScreenPos = TRANSFORM_TEX(o.ScreenPos, _HalftonePattern);
					o.ScreenPos.x = o.ScreenPos.x * aspect;
				}
				ENDCG
				
					GrabPass
				{
					"_GrabTexture"
				}

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
					float4 uvgrab : TEXCOORD1;
				};

				float _Value;
				float _Outline;
				float _Speed;
				float _Width;
				float4 _OutlineColor;
				sampler2D _NoiseTex;
				sampler2D _GrabTexture;

				v2f vert(appdata v)
				{
					v2f o;

					if (_Width == 0)
						_Width = 5;

					float3 cameraForwardWorld = mul((float3x3)unity_CameraToWorld, float3(0, 0, 1));
					float3 cameraForwardObject = mul((float3x3)unity_WorldToObject, cameraForwardWorld);

					float3 tangent = cross(cameraForwardObject, v.normal);
					float3 projectedNormal = cross(cameraForwardObject, tangent);

					projectedNormal = normalize(-projectedNormal) * _Width * length(mul(unity_ObjectToWorld, v.vertex) - _WorldSpaceCameraPos) / max(_ScreenParams.x, _ScreenParams.y);

					v.vertex += float4(projectedNormal, 0);

					float4 n = tex2Dlod(_NoiseTex, float4(v.uv.xy, 0, 0));
					v.vertex.xyz += v.normal * ((sin(_Time.y * _Speed * n) + 1) * 0.5) * _Outline;

					o.vertex = UnityObjectToClipPos(v.vertex);
					UNITY_TRANSFER_FOG(o,o.vertex);

					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 col = _OutlineColor;
					fixed4 grab = tex2D(_GrabTexture, i.uvgrab);
					return grab * col;
				}
				ENDCG
				}
			}
				FallBack "Standard"
		
	}