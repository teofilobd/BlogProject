Shader "Unlit/OutlinishRimLight"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
		_OutlineSmoothness("Outline Smoothness", Float) = 0
		_OutlineIntensity("Outline Intensity", Float) = 0
		_OutlineThickness("Outline Thickness", Float) = 0
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
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			half _OutlineSmoothness;
			half _OutlineIntensity;
			half _OutlineThickness;
			fixed3 _OutlineColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 normal = normalize(i.normal);
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				float dotNV = max(0, dot(normal, viewDir));
				float rim = 1 - min(1, _OutlineIntensity * smoothstep(0, _OutlineSmoothness, 1 - dotNV));
				rim = step(rim, _OutlineThickness);
				
				fixed3 col = tex2D(_MainTex, i.uv).rgb;

				return fixed4(lerp(col, _OutlineColor, rim), 1);
			}
			ENDCG
		}
	}
}
