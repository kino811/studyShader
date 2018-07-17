// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/NewDiffuseAndSpecularShader"
{
    Properties
    {
	_MainTex ("Texture", 2D) = "white" {}
	// 외부로 노출시켜서 머테리얼 에서 정반사 효과 요소인 제곱인자를 설정하게.
	// 머테리얼 마다 정반사 정도를 다르게 할수 있음.
	_SpecularPowFactor ("SpecularPowFactor", Int) = 0
    }
    SubShader
    {
	// 자동 생성된 코드로 추후 알아봄
	Tags { "RenderType"="Opaque" }
	// 자동 생성된 코드로 추후 알아봄
	LOD 100

	Pass
	{
	    CGPROGRAM
	    #pragma vertex vert
	    #pragma fragment frag
	    // // make fog work
	    // #pragma multi_compile_fog
	    
	    #include "UnityCG.cginc"
	    #include "UnityLightingCommon.cginc" // for _LightColor0

	    struct appdata
	    {
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		float3 normal : NORMAL;	
	    };

	    struct v2f
	    {
		float2 uv : TEXCOORD0;
		// 포그관련 자동생성 코드로 추후 알아봄
		// UNITY_FOG_COORDS(1)
		float4 vertex : SV_POSITION;
		float3 diffuse : TEXCOORD1;
		float3 toCameraDir : TEXCOORD2;
		float3 normal : NORMAL;
	    };

	    sampler2D _MainTex;
	    float4 _MainTex_ST;
	    float _AmbientLight = 0.1;
	    int _SpecularPowFactor;
	    
	    v2f vert (appdata v)
	    {
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);

		// 포그 관련 자동 생성 코드로 추후 알아봄.
		// UNITY_TRANSFER_FOG(o,o.vertex);

		// calculate diffuse light
		float3 worldNormal = UnityObjectToWorldNormal(v.normal); // 월드공간상에서의 정점 노멀을 구함
		float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; // 월드공간상의 정점 좌표
		// WorldSpaceLightPos0 이 라이트의 월드좌표이다. 빌트인 쉐이더 변수
		// 방향성 라이트 경우 위치가 없으므로 xyz 로 방향을 나타냄
		// 다른 라이트는 xyz 가 위치이고, w가 1이다.
		// 참고) https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
		//   _WorldSpaceLightPos0	float4	Directional lights: (world space direction, 0). Other lights: (world space position, 1).
		// 난반사 최소값은 0
		o.diffuse = max(0, dot(worldNormal, -_WorldSpaceLightPos0.xyz));

		// calculate about specular
		// _WorldSpaceCameraPos :: 카메라의 월드포지션. 빌트인 쉐이더 변수
		o.toCameraDir = normalize(_WorldSpaceCameraPos - v.vertex);

		o.normal = v.normal;

		return o;
	    }
	    
	    fixed4 frag (v2f i) : SV_Target
	    {
		// sample the texture
		fixed4 col = tex2D(_MainTex, i.uv);
		// // apply fog
		// 포그관련 자동생성 코드, 추후 사용
		// UNITY_APPLY_FOG(i.fogCoord, col);

		// calculate specular light
		float3 normal = normalize(i.normal);	       // renormalize
		float3 worldNormal = UnityObjectToWorldNormal(normal); // 월드공간상에서의 정점 노멀을 구함
		float3 worldReflectLightDir = reflect(_WorldSpaceLightPos0.xyz, worldNormal);
		float3 toCameraDir = normalize(i.toCameraDir); // renormalize
		float specular = 0;
		float3 diffuse = i.diffuse;

		// 난반사 있을시, 즉 빛을 받을시 정반사도 표시
		if (diffuse.x > 0 || diffuse.y > 0 || diffuse.z > 0)
		{
		    specular = pow(dot(toCameraDir, worldReflectLightDir), _SpecularPowFactor);
		}

		// apply light
		float3 light = diffuse + _AmbientLight + specular;
		col.rgb *= light;

		return col;
	    }
	    ENDCG
	}
    }
}
