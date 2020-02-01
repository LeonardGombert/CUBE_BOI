Shader "Custom/Vertex/VertexDisp"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_NoiseTex("_NoiseTex (RGB)", 2D) = "white" {}
		_Value("Value", Float) = 1
	}
		SubShader{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
	// Physically based Standard lighting model, and enable shadows on all light types
	#pragma surface surf Standard fullforwardshadows addshadow vertex:vert

	// Use shader model 3.0 target, to get nicer looking lighting
	#pragma target 3.0

	sampler2D _MainTex;
	sampler2D _NoiseTex;
	

	struct Input {
	float2 uv_MainTex;
	float2 uv_NoiseTex;
	};

	half _Glossiness;
	half _Metallic;
	fixed4 _Color;
	static half _Frequency = 10;
	static half _Amplitude = 0.1;
	float _Value;


		void vert(inout appdata_full v)
		{
			Input o;
			/*float n = tex2D(_NoiseTex, o.uv_NoiseTex).r;
			v.vertex.xyz += v.normal * _Value * (sin(_Time.y * n.r) +1) * 0.001;
			v.vertex.y += n;*/
		}

		void surf(Input IN, inout SurfaceOutputStandard o) 
		{
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;

		}
			ENDCG
}
FallBack "Diffuse"
}