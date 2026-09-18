{% macro get_group_boundaries(parent_node, group_name) %}

    {% set ns = namespace(
        boundaries=[],
        found_group=false
    ) %}


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

                    Once we enter a later sibling node, the
                    current child group is finished.

                    Later direct segments count because they
                    represent progression within the anchored
                    parent.

                    Example:

                        ORDER
                          ORDER_DETAIL
                          FT1
                          CTI
                          BLG

                    FT1 closes ORDER_DETAIL, but does not close
                    ORDER itself.
                #}

                {% if ns.found_group %}

                    {% if child.get('type') == 'segment' %}

                        {% set segment_name =
                            child.get('name')
                        %}

                        {% if segment_name not in ns.boundaries %}
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

                            {% if segment not in ns.boundaries %}
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

                    Direct segment siblings are NOT boundaries
                    for child groups.

                    Their segment types may legally occur again
                    inside one of the structural branches.

                    Only entry into a LATER sibling GROUP
                    establishes a structural transition.

                    Earlier sibling groups must not become
                    boundaries for later groups.

                    Example:

                        DFT_P03
                          COMMON_ORDER
                          FINANCIAL

                    FT1 closes COMMON_ORDER.

                    ORC / OBR / OBX from COMMON_ORDER must NOT
                    close FINANCIAL, because COMMON_ORDER occurs
                    before FINANCIAL in the grammar.
                #}

                {% if ns.found_group %}

                    {% if child.get('type') == 'group' %}

                        {% set entries =
                            easyhl7.get_group_entry_segments(
                                child
                            )
                        %}

                        {% for segment in entries %}

                            {% if segment not in ns.boundaries %}
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