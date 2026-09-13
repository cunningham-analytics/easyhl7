{% macro process_group_children(node, ns, parent_ids=[]) %}

    {% for child in node.get('children', []) %}

        {% if child.get('type') == 'group' %}

            {% if child.get('anchor') %}

                {% set ns.counter = ns.counter + 1 %}

                {% set anchor_cte = 'group_anchor_' ~ ns.counter %}
                {% set group_cte = 'group_' ~ ns.counter %}
                {% set current_group_id = child.get('name') | lower ~ '_id' %}

                ,
                {{ anchor_cte }} as (

                    select
                        *,

                        sum(
                            case
                                when segment_type = '{{ child.get("anchor") }}'
                                    then 1
                                else 0
                            end
                        ) over (
                            partition by
                                msg_control_id

                                {% for parent_id in parent_ids %}
                                    , {{ parent_id }}
                                {% endfor %}

                            order by segment_sequence
                            rows between unbounded preceding and current row
                        ) as __group_id_{{ ns.counter }}

                    from {{ ns.previous_cte }}

                )

                ,
                {{ group_cte }} as (

                    select
                        *,

                        {% if child.get('preamble', []) | length > 0 %}

                            case
                                when segment_type in (

                                    {% for segment in child.get('preamble', []) %}
                                        '{{ segment }}'
                                        {% if not loop.last %},{% endif %}
                                    {% endfor %}

                                )
                                    then __group_id_{{ ns.counter }} + 1

                                else __group_id_{{ ns.counter }}
                            end

                        {% else %}

                            __group_id_{{ ns.counter }}

                        {% endif %}

                        as {{ current_group_id }}

                    from {{ anchor_cte }}

                )

                {% set ns.previous_cte = group_cte %}

                {% set child_parent_ids = parent_ids + [current_group_id] %}

                {{ easyhl7.process_group_children(
                    child,
                    ns,
                    child_parent_ids
                ) }}

            {% else %}

                {{ easyhl7.process_group_children(
                    child,
                    ns,
                    parent_ids
                ) }}

            {% endif %}

        {% endif %}

    {% endfor %}

{% endmacro %}