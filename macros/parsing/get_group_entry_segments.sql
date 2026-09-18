{% macro get_group_entry_segments(node) %}

    {% set ns = namespace(segments=[]) %}

    {#
        A group's structural entry points are:

          1. preamble segments
          2. anchor segments
          3. explicit scope_entry segments

        anchor:
            establishes a new observable group occurrence

        scope_entry:
            establishes structural membership only; it does not
            establish or increment the group's occurrence sequence

        For structural/unanchored groups, entry is derived recursively
        from the possible entry points of their children.
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

    {% endif %}


    {% set scope_entry = node.get('scope_entry', []) %}

    {% if scope_entry %}

        {% if scope_entry is string %}

            {% if scope_entry not in ns.segments %}
                {% do ns.segments.append(scope_entry) %}
            {% endif %}

        {% else %}

            {% for segment in scope_entry %}

                {% if segment not in ns.segments %}
                    {% do ns.segments.append(segment) %}
                {% endif %}

            {% endfor %}

        {% endif %}

    {% endif %}


    {% if not anchor %}

        {#
            Structural/unanchored group.

            It has no occurrence anchor of its own, so entry into it
            is represented by the possible entry points of its
            children.

            Explicit scope_entry values above are retained as
            additional valid structural entry points.
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