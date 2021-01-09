Shader "Custom/Alpha Test"
{
	Properties
	{
		_Color("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex("Main Texture", 2D) = "white" {}
		_Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5    //决定调用clip进行Alpha test时的判断条件
	}

	SubShader
	{
		Tags
		{
			"Queue" = "AlphaTest"
			"RenderType" = "TransparentCutout"			//指明该shader是一个使用了透明度测试的shader
			"IgnoreProjector" = "True"					//致命该shader不受投影器印象
		}

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
			float _Cutoff;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0; 
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1; 
				float3 worldNormal : TEXCOORD2;
			};


			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 worldNormal = normalize(i.worldNormal);
				float3 lightDir = UnityWorldSpaceLightDir(i.worldPos);
				float3 viewDir = UnityWorldSpaceViewDir(i.worldPos);

				fixed4 texColor = tex2D(_MainTex, i.uv);         //需要保留贴图的alpha通道

				//Alpha test
				clip(texColor.a - _Cutoff);						//当参数小于0时,该fragment将会被舍弃

				//当fragment通过alpha test后,进行正常非透明物体的着色工作
				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, lightDir));

				fixed3 halfDir = normalize(lightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * albedo * saturate(dot(halfDir, worldNormal));

				return fixed4(ambient + diffuse + specular, 1.0);
			} 

			ENDCG
		}
	}
	FallBack "Transparent/Cutout/VertexLit"

}