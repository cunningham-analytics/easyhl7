{% macro find_config_node(node, node_name) %}

    {% if node.get('name') == node_name %}
        {{ return(node) }}
    {% endif %}

    {% for child in node.get('children', []) %}

        {% set result = easyhl7.find_config_node(child, node_name) %}

        {% if result is not none %}
            {{ return(result) }}
        {% endif %}

    {% endfor %}

    {{ return(none) }}

{% endmacro %}