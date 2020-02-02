Shader "Custom/Shadow/Scribble"
{
		//show values to edit in inspector
		Properties{
			_Color("Tint", Color) = (0, 0, 0, 1)
			_MainTex("Texture", 2D) = "white" {}
			_NoiseTex("_NoiseTex", 2D) = "white" {}
			[HDR] _Emission("Emission", color) = (0,0,0)

			_HalftonePattern("Halftone Pattern", 2D) = "white" {}
			_HalftonePattern2("Halftone Pattern 2 ", 2D) = "white" {}

			_RemapInputMin("Remap input min value", Range(0, 1)) = 0
			_RemapInputMax("Remap input max value", Range(0, 1)) = 1
			_RemapOutputMin("Remap output min value", Range(0, 1)) = 0
			_RemapOutputMax("Remap output max value", Range(0, 1)) = 1

			_RemapInputMin2("Remap input min value2", Range(0, 1)) = 0
			_RemapInputMax2("Remap input max value2", Range(0, 1)) = 1
			_RemapOutputMin2("Remap output min value2", Range(0, 1)) = 0
			_RemapOutputMax2("Remap output max value2", Range(0, 1)) = 1

		[PerRendererData]_Value("Value", Float) = 1
		[PerRendererData]_Speed("_Speed", Float) = 1
		[PerRendererData]_Outline("_Outline", Range(0,0.01)) = 0
		_OutlineColor("Color", Color) = (1, 1, 1, 1)
		[PerRendererData] _Width("Width", float) = 5

			[PerRendererData]_Test1("_Test1", float) = 1
			[PerRendererData]_Test2("_Test2", float) = 1

			[PerRendererData]_Disorder("Disorder", float) = 0

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
				#pragma target 4.6

				//basic properties
				sampler2D _MainTex;
				fixed4 _Color;
				half3 _Emission;

				//shading properties
				sampler2D _HalftonePattern;
				float4 _HalftonePattern_ST;
				sampler2D _HalftonePattern2;
				float4 _HalftonePattern2_ST;

				///remapping values
				float _RemapInputMin;
				float _RemapInputMax;
				float _RemapOutputMin;
				float _RemapOutputMax;

				float _RemapInputMin2;
				float _RemapInputMax2;
				float _RemapOutputMin2;
				float _RemapOutputMax2;

				float _Disorder;

				float _Test1;
				float _Test2;
				float _Value;
				float _Speed;
				float _Width;
				float4 _OutlineColor;
				sampler2D _NoiseTex;

				//struct that holds information that gets transferred from surface to lighting function
				struct HalftoneSurfaceOutput {
					fixed3 Albedo;
					float2 ScreenPos;
					half3 Emission;
					fixed Alpha;
					fixed3 Normal;
					float2 uv_MainTex;
				};

				// This function remaps values from a input to a output range
				float map(float input, float inMin, float inMax, float outMin,  float outMax)
				{
					//inverse lerp with input range
					float relativeValue = (input - inMin) / (inMax - inMin);
					//lerp with output range
					return lerp(outMin, outMax, relativeValue);
				}

				//input struct which is automatically filled by unity
				struct Input {
					float2 uv_MainTex;
					float2 uv;
					float4 screenPos;
				};

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
					float halftoneValueTwo = tex2D(_HalftonePattern2, s.ScreenPos).r;

					//make lightness binary between fully lit and fully shadow based on halftone pattern (with a bit of antialiasing between)
					halftoneValue = map(halftoneValue, _RemapInputMin, _RemapInputMax, _RemapOutputMin, _RemapOutputMax);
					halftoneValueTwo = map(halftoneValueTwo, _RemapInputMin2, _RemapInputMax2, _RemapOutputMin2, _RemapOutputMax2);
					float halftoneChange = fwidth(halftoneValue) * 0.5;
					float halftoneChangeTwo = fwidth(halftoneValueTwo) * 0.5;
					lightIntensity = smoothstep(halftoneValue - halftoneChange, halftoneValue + halftoneChange, lightIntensity)
									* smoothstep(halftoneValueTwo - halftoneChangeTwo, halftoneValueTwo + halftoneChangeTwo, lightIntensity);

					//combine the color
					float4 col;
					//intensity we calculated previously, diffuse color, light falloff and shadowcasting, color of the light
					col.rgb = lightIntensity * s.Albedo * _LightColor0.rgb;
					//in case we want to make the shader transparent in the future - irrelevant right now
					col.a = s.Alpha;

					return col;
				}


				void vert(inout appdata_full v) {
					float4 n = tex2Dlod(_NoiseTex, float4(v.texcoord.xy, 0, 0));
					v.vertex.xyz += lerp(v.normal * ((sin(_Time.y * _Speed * n) + 1) * 0.5) * _Value, v.normal * ((sin(_Time.y * _Speed * 10 * n) + 1) * 0.5) * _Value * 10, _Disorder);
				}

				//the surface shader function which sets parameters the lighting function then uses
				void surf(Input i, inout HalftoneSurfaceOutput o) {
					//set surface colors
					fixed4 col = tex2D(_MainTex, i.uv_MainTex);
					col *= _Color;
					o.Albedo = col.rgb;

					o.Emission = _Emission;

					float4 n = tex2Dlod(_NoiseTex, float4(i.uv_MainTex.xy, 0, 0));
					_HalftonePattern_ST.xy = ((sin(_Time.y * 30) + 1) * 0.5) * n.r * _Test1 + _Test2;
					_HalftonePattern_ST.zw = step( 0.1,((sin(_Time.y * 10 ) + 1) * 0.5) * n.r * 0.5);
					//_HalftonePattern_ST.xy = 4;


					//setup screenspace UVs for lighing function
					float aspect = _ScreenParams.x / _ScreenParams.y;
					o.ScreenPos = i.uv_MainTex.xy;
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


				float _Value;
				float _Outline;
				float _Speed;
				float _Width;
				float _Disorder;
				float4 _OutlineColor;
				sampler2D _NoiseTex;
				sampler2D _GrabTexture;


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
					v.vertex.xyz += lerp(v.normal * ((sin(_Time.y * _Speed * n) + 1) * 0.5) * _Outline, v.normal * ((sin(_Time.y * _Speed * n) + 1) * 0.5) * _Outline * 10 , _Disorder);

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