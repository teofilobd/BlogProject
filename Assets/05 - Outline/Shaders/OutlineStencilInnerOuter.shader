Shader "Unlit/OutlineStencilInnerOuter"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_OutlineColor ("Outline Color", Color) = (1,1,1,1)
		_InnerOutlineThickness("Inner Outline Thickness", Float) = 0.01
		_OuterOutlineThickness("Outer Outline Thickness", Float) = 0.01
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Stencil {
                Ref 2
                Comp always
                Pass replace
            }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}

		Pass
		{	
			Cull Front
			Stencil {
                Ref 2
                Comp equal
				Pass keep
            }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			half4 _OutlineColor;
			half _InnerOutlineThickness;
			
			v2f vert (appdata v)
			{
				v2f o;
				v.vertex.xyz += v.normal * _InnerOutlineThickness;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return _OutlineColor;
			}
			ENDCG
		}

		Pass
		{	
			Cull Front
			Stencil {
                Ref 2
                Comp notequal
				Pass keep
            }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			half4 _OutlineColor;
			half _OuterOutlineThickness;
			
			v2f vert (appdata v)
			{
				v2f o;
				v.vertex.xyz += v.normal * _OuterOutlineThickness;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return _OutlineColor;
			}
			ENDCG
		}

		
	}
}
