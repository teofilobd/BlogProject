Shader "Unlit/BlinnPhong"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_AmbientColor("Ambient Color", Color) = (1,1,1,1)
		_DiffuseColor("Diffuse Color", Color) = (1,1,1,1)
		_SpecularColor("Specular Color", Color) = (1,1,1,1)

		_AmbientIntensity("Ambient Intensity", Range(0,1)) = 1
		_DiffuseIntensity("Diffuse Intensity", Range(0,1)) = 1
		_SpecularIntesity("Specular Intensity", Range(0,1)) = 1

		_Shininess("Shininess", Float) = 1
	}
	SubShader
	{
		// ForwardBase is needed to work with unity directional light
		Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase"}
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
				float3 normal : TEXCOORD1;
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			fixed3 _AmbientColor;
			fixed3 _DiffuseColor;
			fixed3 _SpecularColor;

			fixed _AmbientIntensity;
			fixed _DiffuseIntensity;
			fixed _SpecularIntesity;

			float _Shininess;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				// Take the normal and convert to world space.
				o.normal = UnityObjectToWorldNormal(v.normal);

				// Take vertex position in world space.
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 normalDir = normalize(i.normal);

				// Light direction
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz); 
				// Viewer direction. From camera position to surface position.
				fixed3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

				// Ambient
				fixed3 ambient = _AmbientIntensity * _AmbientColor;

				// Diffuse
				// max is used to avoid shading surfaces that dont face the light.
				fixed dotNL = max(dot(normalDir, lightDir), 0.0);
				fixed3 diffuse = _DiffuseIntensity * _DiffuseColor * dotNL;

				// Specular

				// Phong
				//fixed3 lightReflection = reflect(-lightDir, normalDir);
				//fixed dotRV = max(dot(lightReflection, viewDir), 0.0);
				//fixed3 specular = _SpecularIntesity * _SpecularColor * pow(dotVL, _Shininess);

				// Blinn-Phong
				fixed3 halfVector = normalize(lightDir + viewDir);
				fixed dotHN = max(dot(halfVector, normalDir), 0.0);
				fixed3 specular = _SpecularIntesity * _SpecularColor * pow(dotHN, _Shininess * 4.0);

				fixed3 finalColor = ambient + diffuse + specular;

				// Gamma correction, if needed.
				//finalColor = pow(finalColor, 1/2.2);
									
				fixed3 col = tex2D(_MainTex, i.uv);				
				finalColor *= col;

				return fixed4(finalColor, 1);
			}
			ENDCG
		}
	}
}
