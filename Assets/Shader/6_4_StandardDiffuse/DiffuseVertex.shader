// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Diffuse Vertex-Level"
{
	Properties 
	{	
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)	//漫反射系数 
	}

	SubShader 
	{
		Pass 
		{
			Tags          //用于定义该pass在unity光照管线中的作用
			{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Diffuse;

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
				//声明输出变量
				v2f o;        

				//通过MVP变换获得position in clip space
				o.pos = UnityObjectToClipPos(v.vertex);

				//获得unity默认的环境光constant
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

				//获得world space中的该物体的法线
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));	

				//获得world space下光源的方向向量
				fixed3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

				//计算diffuse
				fixed3 diffuse = (_LightColor0.rgb * _Diffuse.rgb) * saturate(dot(worldNormal, lightDirection));

				//计算color
				o.color = diffuse + ambient;

				return o;	
			}


			fixed4 frag(v2f o) : SV_TARGET
			{
				return fixed4(o.color, 1.0);
			}

			ENDCG
		}		
	}
	FallBack "Diffuse"
}
