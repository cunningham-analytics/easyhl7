{% macro get_message_config(version, message_type) %}

    {% if version == '2.1' and message_type == 'ORU_R01' %}
        {{ return(easyhl7.config_v2_1_ORU_R01()) }}

    {% elif version == '2.1' and message_type == 'ORM_O01' %}
        {{ return(easyhl7.config_v2_1_ORM_O01()) }}

    {% elif version == '2.2' and message_type == 'ORU_R01' %}
        {{ return(easyhl7.config_v2_2_ORU_R01()) }}

    {% elif version == '2.2' and message_type == 'ORM_O01' %}
        {{ return(easyhl7.config_v2_2_ORM_O01()) }}

    {% elif version == '2.3' and message_type == 'ORU_R01' %}
        {{ return(easyhl7.config_v2_3_ORU_R01()) }}

    {% elif version == '2.3' and message_type == 'ORM_O01' %}
        {{ return(easyhl7.config_v2_3_ORM_O01()) }}

    {% elif version == '2.3.1' and message_type == 'ORU_R01' %}
        {{ return(easyhl7.config_v2_3_1_ORU_R01()) }}

    {% elif version == '2.3.1' and message_type == 'ORM_O01' %}
        {{ return(easyhl7.config_v2_3_1_ORM_O01()) }}

    {% elif version == '2.3' and message_type == 'ORU_R01' %}
    {{ return(easyhl7.config_v2_3_ORU_R01()) }}

    {% elif version == '2.3' and message_type == 'ORM_O01' %}
        {{ return(easyhl7.config_v2_3_ORM_O01()) }}

    {% else %}
        {{ exceptions.raise_compiler_error(
            "EasyHL7 does not support version="
            ~ version
            ~ ", message_type="
            ~ message_type
        ) }}
    {% endif %}

{% endmacro %}