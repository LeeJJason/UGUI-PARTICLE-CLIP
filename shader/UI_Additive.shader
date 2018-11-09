// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "UI/Additive" 
{
	Properties
	{
		_TintColor("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex("Particle Texture", 2D) = "white" {}
		_InvFade("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		_ClipRect("ClipRect", Vector) = (0, 0, 0, 0)
		_UseClipRect("UseClipRect", Float) = 0
	}

	Category
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Blend SrcAlpha One
		ColorMask RGB
		Cull Off Lighting Off ZWrite Off

		SubShader
		{
			Pass
			{

				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_particles
				#pragma multi_compile_fog

				#include "UnityCG.cginc"
				#include "UnityUI.cginc"

				sampler2D _MainTex;
				fixed4 _TintColor;
				float4 _MainTex_ST;
				sampler2D_float _CameraDepthTexture;
				float _InvFade;
				float4 _ClipRect;
				float _UseClipRect;

				struct appdata_t 
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f 
				{
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					UNITY_FOG_COORDS(1)
					float2 worldPosition : TEXCOORD2;
					#ifdef SOFTPARTICLES_ON
					float4 projPos : TEXCOORD3;
					#endif
					
				};


				v2f vert(appdata_t v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					#ifdef SOFTPARTICLES_ON
					o.projPos = ComputeScreenPos(o.vertex);
					COMPUTE_EYEDEPTH(o.projPos.z);
					#endif
					o.color = v.color;
					o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
					//world space中的xy坐标保存到o.worldPosition.xy中
					//unity_ObjectToWorld 等同于_Object2World 5.3.8中使用：_Object2World
					o.worldPosition.xy = mul(unity_ObjectToWorld, v.vertex).xy;
					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}

				

				fixed4 frag(v2f i) : SV_Target
				{
					#ifdef SOFTPARTICLES_ON
					float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
					float partZ = i.projPos.z;
					float fade = saturate(_InvFade * (sceneZ - partZ));
					i.color.a *= fade;
					#endif

					fixed4 col = 2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord);
					UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0,0,0,0)); // fog towards black due to our blend mode

					float c = UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
					col.a = lerp(col.a, c * col.a, _UseClipRect);
					return col;
				}
				ENDCG
			}
		}
	}
}