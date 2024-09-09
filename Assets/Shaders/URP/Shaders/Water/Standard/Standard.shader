Shader "CURP/Water/Standard"
{
    Properties
    {
        //Matcap贴图
        _MatcapMap("Matcap Map",2D) = "white" {}
        _MatcapColor("Matcap Color",Color) = (1,1,1,1)

    }
    SubShader
    {
        Tags {
            "RenderType" = "Transparency"   
            "IgnoreProjector" = "True"
            "UniversalMaterialType" = "Unlit"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Tags {"LightMode" = "UniversalForwardOnly"}
            
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            ZTest LEqual
            ZClip Off
            
            HLSLPROGRAM

            #pragma vertex Vert;
            #pragma fragment Frag;

            struct Atrributes
            {
                
            };

            struct Varings
            {
                
            };

            Varings Vert(Atrributes IN)
            {
                Varings OUT;
                return OUT;
            }

            half4 Frag(Varings IN) : SV_Target
            {
                half4 color = half4(1,1,1,1);
                return color;
            }
            
            ENDHLSL
        }
    }

}
