{% macro apply_config(args) %}

    {% set segment_ref = args.get('segment_ref') %}
    {% set version = args.get('version') %}
    {% set message_type = args.get('message_type') %}

    {% set message_config = easyhl7.get_message_config(
        version,
        message_type
    ) %}

    {{ easyhl7.apply_group_config(
        segment_ref,
        message_config
    ) }}

{% endmacro %}