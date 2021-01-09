Shader "Custom/Mask Texture"
{
	Properties
	{
		_Color("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex("Albedo Texture", 2D) = "white" {}
		_BumpTex("Normal Map", 2D) = "white" {}
		_BumpScale("Bump Scale", Float) = 1.0
		_SpecularMask("Mask Texture", 2D) = "white" {}
		_SpecularScale("Specular Mask Scale", Float) = 1.0
		_Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss("Gloss", Range(8.0, 256)) = 20
	}

	SubShader 
	{
		Pass 
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpTex;
			float _BumpScale;
			sampler2D _SpecularMask;
			float _SpecularScale;
			float4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0; 
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2; 
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				TANGENT_SPACE_ROTATION;
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

			 	return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 tangentSpaceLightDir = normalize(i.lightDir);
				fixed3 tangentSpaceViewDir = normalize(i.viewDir);

				//ambient
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				//diffuse
				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpTex, i.uv)).rgb;
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentSpaceLightDir));

				//specular
				fixed specularRate = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
				fixed3 halfDir = normalize(tangentSpaceLightDir + tangentSpaceViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss) * specularRate;

				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
	}
}