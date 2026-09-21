{% macro get_group_ancestors(node, target_group, ancestors=[]) %}

    {% for child in node.get('children', []) %}

        {% if child.get('type') == 'group' %}

            {% if child.get('name') == target_group %}

                {{ return(ancestors) }}

            {% endif %}

            {% set child_seq = child.get('name') | lower ~ '_seq' %}
            {% set child_ancestors = ancestors + [child_seq] %}

            {% set result = easyhl7.get_group_ancestors(
                child,
                target_group,
                child_ancestors
            ) %}

            {% if result is not none %}
                {{ return(result) }}
            {% endif %}

        {% endif %}

    {% endfor %}

    {{ return(none) }}

{% endmacro %}