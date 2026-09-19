{% macro get_group_boundaries(parent_node, group_name) %}

    {% set ns = namespace(
        boundaries=[],
        found_group=false,
        target_node=none,
        target_segments=[]
    ) %}


    {#
        Collect every segment type legal inside the target group's
        subtree.

        A segment type that is legal inside the target cannot safely
        be used as a boundary merely because that same segment type
        also appears later in the parent's grammar.
    #}

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


    {% set parent_has_anchor =
        parent_node.get('anchor')
    %}


    {% for child in parent_node.get('children', []) %}

        {% set is_target =
            child.get('type') == 'group'
            and child.get('name') == group_name
        %}


        {% if is_target %}

            {% set ns.found_group = true %}


        {% else %}

            {% if parent_has_anchor %}

                {#
                    The parent is a real anchored occurrence.

                    Once we enter a later sibling node, the current
                    child group is finished.

                    Later direct segments and entries into later
                    sibling groups are candidate boundaries.

                    If a candidate segment type is also legal anywhere
                    inside the target group's subtree, it is ambiguous
                    and is excluded from the boundary set.
                #}

                {% if ns.found_group %}

                    {% if child.get('type') == 'segment' %}

                        {% set segment_name =
                            child.get('name')
                        %}

                        {% if
                            segment_name not in ns.target_segments
                            and segment_name not in ns.boundaries
                        %}

                            {% do ns.boundaries.append(
                                segment_name
                            ) %}

                        {% endif %}


                    {% elif child.get('type') == 'group' %}

                        {% set entries =
                            easyhl7.get_group_entry_segments(
                                child
                            )
                        %}

                        {% for segment in entries %}

                            {% if
                                segment not in ns.target_segments
                                and segment not in ns.boundaries
                            %}

                                {% do ns.boundaries.append(
                                    segment
                                ) %}

                            {% endif %}

                        {% endfor %}

                    {% endif %}

                {% endif %}


            {% else %}

                {#
                    The parent is structural/unanchored.

                    Direct segment siblings are NOT boundaries for
                    child groups because those segment types may
                    legally recur inside structural branches.

                    Only entry into a LATER sibling GROUP establishes
                    a structural transition.

                    As above, an entry segment that is also legal
                    inside the target group's subtree is ambiguous and
                    is excluded.
                #}

                {% if ns.found_group %}

                    {% if child.get('type') == 'group' %}

                        {% set entries =
                            easyhl7.get_group_entry_segments(
                                child
                            )
                        %}

                        {% for segment in entries %}

                            {% if
                                segment not in ns.target_segments
                                and segment not in ns.boundaries
                            %}

                                {% do ns.boundaries.append(
                                    segment
                                ) %}

                            {% endif %}

                        {% endfor %}

                    {% endif %}

                {% endif %}

            {% endif %}

        {% endif %}

    {% endfor %}


    {{ return(ns.boundaries) }}

{% endmacro %}