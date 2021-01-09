// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Specular Vertex-Level"
{
	Properties
	{
		_Diffuse("Diffuse Color", Color) = (1, 1, 1, 1)         //漫反射系数
		_Specular("Specular Color", Color) = (1, 1, 1, 1)       //高光系数
		_Gloss("Gloss", Range(8.0, 256)) = 20                   //光滑度(用于控制高光范围,)
	}

	SubShader 
	{
		Pass 
		{
			Tags
			{
				"LightMode" = "ForwardBase"           //指定光照模式
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;
			};


			v2f vert(a2v v)
			{
				v2f o;
				//****Model space -> Clip Space****
				o.pos = UnityObjectToClipPos(v.vertex);

				//****calculate ambient color****
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//****calculate diffuse color****
				//get world normal direction
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				//get world light direction
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

				//****Calculate specular color****
				//get reflection direction
				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
				//get view direction
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				//calculate specular
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

				//sum them up and return
				o.color = ambient + diffuse + specular;
				return o;
			}


			fixed4 frag(v2f o) : SV_Target
			{
				return fixed4(o.color, 1.0);
			}

			ENDCG
		}
	}
	FallBack "Specular"
}