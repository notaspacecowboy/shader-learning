// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Specular Pixel-Level"
{
	Properties
	{
		_Diffuse("Diffuse Color", Color) = (1, 1, 1, 1)
		_Specular("Specular Color", Color) = (1, 1, 1, 1)
		_Gloss("Gloss Level", Range(8.0, 256)) = 20
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
				fixed3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f vert(a2v v)
			{
				v2f o;

				//****Position: Model space -> Clip Space****
				o.pos = UnityObjectToClipPos(v.vertex);

				//****Normal: Model space -> World Space****
				o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

				//****Position: Model space -> World Space****
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				return o;
			}

			fixed4 frag(v2f o): SV_Target
			{
				//****calculate ambient color****
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

				//****calculate diffuse color****
				//get world light direction
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//get diffuse
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(o.worldNormal, worldLightDir));

				//****Calculate specular color****
				//get reflection direction
				fixed3 reflectDir = normalize(reflect(-worldLightDir, o.worldNormal));
				//get view direction
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - o.worldPos.xyz);
				//get specular
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
					
				//sum them up
				fixed3 fColor = ambient = diffuse + specular;
				return fixed4(fColor, 1.0);
			}
			ENDCG
			
		}
	}
}