{% macro apply_config(args) %}

    {% set segment_ref = args.get('segment_ref') %}
    {% set version = args.get('version') %}
    {% set message_type = args.get('message_type') %}
    {% set config = args.get('config') %}
    {% set config_override = args.get('config_override') %}

    {% if config %}

        {% set message_config = config %}

    {% else %}

        {% set message_config = easyhl7.get_message_config(
            version,
            message_type
        ) %}

        {% if config_override %}

            {% set message_config = easyhl7.merge_config_overrides(
                message_config,
                config_override
            ) %}

        {% endif %}

    {% endif %}

    {{ easyhl7.apply_group_config(
        segment_ref,
        message_config
    ) }}

{% endmacro %}