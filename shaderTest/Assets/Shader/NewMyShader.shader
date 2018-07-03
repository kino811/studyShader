// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/NewMyShader"
{
	Properties
	{
        // tilling/offset 지원 안함.
		[NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
            // 버텍스 쉐이더 함수 지정
			#pragma vertex vert
            // fragment 는 pixel 과 같다. 픽셀 쉐이더 함수 지정
			#pragma fragment frag
			
            // 인클루드로 핼퍼 api 를 추가해서 사용 가능하다. 
            // https://docs.unity3d.com/Manual/SL-BuiltinIncludes.html
			#include "UnityCG.cginc" // 지원함수 https://docs.unity3d.com/Manual/SL-BuiltinFunctions.html

            // 버텍스 쉐이더 인풋 데이터형
			struct appdata
			{
				float4 vertex : POSITION;   // vertex position
				float2 uv : TEXCOORD0;  // texture coodinate
			};

            // 버텍스 쉐이더 아웃풋 데이터형
            // vertext 2 fragment
			struct v2f
			{
                float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

            sampler2D _MainTex;
            // TRANSFORM_TEX 메크로 사용시 있어야됨
            float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;

                // 위치를 프로젝션 뷰의 좌표로 변환. 
                // 월드, 뷰, 프로젝션 메트릭스를 적용한 결과.
                o.vertex = UnityObjectToClipPos(v.vertex);
                //or 헬퍼 함수 사용해서
                o.vertex = UnityObjectToClipPos(v.vertex);

                // 텍스처 uv 좌표는 그냥 전달
                o.uv = v.uv;
                //or 메크로 사용. uv 좌표 그냥 넘기는건 동일하나 체크 같은거 추가로 한다고 함.
                // 다음 `TRANSFORM_TEX` 메크로 설명은 다른 한글번역본에 잠깐 나옴
                // https://docs.unity3d.com/kr/530/Manual/ShaderTut2.html
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				return o;
			}
			
            // 다음 SV_Target 은 리턴값 형식이 렌더 대상 형식과 일치해야 됨을 의미한다.
			fixed4 frag (v2f i) : SV_Target
			{
				// 텍셀 컬러 추출
				fixed4 col = tex2D(_MainTex, i.uv);

				return col;
			}
			ENDCG
		}
	}
}
