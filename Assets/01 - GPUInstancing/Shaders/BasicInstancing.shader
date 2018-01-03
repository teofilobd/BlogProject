Shader "Unlit/BasicInstancing"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags { "LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			// Enable gpu instancing variants.
			#pragma multi_compile_instancing

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;

				// Need this for basic functionality.
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 normal : TEXCOORD01;
				float3 worldPos : TEXCOORD02;
			};

			fixed4 _Color;
			
			v2f vert (appdata v)
			{
				v2f o;

				// Need this for basic functionality.
				UNITY_SETUP_INSTANCE_ID(v);

				o.normal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 normalDir = normalize(i.normal);
				float3 lightDir = _WorldSpaceLightPos0;

				// Simple light interaction.
				float3 diffuse = clamp(dot(normalDir, lightDir), 0.5, 1);

				return fixed4(diffuse * _Color.rgb, 1);
			}
			ENDCG
		}
	}
}
