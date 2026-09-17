{% macro get_segment_owners(
    node,
    segment_name,
    depth=0,
    active_group=none,
    active_seq=none
) %}

    {% set ns = namespace(owners=[]) %}

    {% for child in node.get('children', []) %}

        {% if child.get('type') == 'segment' %}

            {% if
                child.get('name') == segment_name
                and active_group
            %}

                {% do ns.owners.append({
                    'group': active_group,
                    'seq': active_seq,
                    'depth': depth
                }) %}

            {% endif %}

        {% elif child.get('type') == 'group' %}

            {% if child.get('anchor') %}

                {% set child_group = child.get('name') %}
                {% set child_seq =
                    child_group | lower ~ '_seq'
                %}

            {% else %}

                {% set child_group = active_group %}
                {% set child_seq = active_seq %}

            {% endif %}

            {% set child_owners =
                easyhl7.get_segment_owners(
                    child,
                    segment_name,
                    depth + 1,
                    child_group,
                    child_seq
                )
            %}

            {% for owner in child_owners %}
                {% do ns.owners.append(owner) %}
            {% endfor %}

        {% endif %}

    {% endfor %}

    {{ return(ns.owners) }}

{% endmacro %}