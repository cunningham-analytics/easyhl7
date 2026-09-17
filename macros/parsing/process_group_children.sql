{% macro process_group_children(node, ns, parent_seqs=[]) %}

    {% for child in node.get('children', []) %}

        {% if child.get('type') == 'group' %}

            {% if child.get('anchor') %}

                {% set ns.counter = ns.counter + 1 %}

                {% set boundary_cte =
                    'group_boundary_' ~ ns.counter
                %}

                {% set anchor_cte =
                    'group_anchor_' ~ ns.counter
                %}

                {% set group_cte =
                    'group_' ~ ns.counter
                %}


                {% set current_group_seq =
                    child.get('name') | lower ~ '_seq'
                %}

                {% set current_group_start_seq =
                    child.get('name') | lower ~ '_start_seq'
                %}


                {% set raw_group_seq =
                    '__group_seq_' ~ ns.counter
                %}

                {% set raw_group_start_seq =
                    '__group_start_seq_' ~ ns.counter
                %}

                {% set raw_group_boundary_seq =
                    '__group_boundary_seq_' ~ ns.counter
                %}


                {% set anchor =
                    child.get('anchor')
                %}

                {% set preamble =
                    child.get('preamble', [])
                %}

                {% set boundaries =
                    easyhl7.get_group_boundaries(
                        node,
                        child.get('name')
                    )
                %}


                {#
                    First determine the most recent structural
                    boundary for this group.

                    The partition is the anchored parent
                    occurrence, when one exists.
                #}

                ,
                {{ boundary_cte }} as (

                    select
                        *,

                        {% if boundaries | length > 0 %}

                            coalesce(
                                max(
                                    case

                                        when segment_type in (

                                            {% for segment in boundaries %}

                                                '{{ segment }}'
                                                {% if not loop.last %},{% endif %}

                                            {% endfor %}

                                        )
                                            then segment_sequence

                                    end
                                ) over (

                                    partition by
                                        msg_control_id

                                        {% for parent_seq in parent_seqs %}
                                            , {{ parent_seq }}
                                        {% endfor %}

                                    order by segment_sequence

                                    rows between
                                        unbounded preceding
                                        and current row

                                ),
                                0
                            )

                        {% else %}

                            0

                        {% endif %}

                        as {{ raw_group_boundary_seq }}

                    from {{ ns.previous_cte }}

                )



                ,
                {{ anchor_cte }} as (

                    select
                        *,

                        sum(
                            case

                                when

                                    {% if parent_seqs | length > 0 %}

                                        {% for parent_seq in parent_seqs %}

                                            {{ parent_seq }} > 0
                                            and

                                        {% endfor %}

                                    {% endif %}


                                    {% if
                                        boundaries | length > 0
                                        and parent_seqs | length > 0
                                    %}

                                        {{ raw_group_boundary_seq }} = 0
                                        and

                                    {% endif %}


                                    (

                                        {% if anchor is string %}

                                            segment_type = '{{ anchor }}'

                                        {% else %}

                                            segment_type in (

                                                {% for segment in anchor %}

                                                    '{{ segment }}'
                                                    {% if not loop.last %},{% endif %}

                                                {% endfor %}

                                            )

                                        {% endif %}

                                    )

                                    then 1

                                else 0

                            end
                        ) over (

                            partition by
                                msg_control_id

                                {% for parent_seq in parent_seqs %}
                                    , {{ parent_seq }}
                                {% endfor %}

                            order by segment_sequence

                            rows between
                                unbounded preceding
                                and current row

                        ) as {{ raw_group_seq }},


                        max(
                            case

                                when

                                    {% if parent_seqs | length > 0 %}

                                        {% for parent_seq in parent_seqs %}

                                            {{ parent_seq }} > 0
                                            and

                                        {% endfor %}

                                    {% endif %}


                                    {% if
                                        boundaries | length > 0
                                        and parent_seqs | length > 0
                                    %}

                                        {{ raw_group_boundary_seq }} = 0
                                        and

                                    {% endif %}


                                    (

                                        {% if preamble | length > 0 %}

                                            segment_type in (

                                                {% for segment in preamble %}

                                                    '{{ segment }}',
                                                {% endfor %}

                                                {% if anchor is string %}

                                                    '{{ anchor }}'

                                                {% else %}

                                                    {% for segment in anchor %}

                                                        '{{ segment }}'
                                                        {% if not loop.last %},{% endif %}

                                                    {% endfor %}

                                                {% endif %}

                                            )

                                        {% else %}

                                            {% if anchor is string %}

                                                segment_type = '{{ anchor }}'

                                            {% else %}

                                                segment_type in (

                                                    {% for segment in anchor %}

                                                        '{{ segment }}'
                                                        {% if not loop.last %},{% endif %}

                                                    {% endfor %}

                                                )

                                            {% endif %}

                                        {% endif %}

                                    )

                                    then segment_sequence

                            end
                        ) over (

                            partition by
                                msg_control_id

                                {% for parent_seq in parent_seqs %}
                                    , {{ parent_seq }}
                                {% endfor %}

                            order by segment_sequence

                            rows between
                                unbounded preceding
                                and current row

                        ) as {{ raw_group_start_seq }}

                    from {{ boundary_cte }}

                )


                {#
                    Final group membership.

                    The occurrence counter may continue to exist
                    internally, but the public *_seq column is
                    nonzero only while this group is structurally
                    active.

                    A boundary at the current row therefore
                    immediately closes the group.
                #}

                ,
                {{ group_cte }} as (

                    select
                        *,

                        case

                            when

                                {% if parent_seqs | length > 0 %}

                                    {% for parent_seq in parent_seqs %}

                                        {{ parent_seq }} > 0
                                        and

                                    {% endfor %}

                                {% endif %}

                                coalesce(
                                    {{ raw_group_start_seq }},
                                    0
                                )
                                >
                                {{ raw_group_boundary_seq }}

                            then

                                {% if preamble | length > 0 %}

                                    case

                                        when segment_type in (

                                            {% for segment in preamble %}

                                                '{{ segment }}'
                                                {% if not loop.last %},{% endif %}

                                            {% endfor %}

                                        )
                                            then {{ raw_group_seq }} + 1

                                        else {{ raw_group_seq }}

                                    end

                                {% else %}

                                    {{ raw_group_seq }}

                                {% endif %}

                            else 0

                        end as {{ current_group_seq }},


                        case

                            when

                                {% if parent_seqs | length > 0 %}

                                    {% for parent_seq in parent_seqs %}

                                        {{ parent_seq }} > 0
                                        and

                                    {% endfor %}

                                {% endif %}

                                coalesce(
                                    {{ raw_group_start_seq }},
                                    0
                                )
                                >
                                {{ raw_group_boundary_seq }}

                            then coalesce(
                                {{ raw_group_start_seq }},
                                0
                            )

                            else 0

                        end as {{ current_group_start_seq }}

                    from {{ anchor_cte }}

                )


                {% set ns.previous_cte =
                    group_cte
                %}


                {% set child_parent_seqs =
                    parent_seqs + [current_group_seq]
                %}


                {{ easyhl7.process_group_children(
                    child,
                    ns,
                    child_parent_seqs
                ) }}


            {% else %}

                {#
                    Structural/unanchored groups do not create
                    sequence columns, but their children still
                    inherit the currently active anchored
                    ancestors.
                #}

                {{ easyhl7.process_group_children(
                    child,
                    ns,
                    parent_seqs
                ) }}

            {% endif %}

        {% endif %}

    {% endfor %}

{% endmacro %}