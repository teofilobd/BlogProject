Shader "Unlit/BlinnPhongSV"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		[Toggle(USE_AMBIENT)] _UseAmbient ("Use Ambient?", Float) = 0
		_AmbientIntensity("Ambient Intensity", Range(0,1)) = 1
		_AmbientColor("Ambient Color", Color) = (1,1,1,1)
		
		[Toggle(USE_DIFFUSE)] _UseDiffuse ("Use Diffuse?", Float) = 0		
		_DiffuseIntensity("Diffuse Intensity", Range(0,1)) = 1
		_DiffuseColor("Diffuse Color", Color) = (1,1,1,1)
		
		[KeywordEnum(None, Phong, BlinnPhong)] Use_Specular ("Choose Specular", Float) = 0
		_SpecularIntesity("Specular Intensity", Range(0,1)) = 1
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
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

			#pragma multi_compile __ USE_AMBIENT
			#pragma multi_compile __ USE_DIFFUSE 
			#pragma multi_compile __ USE_SPECULAR_PHONG USE_SPECULAR_BLINNPHONG
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				#if USE_DIFFUSE || USE_SPECULAR_PHONG || USE_SPECULAR_BLINNPHONG
					float3 normal : NORMAL;
				#endif
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				#if USE_DIFFUSE || USE_SPECULAR_PHONG || USE_SPECULAR_BLINNPHONG			
					float3 normal : TEXCOORD1;
				#endif
				float4 vertex : SV_POSITION;
				#if USE_SPECULAR_PHONG || USE_SPECULAR_BLINNPHONG
					float3 worldPos : TEXCOORD2;
				#endif
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			#if USE_AMBIENT
				fixed3 _AmbientColor;
				fixed _AmbientIntensity;
			#endif

			#if USE_DIFFUSE
				fixed3 _DiffuseColor;
				fixed _DiffuseIntensity;
			#endif

			#if USE_SPECULAR_PHONG || USE_SPECULAR_BLINNPHONG
				fixed3 _SpecularColor;
				fixed _SpecularIntesity;
				float _Shininess;
			#endif

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				#if USE_DIFFUSE || USE_SPECULAR_PHONG || USE_SPECULAR_BLINNPHONG
					// Take the normal and convert to world space.
					o.normal = UnityObjectToWorldNormal(v.normal);
				#endif

				#if USE_SPECULAR_PHONG || USE_SPECULAR_BLINNPHONG
					// Take vertex position in world space.
					o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif 

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 finalColor = fixed3(0,0,0);

				#if USE_DIFFUSE || USE_SPECULAR_PHONG || USE_SPECULAR_BLINNPHONG
					fixed3 normalDir = normalize(i.normal);
					// Light direction
					fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz); 
				#endif
				
				#if USE_SPECULAR_PHONG || USE_SPECULAR_BLINNPHONG
					// Viewer direction. From camera position to surface position.
					fixed3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				#endif

				#if USE_AMBIENT
					// Ambient
					finalColor += _AmbientIntensity * _AmbientColor;
				#endif
			
				#if USE_DIFFUSE
					// Diffuse
					// max is used to avoid shading surfaces that dont face the light.
					fixed dotNL = max(dot(normalDir, lightDir), 0.0);
					finalColor += _DiffuseIntensity * _DiffuseColor * dotNL;
				#endif

				#if USE_SPECULAR_PHONG
					// Specular Phong
					fixed3 lightReflection = reflect(-lightDir, normalDir);
					fixed dotLV = max(dot(lightReflection, viewDir), 0.0);
					finalColor += _SpecularIntesity * _SpecularColor * pow(dotLV, _Shininess);
				#endif

				#if USE_SPECULAR_BLINNPHONG
					// Specular Blinn-Phong
					fixed3 halfVector = normalize(lightDir + viewDir);
					fixed dotHN = max(dot(halfVector, normalDir), 0.0);
					finalColor += _SpecularIntesity * _SpecularColor * pow(dotHN, _Shininess * 4.0);
				#endif

				// You can try to add a new variant for this part.
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
