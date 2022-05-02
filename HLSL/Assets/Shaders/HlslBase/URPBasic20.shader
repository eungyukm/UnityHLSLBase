// Camera Vector를 활용한 rim light
Shader "URPTraining/URPBasic20"
{
    Properties
    {
        _RimPower("Rim Power", Range(0.01, 0.1)) = 0.1
        _RimInten("Rim Intensity", Range(0.01, 100)) = 1
        [HDR] _RimColor("Rim Color", color) = (1,1,1,1)
    }
    SubShader
    {
        // 태그 선언 안하면 기본으로 설정
        Tags 
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType"="Opaque"
            "Queue"="Geometry"
        }

        Pass
        {
            Name "Universal Forward"
            Tags { "LightMode" = "UniversalForward"}

            HLSLPROGRAM

            #pragma prefer_hlslcc gles
            #pragma exculde_renderer d3d11_9x
            #pragma vertex vert
            #pragma fragment frag

            // CG : shader는 .cginc를 hlsl shader는 .hlsl을 include하게 됩니다.
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // vertex buffer에서 읽어올 정보를 선언합니다.
            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            // 버텍스 셰이더에서 픽셀 셰이더로 전달할 정보를 선언합니다.
            // 보간기 : Vertxt Shader에서 Pixcel Shader로 이동할 때 
            struct VertexOutput
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 WorldSpaceViewDirection : TEXCOORD0;
            };

            float _RimPower, _RimInten;
            half4 _RimColor;

            // 버텍스 셰이더
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.normal = TransformObjectToWorldNormal(v.normal);

                // 지정된 객체 공간 정점 위치에서 카메라 방향으로 월드 공간을 방향을 계산하고 정규화 합니다.
                // 월드공간 카메라 좌표 - 우러드 공간 버텍스 좌표
                o.WorldSpaceViewDirection = normalize(_WorldSpaceCameraPos.xyz -
                    mul(GetObjectToWorldMatrix(), float4(v.vertex.xyz, 1.0)).xyz);
                return o;
            }

            // 픽셀 셰이더
            half4 frag(VertexOutput i) : SV_Target
            {
                half4 color = half4(0.5,0.5,0.5,1);
                float3 light = _MainLightPosition.xyz;
                
                half3 ambient = SampleSH(i.normal);

                // 월드 카메라 벡터와 노멀을 내적해 방향에 대한 값을 구합니다.
                // 바라보는 방향이 같은 1(밝음)
                // 90도면 0(어두움)이 됩니다.
                half face = saturate(dot(i.WorldSpaceViewDirection, i.normal));
                half3 rim = 1.0 - (pow(face, _RimPower));

                color.rgb *= saturate(dot(i.normal, light)) * _MainLightColor.rgb + ambient;
                color.rgb += rim * _RimInten * _RimColor;
                return color;
            }
            ENDHLSL
        }
    }
}
