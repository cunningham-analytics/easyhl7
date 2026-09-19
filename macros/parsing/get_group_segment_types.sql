{% macro get_group_segment_types(node) %}

    {% set ns = namespace(segments=[]) %}

    {#
        Return every segment type that is structurally legal anywhere
        inside this node's subtree.

        Boundary discovery uses this to distinguish a true transition
        out of a group from a segment type that can also legally occur
        inside that group.
    #}

    {% for child in node.get('children', []) %}

        {% if child.get('type') == 'segment' %}

            {% set segment_name = child.get('name') %}

            {% if segment_name not in ns.segments %}
                {% do ns.segments.append(segment_name) %}
            {% endif %}

        {% elif child.get('type') == 'group' %}

            {% set child_segments =
                easyhl7.get_group_segment_types(child)
            %}

            {% for segment in child_segments %}

                {% if segment not in ns.segments %}
                    {% do ns.segments.append(segment) %}
                {% endif %}

            {% endfor %}

        {% endif %}

    {% endfor %}


    {{ return(ns.segments) }}

{% endmacro %}
