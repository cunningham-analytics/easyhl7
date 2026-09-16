{% macro process_group_children(node, ns, parent_seqs=[]) %}

    {% for child in node.get('children', []) %}

        {% if child.get('type') == 'group' %}

            {% if child.get('anchor') %}

                {% set ns.counter = ns.counter + 1 %}

                {% set anchor_cte = 'group_anchor_' ~ ns.counter %}
                {% set group_cte = 'group_' ~ ns.counter %}
                {% set current_group_seq = child.get('name') | lower ~ '_seq' %}
                {% set anchor = child.get('anchor') %}

                ,
                {{ anchor_cte }} as (

                    select
                        *,

                        sum(
                            case

                                {% if anchor is string %}

                                    when segment_type = '{{ anchor }}'
                                        then 1

                                {% else %}

                                    when segment_type in (

                                        {% for segment in anchor %}
                                            '{{ segment }}'
                                            {% if not loop.last %},{% endif %}
                                        {% endfor %}

                                    )
                                        then 1

                                {% endif %}

                                else 0
                            end
                        ) over (
                            partition by
                                msg_control_id

                                {% for parent_seq in parent_seqs %}
                                    , {{ parent_seq }}
                                {% endfor %}

                            order by segment_sequence
                            rows between unbounded preceding and current row
                        ) as __group_seq_{{ ns.counter }}

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
                                    then __group_seq_{{ ns.counter }} + 1

                                else __group_seq_{{ ns.counter }}
                            end

                        {% else %}

                            __group_seq_{{ ns.counter }}

                        {% endif %}

                        as {{ current_group_seq }}

                    from {{ anchor_cte }}

                )

                {% set ns.previous_cte = group_cte %}

                {% set child_parent_seqs =
                    parent_seqs + [current_group_seq]
                %}

                {{ easyhl7.process_group_children(
                    child,
                    ns,
                    child_parent_seqs
                ) }}

            {% else %}

                {{ easyhl7.process_group_children(
                    child,
                    ns,
                    parent_seqs
                ) }}

            {% endif %}

        {% endif %}

    {% endfor %}

{% endmacro %}