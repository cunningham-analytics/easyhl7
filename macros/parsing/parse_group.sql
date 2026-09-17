{% macro parse_group(args) %}

    {% set hierarchy_ref = args.get('hierarchy_ref') %}
    {% set version = args.get('version') %}
    {% set message_type = args.get('message_type') %}
    {% set group_name = args.get('group') %}
    {% set config = args.get('config') %}
    {% set config_override = args.get('config_override') %}

    {# Load config #}
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


    {# Find requested group #}
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


    {# Get anchored ancestors #}
    {% set ancestor_seqs =
        easyhl7.get_group_ancestors(
            message_config,
            group_name
        )
    %}

    {% if ancestor_seqs is none %}
        {% set ancestor_seqs = [] %}
    {% endif %}


    {# Anchored groups have their own sequence #}
    {% set has_anchor = group_config.get('anchor') %}

    {% if has_anchor %}
        {% set group_seq =
            group_name | lower ~ '_seq'
        %}
    {% endif %}


    {# Only segments directly owned by this group #}
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


        {% for segment in segment_children %}

            {% set segment_name = segment.get('name') %}
            {% set segment_max = segment.get('max') %}

            {#
                Only exclude descendant groups that can actually
                contain this same segment type.

                Example:

                ORDER.FT1
                    -> no descendant FT1
                    -> no descendant filter

                ORDER_DETAIL.NTE
                    -> OBSERVATION also contains NTE
                    -> observation_seq = 0
            #}

            {% set segment_descendant_seqs =
                easyhl7.get_segment_descendant_seqs(
                    group_config,
                    segment_name
                )
            %}


            {% if segment_max is none or segment_max > 1 %}

                ,
                jsonb_agg(
                    {{ easyhl7.parse_segment('segment') }}
                    order by segment_sequence
                ) filter (
                    where segment_type = '{{ segment_name }}'

                    {% for descendant_seq in segment_descendant_seqs %}
                        and {{ descendant_seq }} = 0
                    {% endfor %}
                ) as {{ segment_name | lower }}

            {% else %}

                ,
                max(
                    case
                        when segment_type = '{{ segment_name }}'

                        {% for descendant_seq in segment_descendant_seqs %}
                            and {{ descendant_seq }} = 0
                        {% endfor %}

                        then
                            {{ easyhl7.parse_segment('segment') }}::text
                    end
                )::jsonb as {{ segment_name | lower }}

            {% endif %}

        {% endfor %}


    from {{ ref(hierarchy_ref) }}


    {# Remove rows outside the requested group #}
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