{% macro process_group_children(
    node,
    ns,
    parent_seqs=[],
    parent_scopes=[]
) %}

    {% for child in node.get('children', []) %}

        {% if child.get('type') == 'group' %}

            {% if child.get('anchor') %}

                {% set ns.counter = ns.counter + 1 %}


                {% set entry_boundary_cte =
                    'group_entry_boundary_' ~ ns.counter
                %}

                {% set candidate_start_cte =
                    'group_candidate_start_' ~ ns.counter
                %}

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

                {% set current_group_scope =
                    '__' ~ child.get('name') | lower ~ '_scope_active'
                %}


                {% set raw_group_seq =
                    '__group_seq_' ~ ns.counter
                %}

                {% set raw_group_start_seq =
                    '__group_start_seq_' ~ ns.counter
                %}

                {% set raw_group_candidate_start_seq =
                    '__group_candidate_start_seq_' ~ ns.counter
                %}

                {% set raw_group_scope_start_seq =
                    '__group_scope_start_seq_' ~ ns.counter
                %}

                {% set raw_group_boundary_seq =
                    '__group_boundary_seq_' ~ ns.counter
                %}

                {% set raw_group_terminal_boundary_seq =
                    '__group_terminal_boundary_seq_' ~ ns.counter
                %}

                {% set raw_group_entry_boundary_seq =
                    '__group_entry_boundary_seq_' ~ ns.counter
                %}


                {% set anchor =
                    child.get('anchor')
                %}

                {% set preamble =
                    child.get('preamble', [])
                %}

                {% set scope_entry =
                    child.get('scope_entry', [])
                %}

                {% set has_scope_entry =
                    scope_entry | length > 0
                %}

                {% set boundaries =
                    easyhl7.get_group_boundaries(
                        node,
                        child.get('name')
                    )
                %}

                {% set entry_boundaries =
                    easyhl7.get_group_entry_boundaries(
                        node,
                        child.get('name')
                    )
                %}


                ,
                {{ entry_boundary_cte }} as (

                    select
                        *,

                        {% if entry_boundaries | length > 0 %}

                            coalesce(
                                max(
                                    case

                                        when segment_type in (

                                            {% for segment in entry_boundaries %}

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

                        as {{ raw_group_entry_boundary_seq }}

                    from {{ ns.previous_cte }}

                )


                ,
                {{ candidate_start_cte }} as (

                    select
                        *,

                        min(
                            case

                                when

                                    {% if parent_scopes | length > 0 %}

                                        {% for parent_scope in parent_scopes %}

                                            {{ parent_scope }}
                                            and

                                        {% endfor %}

                                    {% endif %}


                                    {% if entry_boundaries | length > 0 %}

                                        {{ raw_group_entry_boundary_seq }} > 0
                                        and
                                        segment_sequence
                                            >
                                        {{ raw_group_entry_boundary_seq }}
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

                        )

                        as {{ raw_group_candidate_start_seq }}

                    from {{ entry_boundary_cte }}

                )


                ,
                {{ boundary_cte }} as (

                    select
                        *,

                        {% if boundaries | length > 0 %}

                            coalesce(
                                max(
                                    case

                                        when
                                            segment_type in (

                                                {% for segment in boundaries %}

                                                    '{{ segment }}'
                                                    {% if not loop.last %},{% endif %}

                                                {% endfor %}

                                            )

                                            and
                                            {{ raw_group_candidate_start_seq }}
                                                is not null

                                            and
                                            segment_sequence
                                                >
                                            {{ raw_group_candidate_start_seq }}

                                            {% if entry_boundaries | length > 0 %}

                                            and
                                            {{ raw_group_entry_boundary_seq }} > 0

                                            and
                                            segment_sequence
                                                >
                                            {{ raw_group_entry_boundary_seq }}

                                            {% endif %}

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


                        {% if has_scope_entry %}

                            ,

                            {% if boundaries | length > 0 %}

                                min(
                                    case

                                        when
                                            segment_type in (

                                                {% for segment in boundaries %}

                                                    '{{ segment }}'
                                                    {% if not loop.last %},{% endif %}

                                                {% endfor %}

                                            )

                                            {% if entry_boundaries | length > 0 %}

                                            and
                                            {{ raw_group_entry_boundary_seq }} > 0

                                            and
                                            segment_sequence
                                                >
                                            {{ raw_group_entry_boundary_seq }}

                                            {% endif %}

                                            then segment_sequence

                                    end
                                ) over (

                                    partition by
                                        msg_control_id

                                        {% for parent_seq in parent_seqs %}
                                            , {{ parent_seq }}
                                        {% endfor %}

                                )

                            {% else %}

                                cast(null as bigint)

                            {% endif %}

                            as {{ raw_group_terminal_boundary_seq }}

                        {% endif %}

                    from {{ candidate_start_cte }}

                )


                ,
                {{ anchor_cte }} as (

                    select
                        *,

                        sum(
                            case

                                when

                                    {% if parent_scopes | length > 0 %}

                                        {% for parent_scope in parent_scopes %}

                                            {{ parent_scope }}
                                            and

                                        {% endfor %}

                                    {% endif %}


                                    {% if entry_boundaries | length > 0 %}

                                        {{ raw_group_entry_boundary_seq }} > 0
                                        and
                                        segment_sequence
                                            >
                                        {{ raw_group_entry_boundary_seq }}
                                        and

                                    {% endif %}


                                    {% if boundaries | length > 0 %}

                                        (
                                            {{ raw_group_boundary_seq }} = 0
                                            or
                                            segment_sequence
                                                <
                                            {{ raw_group_boundary_seq }}
                                        )
                                        and

                                    {% endif %}


                                    {% if has_scope_entry %}

                                        (
                                            {{ raw_group_terminal_boundary_seq }} is null
                                            or
                                            segment_sequence
                                                <
                                            {{ raw_group_terminal_boundary_seq }}
                                        )
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

                                    {% if parent_scopes | length > 0 %}

                                        {% for parent_scope in parent_scopes %}

                                            {{ parent_scope }}
                                            and

                                        {% endfor %}

                                    {% endif %}


                                    {% if entry_boundaries | length > 0 %}

                                        {{ raw_group_entry_boundary_seq }} > 0
                                        and
                                        segment_sequence
                                            >
                                        {{ raw_group_entry_boundary_seq }}
                                        and

                                    {% endif %}


                                    {% if boundaries | length > 0 %}

                                        (
                                            {{ raw_group_boundary_seq }} = 0
                                            or
                                            segment_sequence
                                                <
                                            {{ raw_group_boundary_seq }}
                                        )
                                        and

                                    {% endif %}


                                    {% if has_scope_entry %}

                                        (
                                            {{ raw_group_terminal_boundary_seq }} is null
                                            or
                                            segment_sequence
                                                <
                                            {{ raw_group_terminal_boundary_seq }}
                                        )
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


                        {% if has_scope_entry %}

                            ,

                            min(
                                case

                                    when

                                        {% if parent_scopes | length > 0 %}

                                            {% for parent_scope in parent_scopes %}

                                                {{ parent_scope }}
                                                and

                                            {% endfor %}

                                        {% endif %}


                                        {% if entry_boundaries | length > 0 %}

                                            {{ raw_group_entry_boundary_seq }} > 0
                                            and
                                            segment_sequence
                                                >
                                            {{ raw_group_entry_boundary_seq }}
                                            and

                                        {% endif %}


                                        (
                                            {{ raw_group_terminal_boundary_seq }} is null
                                            or
                                            segment_sequence
                                                <
                                            {{ raw_group_terminal_boundary_seq }}
                                        )
                                        and


                                        (

                                            {% if scope_entry is string %}

                                                segment_type =
                                                    '{{ scope_entry }}'

                                            {% else %}

                                                segment_type in (

                                                    {% for segment in scope_entry %}

                                                        '{{ segment }}'
                                                        {% if not loop.last %},{% endif %}

                                                    {% endfor %}

                                                )

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

                            )

                            as {{ raw_group_scope_start_seq }}

                        {% endif %}

                    from {{ boundary_cte }}

                )


                ,
                {{ group_cte }} as (

                    select
                        *,

                        case

                            when

                                {% if parent_scopes | length > 0 %}

                                    {% for parent_scope in parent_scopes %}

                                        {{ parent_scope }}
                                        and

                                    {% endfor %}

                                {% endif %}


                                {% if has_scope_entry %}

                                    (
                                        {{ raw_group_terminal_boundary_seq }} is null
                                        or
                                        segment_sequence
                                            <
                                        {{ raw_group_terminal_boundary_seq }}
                                    )
                                    and

                                    (
                                        coalesce(
                                            {{ raw_group_start_seq }},
                                            0
                                        ) > 0

                                        or

                                        coalesce(
                                            {{ raw_group_scope_start_seq }},
                                            0
                                        ) > 0
                                    )

                                {% else %}

                                    coalesce(
                                        {{ raw_group_start_seq }},
                                        0
                                    ) > 0

                                    {% if boundaries | length > 0 %}

                                    and
                                    (
                                        {{ raw_group_boundary_seq }} = 0
                                        or
                                        segment_sequence
                                            <
                                        {{ raw_group_boundary_seq }}
                                    )

                                    {% endif %}

                                {% endif %}

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

                                {% if parent_scopes | length > 0 %}

                                    {% for parent_scope in parent_scopes %}

                                        {{ parent_scope }}
                                        and

                                    {% endfor %}

                                {% endif %}


                                {% if has_scope_entry %}

                                    (
                                        {{ raw_group_terminal_boundary_seq }} is null
                                        or
                                        segment_sequence
                                            <
                                        {{ raw_group_terminal_boundary_seq }}
                                    )
                                    and

                                    (
                                        coalesce(
                                            {{ raw_group_start_seq }},
                                            0
                                        ) > 0

                                        or

                                        coalesce(
                                            {{ raw_group_scope_start_seq }},
                                            0
                                        ) > 0
                                    )

                                {% else %}

                                    coalesce(
                                        {{ raw_group_start_seq }},
                                        0
                                    ) > 0

                                    {% if boundaries | length > 0 %}

                                    and
                                    (
                                        {{ raw_group_boundary_seq }} = 0
                                        or
                                        segment_sequence
                                            <
                                        {{ raw_group_boundary_seq }}
                                    )

                                    {% endif %}

                                {% endif %}

                            then

                                case

                                    when coalesce(
                                        {{ raw_group_start_seq }},
                                        0
                                    ) > 0

                                        then coalesce(
                                            {{ raw_group_start_seq }},
                                            0
                                        )

                                    {% if has_scope_entry %}

                                    else coalesce(
                                        {{ raw_group_scope_start_seq }},
                                        0
                                    )

                                    {% endif %}

                                end

                            else 0

                        end as {{ current_group_start_seq }},


                        case

                            when

                                {% if parent_scopes | length > 0 %}

                                    {% for parent_scope in parent_scopes %}

                                        {{ parent_scope }}
                                        and

                                    {% endfor %}

                                {% endif %}


                                {% if has_scope_entry %}

                                    (
                                        {{ raw_group_terminal_boundary_seq }} is null
                                        or
                                        segment_sequence
                                            <
                                        {{ raw_group_terminal_boundary_seq }}
                                    )
                                    and

                                    (
                                        coalesce(
                                            {{ raw_group_start_seq }},
                                            0
                                        ) > 0

                                        or

                                        coalesce(
                                            {{ raw_group_scope_start_seq }},
                                            0
                                        ) > 0
                                    )

                                {% else %}

                                    coalesce(
                                        {{ raw_group_start_seq }},
                                        0
                                    ) > 0

                                    {% if boundaries | length > 0 %}

                                    and
                                    (
                                        {{ raw_group_boundary_seq }} = 0
                                        or
                                        segment_sequence
                                            <
                                        {{ raw_group_boundary_seq }}
                                    )

                                    {% endif %}

                                {% endif %}

                                then true

                            else false

                        end as {{ current_group_scope }}

                    from {{ anchor_cte }}

                )


                {% set ns.previous_cte =
                    group_cte
                %}


                {% set child_parent_seqs =
                    parent_seqs + [current_group_seq]
                %}

                {% set child_parent_scopes =
                    parent_scopes + [current_group_scope]
                %}


                {{ easyhl7.process_group_children(
                    child,
                    ns,
                    child_parent_seqs,
                    child_parent_scopes
                ) }}


            {% else %}

                {{ easyhl7.process_group_children(
                    child,
                    ns,
                    parent_seqs,
                    parent_scopes
                ) }}

            {% endif %}

        {% endif %}

    {% endfor %}

{% endmacro %}