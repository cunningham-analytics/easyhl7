{% macro apply_group_config(segment_ref, message_config) %}

    with base as (

        select *
        from {{ ref(segment_ref) }}

    )

    {{ easyhl7.build_group_ctes(
        message_config,
        'base'
    ) }}

{% endmacro %}