{% macro get_group_entry_segments(node) %}

    {% set ns = namespace(segments=[]) %}

    {#
        A preamble can establish the group before its anchor.
        Include both the preamble and anchor because the
        preamble may be absent.
    #}

    {% for segment in node.get('preamble', []) %}

        {% if segment not in ns.segments %}
            {% do ns.segments.append(segment) %}
        {% endif %}

    {% endfor %}


    {% set anchor = node.get('anchor') %}

    {% if anchor %}

        {% if anchor is string %}

            {% if anchor not in ns.segments %}
                {% do ns.segments.append(anchor) %}
            {% endif %}

        {% else %}

            {% for segment in anchor %}

                {% if segment not in ns.segments %}
                    {% do ns.segments.append(segment) %}
                {% endif %}

            {% endfor %}

        {% endif %}

    {% else %}

        {#
            Structural/unanchored group.

            It has no anchor of its own, so entry into it is
            represented by the possible entry points of its
            children.
        #}

        {% for child in node.get('children', []) %}

            {% if child.get('type') == 'segment' %}

                {% set segment_name = child.get('name') %}

                {% if segment_name not in ns.segments %}
                    {% do ns.segments.append(segment_name) %}
                {% endif %}

            {% elif child.get('type') == 'group' %}

                {% set child_entries =
                    easyhl7.get_group_entry_segments(child)
                %}

                {% for segment in child_entries %}

                    {% if segment not in ns.segments %}
                        {% do ns.segments.append(segment) %}
                    {% endif %}

                {% endfor %}

            {% endif %}

        {% endfor %}

    {% endif %}

    {{ return(ns.segments) }}

{% endmacro %}