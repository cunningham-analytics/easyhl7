{% macro merge_config_overrides(node, overrides) %}

    {% set node_name = node.get('name') %}

    {% if node_name in overrides %}
        {% set node_override = overrides.get(node_name) %}

        {% for key, value in node_override.items() %}
            {% do node.update({key: value}) %}
        {% endfor %}
    {% endif %}

    {% for child in node.get('children', []) %}

        {% if child.get('type') == 'group' %}

            {% do easyhl7.merge_config_overrides(
                child,
                overrides
            ) %}

        {% endif %}

    {% endfor %}

    {{ return(node) }}

{% endmacro %}