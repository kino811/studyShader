// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/NewDiffuseAndSpecularLightColorShader"
{
    Properties
    {
	// diffuse map
	_DiffuseMapTex ("Texture", 2D) = "white" {}
	// specular map
	_SpecularMapTex ("Texture", 2D) = "white" {}
	// 외부로 노출시켜서 머테리얼 에서 정반사 효과 요소인 제곱인자를 설정하게.
	// 머테리얼 마다 정반사 정도를 다르게 할수 있음.
	_SpecularPowFactor ("SpecularPowFactor", Int) = 0
	_AmbientLight ("AmbientLight", Float) = 0.1
    }
    SubShader
    {
	Pass
	{
	    CGPROGRAM
	    #pragma vertex vert
	    #pragma fragment frag
	    
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
		float4 vertex : SV_POSITION;
		float2 uv : TEXCOORD0;
		float3 diffuse : TEXCOORD1;
		float3 reflection : TEXCOORD2;
		float3 viewDir : TEXCOORD3;
	    };

	    sampler2D _DiffuseMapTex;
	    sampler2D _SpecularMapTex;
	    float _AmbientLight;
	    int _SpecularPowFactor;
	    
	    v2f vert (appdata v)
	    {
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;

		float3 worldNormal = UnityObjectToWorldNormal(v.normal); // 월드공간상에서의 정점 노멀을 구함

		// calculate diffuse light
		float3 lightDir = _WorldSpaceLightPos0.xyz;
		o.diffuse = dot(-lightDir, worldNormal);

		// calculate about specular
		float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; // 월드공간상의 정점 좌표
		o.reflection = reflect(lightDir, worldNormal);

		o.viewDir = normalize(worldPos - _WorldSpaceCameraPos);

		return o;
	    }
	    
	    fixed4 frag (v2f i) : SV_Target
	    {
		fixed4 albedo = tex2D(_DiffuseMapTex, i.uv);
		float3 diffuse = _LightColor0 * albedo.rgb * saturate(i.diffuse);

		// calculate specular light
		float3 specular = 0;
		float3 reflection = normalize(i.reflection);
		float3 viewDir = normalize(i.viewDir);
		// 난반사 있을시, 즉 빛을 받을시 정반사도 표시
		if (i.diffuse.x > 0)
		{
		    specular = pow(saturate(dot(reflection, -viewDir)), _SpecularPowFactor);
		    fixed4 specularAlbedo = tex2D(_SpecularMapTex, i.uv);
		    specular *= specularAlbedo.rgb;
		}

		// ambient
		float3 ambient = _AmbientLight * albedo;

		return fixed4(diffuse + ambient + specular, 1);
	    }
	    ENDCG
	}
    }
}
