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

                {% set raw_group_scope_start_seq =
                    '__group_scope_start_seq_' ~ ns.counter
                %}

                {% set raw_group_boundary_seq =
                    '__group_boundary_seq_' ~ ns.counter
                %}

                {% set raw_group_terminal_boundary_seq =
                    '__group_terminal_boundary_seq_' ~ ns.counter
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


                {#
                    Determine structural boundaries.

                    Legacy groups retain the existing running boundary
                    behavior.

                    Groups with scope_entry additionally get a terminal
                    boundary. This is the first later sibling entry in
                    the current parent occurrence.

                    Once that terminal boundary has been crossed, a
                    scope_entry cannot reopen this group.

                    This is important for structures such as:

                        COMMON_ORDER*
                        FINANCIAL*

                    where OBR/OBX can establish COMMON_ORDER scope when
                    ORC is absent, but an OBR/OBX inside FINANCIAL must
                    not reopen the earlier root COMMON_ORDER.
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


                        {% if has_scope_entry %}

                            ,

                            {% if boundaries | length > 0 %}

                                min(
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

                                )

                            {% else %}

                                cast(null as bigint)

                            {% endif %}

                            as {{ raw_group_terminal_boundary_seq }}

                        {% endif %}

                    from {{ ns.previous_cte }}

                )



                ,
                {{ anchor_cte }} as (

                    select
                        *,

                        {#
                            Observable occurrence sequence.

                            Only anchor segments increment this counter.
                            scope_entry NEVER increments it.

                            Therefore an implicitly entered group can be
                            structurally active while its public *_seq
                            remains zero.
                        #}

                        sum(
                            case

                                when

                                    {% if parent_scopes | length > 0 %}

                                        {% for parent_scope in parent_scopes %}

                                            {{ parent_scope }}
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


                        {#
                            Observable group start.

                            This retains the existing preamble + anchor
                            behavior.

                            scope_entry is deliberately NOT included
                            here because it does not establish an
                            observable occurrence.
                        #}

                        max(
                            case

                                when

                                    {% if parent_scopes | length > 0 %}

                                        {% for parent_scope in parent_scopes %}

                                            {{ parent_scope }}
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

                            {#
                                Structural scope start.

                                This is the first scope_entry encountered
                                in the current parent occurrence before
                                the group's terminal sibling boundary.

                                It proves that we are structurally inside
                                the group, but it does not establish an
                                occurrence number.
                            #}

                            min(
                                case

                                    when

                                        {% if parent_scopes | length > 0 %}

                                            {% for parent_scope in parent_scopes %}

                                                {{ parent_scope }}
                                                and

                                            {% endfor %}

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


                {#
                    Final group membership.

                    There are now two related concepts:

                    1. occurrence identity
                       -> public *_seq
                       -> established only by anchor

                    2. structural scope
                       -> internal *_scope_active
                       -> may be established by anchor/preamble OR
                          scope_entry

                    Existing groups without scope_entry retain the
                    previous behavior.

                    For an implicitly entered group:

                        *_seq = 0
                        *_scope_active = true

                    This allows independently observable descendant
                    groups to parse without inventing an ambiguous
                    parent occurrence number.
                #}

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
                                    )
                                    >
                                    {{ raw_group_boundary_seq }}

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
                                    )
                                    >
                                    {{ raw_group_boundary_seq }}

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
                                    )
                                    >
                                    {{ raw_group_boundary_seq }}

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

                {#
                    Structural/unanchored groups do not create
                    occurrence or scope columns of their own.

                    Their children inherit the currently active
                    anchored ancestor scopes.
                #}

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