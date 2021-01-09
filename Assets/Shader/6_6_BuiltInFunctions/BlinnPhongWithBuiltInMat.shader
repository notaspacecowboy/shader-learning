Shader "Cutom/Blinn-Phong Model With Unity BuiltIn Functions"
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
				float3 worldPos : TEXCOORD0;
				fixed3 worldNormal : TEXCOORD1;	
			};


			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));

				return o;
			}	

			fixed4 frag(v2f o) : SV_Target
			{
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(o.worldPos));
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));
				fixed3 halfDir = normalize(worldLightDir + worldViewDir);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(o.worldNormal, worldLightDir));

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(o.worldNormal, halfDir)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);

			}


			ENDCG
		}
	}
}