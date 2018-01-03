Shader "Unlit/PropertyInstancing"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
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
				float2 uv : TEXCOORD01;
				UNITY_VERTEX_INPUT_INSTANCE_ID // Need this for basic functionality.
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD01;
				float3 normal : TEXCOORD02;
				float3 worldPos : TEXCOORD03;
				UNITY_VERTEX_INPUT_INSTANCE_ID // Need this to be able to get property in fragment shader.				
			};

			// Per instance properties must be declared in this block.
			UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
            UNITY_INSTANCING_BUFFER_END(Props)

			sampler2D _MainTex; float4 _MainTex_ST;

			v2f vert (appdata v)
			{
				v2f o;

				// Setup.
				UNITY_SETUP_INSTANCE_ID(v);
				// Transfer to fragment shader.
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.normal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// Setup.
				UNITY_SETUP_INSTANCE_ID(i);

				float3 normalDir = normalize(i.normal);
				float3 lightDir = _WorldSpaceLightPos0;
				// Simple light interaction.
				float3 diffuse = clamp(dot(normalDir, lightDir), 0.5, 1);

				// Get per instance property value.
				fixed3 color = UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
				fixed3 texColor = tex2D(_MainTex, i.uv);

				return fixed4(texColor * diffuse * color, 1);
			}
			ENDCG
		}
	}
}
