{% macro debug_group_boundaries() %}

    {% set config = easyhl7.config_v2_4_DFT_P03() %}

    {% set groups = [
        'COMMON_ORDER',
        'FINANCIAL'
    ] %}

    {% for group_name in groups %}

        {% set boundaries =
            easyhl7.get_group_boundaries(
                config,
                group_name
            )
        %}

        {{ log(
            group_name
            ~ ' boundaries: '
            ~ boundaries,
            info=true
        ) }}

    {% endfor %}

{% endmacro %}