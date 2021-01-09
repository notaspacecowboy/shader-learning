Shader "Custom/NormalMap World-Space"
{
	Properties
	{
		_Color("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex("Main Textur", 2D) = "White" {}
		_BumpMap("Normal Map", 2D) = "Bump" {}
		_BumpScale("Bump Scale", Float) = 1.0
		_Specular("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
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

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				fixed4 texcoord : TEXCOORD0; 
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 tangentToWorldMatrix0 : TEXCOORD1;        //用这种方式存储是因为一个插值寄存器最大只能存放float4类型的变量
				float4 tangentToWorldMatrix1 : TEXCOORD2;		 //matrix的最后一列用于存储worldPosition
				float4 tangentToWorldMatrix2 : TEXCOORD3;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				o.tangentToWorldMatrix0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.tangentToWorldMatrix1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.tangentToWorldMatrix2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 worldPos = float3(i.tangentToWorldMatrix0.w, i.tangentToWorldMatrix1.w, i.tangentToWorldMatrix2.w);
	
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				//get tangent-space Normal
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
			
				//transform the normal from tangent space to world space
				bump = normalize(half3(dot(i.tangentToWorldMatrix0.xyz, bump), dot(i.tangentToWorldMatrix1.xyz, bump), dot(i.tangentToWorldMatrix2.xyz, bump)));

				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = unity_LightColor0.rgb * albedo * max(0, dot(bump, lightDir));
				
				fixed3 halfDir = normalize(lightDir + viewDir);
				fixed3 specular = unity_LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
	}
	//FallBack "Specular"
}