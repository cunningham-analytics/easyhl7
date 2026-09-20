{% macro get_message_config(version, message_type) %}

    {% if version == '2.1' and message_type == 'ORU_R01' %}
        {{ return(easyhl7.config_v2_1_ORU_R01()) }}

    {% elif version == '2.1' and message_type == 'ORM_O01' %}
        {{ return(easyhl7.config_v2_1_ORM_O01()) }}

    {% elif version == '2.1' and message_type == 'DFT_P03' %}
        {{ return(easyhl7.config_v2_1_DFT_P03()) }}

    {% elif version == '2.1' and message_type == 'ADT_A01' %}
        {{ return(easyhl7.config_v2_1_ADT_A01()) }}

    {% elif version == '2.1' and message_type == 'ADT_A02' %}
        {{ return(easyhl7.config_v2_1_ADT_A02()) }}

    {% elif version == '2.1' and message_type == 'ADT_A03' %}
        {{ return(easyhl7.config_v2_1_ADT_A03()) }}


    {% elif version == '2.2' and message_type == 'ORU_R01' %}
        {{ return(easyhl7.config_v2_2_ORU_R01()) }}

    {% elif version == '2.2' and message_type == 'ORM_O01' %}
        {{ return(easyhl7.config_v2_2_ORM_O01()) }}

    {% elif version == '2.2' and message_type == 'DFT_P03' %}
        {{ return(easyhl7.config_v2_2_DFT_P03()) }}

    {% elif version == '2.2' and message_type == 'ADT_A01' %}
        {{ return(easyhl7.config_v2_2_ADT_A01()) }}

    {% elif version == '2.2' and message_type == 'ADT_A02' %}
        {{ return(easyhl7.config_v2_2_ADT_A02()) }}

    {% elif version == '2.2' and message_type == 'ADT_A03' %}
        {{ return(easyhl7.config_v2_2_ADT_A03()) }}


    {% elif version == '2.3' and message_type == 'ORU_R01' %}
        {{ return(easyhl7.config_v2_3_ORU_R01()) }}

    {% elif version == '2.3' and message_type == 'ORM_O01' %}
        {{ return(easyhl7.config_v2_3_ORM_O01()) }}

    {% elif version in ['2.3', '2.3.1'] and message_type == 'DFT_P03' %}
        {{ return(easyhl7.config_v2_3_DFT_P03()) }}

    {% elif version == '2.3' and message_type == 'ADT_A01' %}
        {{ return(easyhl7.config_v2_3_ADT_A01()) }}

    {% elif version in ['2.3', '2.3.1'] and message_type == 'ADT_A02' %}
        {{ return(easyhl7.config_v2_3_ADT_A02()) }}

    {% elif version == '2.3' and message_type == 'ADT_A03' %}
        {{ return(easyhl7.config_v2_3_ADT_A03()) }}

    {% elif version == '2.3' and message_type == 'MDM_T02' %}
        {{ return(easyhl7.config_v2_3_MDM_T02()) }}

    {% elif version == '2.3' and message_type == 'MDM_T08' %}
        {{ return(easyhl7.config_v2_3_MDM_T08()) }}

    {% elif version == '2.3' and message_type == 'RAS_O01' %}
        {{ return(easyhl7.config_v2_3_RAS_O01()) }}


    {% elif version == '2.3.1' and message_type == 'ORU_R01' %}
        {{ return(easyhl7.config_v2_3_1_ORU_R01()) }}

    {% elif version == '2.3.1' and message_type == 'ORM_O01' %}
        {{ return(easyhl7.config_v2_3_1_ORM_O01()) }}

    {% elif version == '2.3.1' and message_type == 'ADT_A01' %}
        {{ return(easyhl7.config_v2_3_1_ADT_A01()) }}

    {% elif version == '2.3.1' and message_type == 'ADT_A03' %}
        {{ return(easyhl7.config_v2_3_1_ADT_A03()) }}

    {% elif version == '2.3.1' and message_type == 'MDM_T02' %}
        {{ return(easyhl7.config_v2_3_1_MDM_T02()) }}

    {% elif version == '2.3.1' and message_type == 'MDM_T08' %}
        {{ return(easyhl7.config_v2_3_1_MDM_T08()) }}

    {% elif version == '2.3.1' and message_type == 'RAS_O01' %}
        {{ return(easyhl7.config_v2_3_1_RAS_O01()) }}


    {% elif version == '2.4' and message_type == 'ORU_R01' %}
        {{ return(easyhl7.config_v2_4_ORU_R01()) }}

    {% elif version == '2.4' and message_type == 'DFT_P03' %}
        {{ return(easyhl7.config_v2_4_DFT_P03()) }}

    {% elif version in ['2.4', '2.5', '2.6'] and message_type == 'ORM_O01' %}
        {{ return(easyhl7.config_v2_4_ORM_O01()) }}

    {% elif version == '2.4' and message_type == 'ADT_A01' %}
        {{ return(easyhl7.config_v2_4_ADT_A01()) }}

    {% elif version == '2.4' and message_type == 'ADT_A02' %}
        {{ return(easyhl7.config_v2_4_ADT_A02()) }}

    {% elif version == '2.4' and message_type == 'ADT_A03' %}
        {{ return(easyhl7.config_v2_4_ADT_A03()) }}

    {% elif version == '2.4' and message_type == 'MDM_T02' %}
        {{ return(easyhl7.config_v2_4_MDM_T02()) }}

    {% elif version == '2.4' and message_type == 'MDM_T08' %}
        {{ return(easyhl7.config_v2_4_MDM_T08()) }}

    {% elif version == '2.4' and message_type == 'RAS_O17' %}
        {{ return(easyhl7.config_v2_4_RAS_O17()) }}


    {% elif version in ['2.5', '2.5.1'] and message_type == 'ORU_R01' %}
        {{ return(easyhl7.config_v2_5_ORU_R01()) }}

    {% elif version in ['2.5', '2.5.1'] and message_type == 'DFT_P03' %}
        {{ return(easyhl7.config_v2_5_DFT_P03()) }}

    {% elif version in ['2.5', '2.5.1'] and message_type == 'ADT_A01' %}
        {{ return(easyhl7.config_v2_5_ADT_A01()) }}

    {% elif version in ['2.5', '2.5.1'] and message_type == 'ADT_A02' %}
        {{ return(easyhl7.config_v2_5_ADT_A02()) }}

    {% elif version in ['2.5', '2.5.1'] and message_type == 'ADT_A03' %}
        {{ return(easyhl7.config_v2_5_ADT_A03()) }}

    {% elif version in ['2.5', '2.5.1'] and message_type == 'MDM_T02' %}
        {{ return(easyhl7.config_v2_5_MDM_T02()) }}

    {% elif version in ['2.5', '2.5.1'] and message_type == 'MDM_T08' %}
        {{ return(easyhl7.config_v2_5_MDM_T08()) }}

    {% elif version in ['2.5', '2.5.1'] and message_type == 'RAS_O17' %}
        {{ return(easyhl7.config_v2_5_RAS_O17()) }}


    {% elif version == '2.6' and message_type == 'ORU_R01' %}
        {{ return(easyhl7.config_v2_6_ORU_R01()) }}

    {% elif version == '2.6' and message_type == 'DFT_P03' %}
        {{ return(easyhl7.config_v2_6_DFT_P03()) }}

    {% elif version == '2.6' and message_type == 'ADT_A01' %}
        {{ return(easyhl7.config_v2_6_ADT_A01()) }}

    {% elif version == '2.6' and message_type == 'ADT_A02' %}
        {{ return(easyhl7.config_v2_6_ADT_A02()) }}

    {% elif version == '2.6' and message_type == 'ADT_A03' %}
        {{ return(easyhl7.config_v2_6_ADT_A03()) }}

    {% elif version == '2.6' and message_type == 'MDM_T02' %}
        {{ return(easyhl7.config_v2_6_MDM_T02()) }}

    {% elif version == '2.6' and message_type == 'MDM_T08' %}
        {{ return(easyhl7.config_v2_6_MDM_T08()) }}

    {% elif version == '2.6' and message_type == 'RAS_O17' %}
        {{ return(easyhl7.config_v2_6_RAS_O17()) }}


    {% elif version == '2.1' and message_type == 'ADT_A08' %}
        {{ return(easyhl7.config_v2_1_ADT_A08()) }}

    {% elif version == '2.2' and message_type == 'ADT_A08' %}
        {{ return(easyhl7.config_v2_2_ADT_A08()) }}

    {% elif version == '2.3' and message_type == 'ADT_A08' %}
        {{ return(easyhl7.config_v2_3_ADT_A08()) }}

    {% elif version == '2.3.1' and message_type == 'ADT_A08' %}
        {{ return(easyhl7.config_v2_3_1_ADT_A08()) }}

    {% elif version == '2.4' and message_type == 'ADT_A08' %}
        {{ return(easyhl7.config_v2_4_ADT_A08()) }}

    {% elif version in ['2.5', '2.5.1'] and message_type == 'ADT_A08' %}
        {{ return(easyhl7.config_v2_5_ADT_A08()) }}

    {% elif version == '2.6' and message_type == 'ADT_A08' %}
        {{ return(easyhl7.config_v2_6_ADT_A08()) }}

    {% elif version in ['2.3', '2.3.1'] and message_type == 'RDE_O01' %}
        {{ return(easyhl7.config_v2_3_RDE_O01()) }}

    {% elif version == '2.4' and message_type == 'RDE_O11' %}
        {{ return(easyhl7.config_v2_4_RDE_O11()) }}

    {% elif version in ['2.5', '2.5.1'] and message_type == 'RDE_O11' %}
        {{ return(easyhl7.config_v2_5_RDE_O11()) }}

    {% elif version == '2.6' and message_type == 'RDE_O11' %}
        {{ return(easyhl7.config_v2_6_RDE_O11()) }}

    {% elif version == '2.1' and message_type == 'BAR_P01' %}
        {{ return(easyhl7.config_v2_1_BAR_P01()) }}

    {% elif version == '2.2' and message_type == 'BAR_P01' %}
        {{ return(easyhl7.config_v2_2_BAR_P01()) }}

    {% elif version in ['2.3', '2.3.1'] and message_type == 'BAR_P01' %}
        {{ return(easyhl7.config_v2_3_BAR_P01()) }}

    {% elif version == '2.4' and message_type == 'BAR_P01' %}
        {{ return(easyhl7.config_v2_4_BAR_P01()) }}

    {% elif version in ['2.5', '2.5.1'] and message_type == 'BAR_P01' %}
        {{ return(easyhl7.config_v2_5_BAR_P01()) }}

    {% elif version == '2.6' and message_type == 'BAR_P01' %}
        {{ return(easyhl7.config_v2_6_BAR_P01()) }}

    {% elif version == '2.1' and message_type == 'BAR_P02' %}
        {{ return(easyhl7.config_v2_1_BAR_P02()) }}

    {% elif version == '2.2' and message_type == 'BAR_P02' %}
        {{ return(easyhl7.config_v2_2_BAR_P02()) }}

    {% elif version in ['2.3', '2.3.1'] and message_type == 'BAR_P02' %}
        {{ return(easyhl7.config_v2_3_BAR_P02()) }}

    {% elif version == '2.4' and message_type == 'BAR_P02' %}
        {{ return(easyhl7.config_v2_4_BAR_P02()) }}

    {% elif version in ['2.5', '2.5.1'] and message_type == 'BAR_P02' %}
        {{ return(easyhl7.config_v2_5_BAR_P02()) }}

    {% elif version == '2.6' and message_type == 'BAR_P02' %}
        {{ return(easyhl7.config_v2_6_BAR_P02()) }}

    {% elif version in ['2.3', '2.3.1'] and message_type == 'BAR_P05' %}
        {{ return(easyhl7.config_v2_3_BAR_P05()) }}

    {% elif version == '2.4' and message_type == 'BAR_P05' %}
        {{ return(easyhl7.config_v2_4_BAR_P05()) }}

    {% elif version in ['2.5', '2.5.1'] and message_type == 'BAR_P05' %}
        {{ return(easyhl7.config_v2_5_BAR_P05()) }}

    {% elif version == '2.6' and message_type == 'BAR_P05' %}
        {{ return(easyhl7.config_v2_6_BAR_P05()) }}

    {% elif version in ['2.5', '2.5.1'] and message_type == 'BAR_P12' %}
        {{ return(easyhl7.config_v2_5_BAR_P12()) }}

    {% elif version == '2.6' and message_type == 'BAR_P12' %}
        {{ return(easyhl7.config_v2_6_BAR_P12()) }}


    {% else %}
        {{ exceptions.raise_compiler_error(
            "EasyHL7 does not support version="
            ~ version
            ~ ", message_type="
            ~ message_type
        ) }}
    {% endif %}

{% endmacro %}