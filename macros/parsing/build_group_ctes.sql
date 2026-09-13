{% macro build_group_ctes(node, previous_cte) %}

    {% set ns = namespace(
        previous_cte=previous_cte,
        counter=0
    ) %}

    {{ easyhl7.process_group_children(
        node,
        ns
    ) }}

    select *
    from {{ ns.previous_cte }}

{% endmacro %}