// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/NewDiffuseAndSpecularShader"
{
    Properties
    {
	_MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
	Tags { "RenderType"="Opaque" }
	LOD 100

	Pass
	{
	    CGPROGRAM
	    #pragma vertex vert
	    #pragma fragment frag
	    // // make fog work
	    // #pragma multi_compile_fog
	    
	    #include "UnityCG.cginc"

	    struct appdata
	    {
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		float3 normal : NORMAL;	
	    };

	    struct v2f
	    {
		float2 uv : TEXCOORD0;
		// UNITY_FOG_COORDS(1)
		float4 vertex : SV_POSITION;
		float3 diffuse : TEXCOORD1;
		float3 toCameraDir : TEXCOORD2;
		float3 normal : NORMAL;
	    };

	    sampler2D _MainTex;
	    float4 _MainTex_ST;
	    float _AmbientLight = 0.1;
	    float3 _CameraPos;
	    float _SpecularPowFactor;
            float3 _LightWorldPos;
	    
	    v2f vert (appdata v)
	    {
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		// UNITY_TRANSFER_FOG(o,o.vertex);

		// calculate diffuse light
		float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
		float3 lightDir = normalize(worldPos - _LightWorldPos);
		float diffuse = dot(-lightDir, v.normal);
		o.diffuse = float3(diffuse, diffuse, diffuse);

		// calculate about specular
		o.toCameraDir = normalize(_CameraPos - v.vertex);

		o.normal = v.normal;

		return o;
	    }
	    
	    fixed4 frag (v2f i) : SV_Target
	    {
		// sample the texture
		fixed4 col = tex2D(_MainTex, i.uv);
		// // apply fog
		// UNITY_APPLY_FOG(i.fogCoord, col);

		// calculate specular light
		float3 toCameraDir = normalize(i.toCameraDir); // renormalize
		float3 normal = normalize(i.normal);	       // renormalize
		float specular = pow(dot(toCameraDir, normal), _SpecularPowFactor);

		// calculate light
		float light = _AmbientLight + i.diffuse + specular;

		// apply light
		col.xyz *= light;

		return col;
	    }
	    ENDCG
	}
    }
}
