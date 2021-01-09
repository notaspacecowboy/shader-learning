// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderBook/Chapter5/SimpleShader"
{
    //property语义段,非必须
    Properties
    {
        //_Color: 在该unity shader中使用的变量名
        //"Color Tint": 在material中显示的名字
        //Color: 属性类型为color
        //{1,1,1,1}:初始值
        _Color("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
    }


    SubShader
    {
        Pass
        {
            CGPROGRAM

            #include "UNITYCG.cginc"

            //编译指令,通知unity在哪个函数中找到vertex/fragment shader的实现
            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Color;
            
            //即application->vertex shader
            struct a2v
            {
                float4 vertPos : POSITION;      //从POSITION语义块中找vertPos的值，该值为vertex在model space下的坐标
                float3 normal : NORMAL;         //从NORMAL语义块中找normal变量的值，该值为vertex在model space下的法线方向矢量
                float4 texcoord: TEXCOORD0;     //从TEXCOORD0语义块中找texcoord变量的值，该值为vertex使用的贴图坐标
            };

            struct v2f
            {
                //该变量必须包含,否则renderer无法得到顶点在clip space中的坐标
                float4 pos: SV_POSITION;     
                fixed3 color: COLOR0;
            };
            
            //vertex shader代码,该shader将逐顶点执行
            //input: v, 即该顶点坐标, 由POSITION语义段提供
            //output: 该顶点在clip space中的坐标, 即SV_POSITION
            v2f vert(a2v v)
            {
                v2f o; 
                
                o.pos = UnityObjectToClipPos(v.vertPos);
                
                //normal中包含顶点的法线方向,范围为0-1间
                o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);

                return o;

                //该函数执行 mul(UNITY_MATRIX_MVP,v)
                //return UnityObjectToClipPos(v.vertPos);
            }

            //在该简单frament shader中,没有任何input
            //output为一个fixed4的vector
            //SV_Target通知renderer,将用户输出存储到一个renderer target中,这里会输出到帧缓存中
            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 color = i.color;
                color *= _Color.rgb;
                return fixed4(color, 1.0);

                //颜色范围在（0,0,0)(黑色), (1,1,1)(白色)之间
                //return fixed4(1.0, 1.0, 1.0, 1.0);
            }

            ENDCG
        }
    }
}
