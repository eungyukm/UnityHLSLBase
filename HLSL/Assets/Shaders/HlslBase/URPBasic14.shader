Shader "URPTraining/URPBasic14"
{
    Properties
    {
        _TintColor("Color", color) = (1,1,1,1)
        _Intensity("Range Sample", Range(0,1)) = 0.5
        _MainTex ("Main Texture", 2D) = "white" {}
        [NoScaleOffset] _Flowmap("Flowmap", 2D) = "white" {}
        
        _FlowTime("Flow Time", Range(0, 10)) = 1
        _FlowIntensity("Flow Intensity", Range(0,2)) = 1
    }
    SubShader
    {
        Tags 
        {
            // Redner type과 Redner Queue를 여기서 결정합니다.
            "RenderPipeline" = "UniversalPipeline"
            "RenderType"="Opaque" 
            "Queue" = "Geometry"
        }

        Pass
        {
            HLSLPROGRAM

            #pragma prefer_hlslcc gles
            #pragma exculde_renderer d3d11_9x
            
            #pragma vertex vert
            #pragma fragment frag

            // CG : shader는 .cginc를 hlsl shader는 .hlsl을 include하게 됩니다.
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            half4 _TintColor;
            float _Intensity;

            float4 _MainTex_ST;
            Texture2D _MainTex, _Flowmap;
            SamplerState sampler_MainTex;

            float _FlowTime, _FlowIntensity;

            // vertex buffer에서 읽어올 정보를 선언합니다.
            struct VertexInput
            {
                float4 vertex : POSITION;
                // UV1번을 사용하는 경우
                float2 uv1 : TEXCOORD0;
                // UV2번을 사용하는 경우
                float2 uv2 : TEXCOORD1;
            };
            
            // 버텍스 셰이더에서 픽셀 셰이더로 전달할 정보를 선언합니다.
            // 보간기 : Vertxt Shader에서 Pixcel Shader로 이동할 때
            struct VertexOutput
            {
                float4 vertex : SV_POSITION;
                float2 uv1 : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
            };

            // 버텍스 셰이더
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                // 월드 공간의 position을 얻어옵니다.
                half3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                o.vertex.y += positionWS.x;
                o.uv1 = v.uv1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            // 프레그넌트 셰이더
            half4 frag(VertexOutput i) : SV_Target
            {
                half4 flow = _Flowmap.Sample(sampler_MainTex, i.uv1);
                
                half4 color = _MainTex.Sample(sampler_MainTex, i.uv1);
                color.rgb *= _TintColor * _Intensity;
                return color;
            }
            ENDHLSL
        }
    }
}
