Shader "Unlit/OutlinishMatcap"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MatCapTex ("MatCap", 2D) = "white" {}
		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
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
				float2 matcapUV : TEXCOORD1;
			};

			sampler2D _MainTex;
			sampler2D _MatCapTex;
			float4 _MainTex_ST;
			fixed3 _OutlineColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float2 normalVS = mul((float3x3)UNITY_MATRIX_V, UnityObjectToWorldNormal(v.normal));
				o.matcapUV = normalVS * 0.5 + 0.5;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed matcap = tex2D(_MatCapTex, i.matcapUV).rgb;

				fixed3 col = tex2D(_MainTex, i.uv).rgb;

				return fixed4(lerp(_OutlineColor, col, matcap), 1);
			}
			ENDCG
		}
	}
}
