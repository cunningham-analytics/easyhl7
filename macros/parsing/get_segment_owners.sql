{% macro get_segment_owners(
    node,
    segment_name,
    active_group=none,
    active_seq=none,
    active_start_seq=none
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
                    'start_seq': active_start_seq
                }) %}

            {% endif %}


        {% elif child.get('type') == 'group' %}

            {% if child.get('anchor') %}

                {% set child_group =
                    child.get('name')
                %}

                {% set child_seq =
                    child_group | lower ~ '_seq'
                %}

                {% set child_start_seq =
                    child_group | lower ~ '_start_seq'
                %}

            {% else %}

                {#
                    Structural/unanchored groups do not establish
                    a new owner. Their direct segments belong to
                    the nearest anchored group.
                #}

                {% set child_group = active_group %}
                {% set child_seq = active_seq %}
                {% set child_start_seq = active_start_seq %}

            {% endif %}

            {% set child_owners =
                easyhl7.get_segment_owners(
                    child,
                    segment_name,
                    child_group,
                    child_seq,
                    child_start_seq
                )
            %}

            {% for owner in child_owners %}

                {% do ns.owners.append(owner) %}

            {% endfor %}

        {% endif %}

    {% endfor %}

    {{ return(ns.owners) }}

{% endmacro %}