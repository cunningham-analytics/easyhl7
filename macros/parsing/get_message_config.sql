{% macro get_message_config(version, message_type) %}

    {% if version == '2.1' and message_type == 'ORU_R01' %}

        {{ return(easyhl7.config_v2_1_ORU_R01()) }}

    {% else %}

        {{ exceptions.raise_compiler_error(
            "EasyHL7 does not support version="
            ~ version
            ~ ", message_type="
            ~ message_type
        ) }}

    {% endif %}

{% endmacro %}