{% macro parse_group(args) %}

    {% set hierarchy_ref = args.get('hierarchy_ref') %}
    {% set version = args.get('version') %}
    {% set message_type = args.get('message_type') %}
    {% set group_name = args.get('group') %}
    {% set config = args.get('config') %}
    {% set config_override = args.get('config_override') %}


    {# ---------------------------------------------------------
       Load message config
       --------------------------------------------------------- #}

    {% if config %}

        {% set message_config = config %}

    {% else %}

        {% set message_config =
            easyhl7.get_message_config(
                version,
                message_type
            )
        %}

        {% if config_override %}

            {% set message_config =
                easyhl7.merge_config_overrides(
                    message_config,
                    config_override
                )
            %}

        {% endif %}

    {% endif %}


    {# ---------------------------------------------------------
       Find requested group
       --------------------------------------------------------- #}

    {% set group_config =
        easyhl7.find_config_node(
            message_config,
            group_name
        )
    %}

    {% if group_config is none %}

        {{ exceptions.raise_compiler_error(
            "EasyHL7 group not found: "
            ~ group_name
        ) }}

    {% endif %}


    {# ---------------------------------------------------------
       Get anchored ancestors
       --------------------------------------------------------- #}

    {% set ancestor_seqs =
        easyhl7.get_group_ancestors(
            message_config,
            group_name
        )
    %}

    {% if ancestor_seqs is none %}
        {% set ancestor_seqs = [] %}
    {% endif %}


    {# ---------------------------------------------------------
       Determine this group's sequence
       --------------------------------------------------------- #}

    {% set has_anchor = group_config.get('anchor') %}

    {% if has_anchor %}

        {% set group_seq =
            group_name | lower ~ '_seq'
        %}

    {% endif %}


    {# ---------------------------------------------------------
       Get segments directly owned by this group
       --------------------------------------------------------- #}

    {% set segment_children = [] %}

    {% for child in group_config.get('children', []) %}

        {% if child.get('type') == 'segment' %}

            {% do segment_children.append(child) %}

        {% endif %}

    {% endfor %}


    select
        msg_control_id

        {% for ancestor_seq in ancestor_seqs %}
            , {{ ancestor_seq }}
        {% endfor %}

        {% if has_anchor %}
            , {{ group_seq }}
        {% endif %}


        {# -----------------------------------------------------
           Parse each directly owned segment
           ----------------------------------------------------- #}

        {% for segment in segment_children %}

            {% set segment_name = segment.get('name') %}
            {% set segment_max = segment.get('max') %}


            {# -------------------------------------------------
               Find every configured owner of this segment type
               ------------------------------------------------- #}

            {% set segment_owners =
                easyhl7.get_segment_owners(
                    message_config,
                    segment_name
                )
            %}


            {# -------------------------------------------------
               Find this group's depth for this segment
               ------------------------------------------------- #}

            {% set owner_ns = namespace(
                target_depth=none,
                competing_seqs=[]
            ) %}

            {% for owner in segment_owners %}

                {% if owner.get('group') == group_name %}

                    {% set owner_ns.target_depth =
                        owner.get('depth')
                    %}

                {% endif %}

            {% endfor %}


            {# -------------------------------------------------
               Any deeper valid owner can claim this segment.

               We only care about groups that are actually
               configured to own this SAME segment type.
               ------------------------------------------------- #}

            {% if owner_ns.target_depth is not none %}

                {% for owner in segment_owners %}

                    {% if
                        owner.get('depth') > owner_ns.target_depth
                        and owner.get('seq')
                        and owner.get('seq') not in owner_ns.competing_seqs
                    %}

                        {% do owner_ns.competing_seqs.append(
                            owner.get('seq')
                        ) %}

                    {% endif %}

                {% endfor %}

            {% endif %}


            {# -------------------------------------------------
               Repeating segment
               ------------------------------------------------- #}

            {% if segment_max is none or segment_max > 1 %}

                ,
                jsonb_agg(
                    {{ easyhl7.parse_segment('segment') }}
                    order by segment_sequence
                ) filter (

                    where segment_type = '{{ segment_name }}'

                    {% for competing_seq in owner_ns.competing_seqs %}

                        and {{ competing_seq }} = 0

                    {% endfor %}

                ) as {{ segment_name | lower }}


            {# -------------------------------------------------
               Non-repeating segment
               ------------------------------------------------- #}

            {% else %}

                ,
                max(
                    case

                        when segment_type = '{{ segment_name }}'

                        {% for competing_seq in owner_ns.competing_seqs %}

                            and {{ competing_seq }} = 0

                        {% endfor %}

                        then
                            {{ easyhl7.parse_segment('segment') }}::text

                    end
                )::jsonb as {{ segment_name | lower }}

            {% endif %}

        {% endfor %}


    from {{ ref(hierarchy_ref) }}


    {# ---------------------------------------------------------
       Restrict to instances of requested group
       --------------------------------------------------------- #}

    {% if has_anchor %}

        where {{ group_seq }} > 0

    {% elif ancestor_seqs | length > 0 %}

        where

            {% for ancestor_seq in ancestor_seqs %}

                {{ ancestor_seq }} > 0

                {% if not loop.last %}
                    and
                {% endif %}

            {% endfor %}

    {% endif %}


    group by
        msg_control_id

        {% for ancestor_seq in ancestor_seqs %}
            , {{ ancestor_seq }}
        {% endfor %}

        {% if has_anchor %}
            , {{ group_seq }}
        {% endif %}

{% endmacro %}