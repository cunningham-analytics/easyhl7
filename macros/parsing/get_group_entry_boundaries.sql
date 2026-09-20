{% macro get_group_entry_boundaries(parent_node, group_name) %}

    {% set ns = namespace(
        entry_boundaries=[],
        found_group=false,
        target_node=none,
        target_segments=[],
        candidate=none
    ) %}


    {% for child in parent_node.get('children', []) %}

        {% if
            child.get('type') == 'group'
            and child.get('name') == group_name
        %}

            {% set ns.target_node = child %}

        {% endif %}

    {% endfor %}


    {% if ns.target_node %}

        {% set ns.target_segments =
            easyhl7.get_group_segment_types(
                ns.target_node
            )
        %}

    {% endif %}


    {% for child in parent_node.get('children', []) %}

        {% set is_target =
            child.get('type') == 'group'
            and child.get('name') == group_name
        %}


        {% if is_target %}

            {% set ns.found_group = true %}


        {% elif not ns.found_group %}

            {% if
                child.get('type') == 'segment'
                and child.get('min', 0) > 0
            %}

                {% set segment_name =
                    child.get('name')
                %}

                {% if
                    segment_name not in ns.target_segments
                %}

                    {% set ns.candidate =
                        segment_name
                    %}

                {% endif %}

            {% endif %}

        {% endif %}

    {% endfor %}


    {% if ns.candidate %}

        {% do ns.entry_boundaries.append(
            ns.candidate
        ) %}

    {% endif %}


    {{ return(ns.entry_boundaries) }}

{% endmacro %}