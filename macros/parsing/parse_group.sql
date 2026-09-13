{% macro parse_group(args) %}

    {% set hierarchy_ref = args.get('hierarchy_ref') %}
    {% set version = args.get('version') %}
    {% set message_type = args.get('message_type') %}
    {% set group_name = args.get('group') %}

    {% set message_config = easyhl7.get_message_config(
        version,
        message_type
    ) %}

    {% set group_config = easyhl7.find_config_node(
        message_config,
        group_name
    ) %}

    {% if group_config is none %}
        {{ exceptions.raise_compiler_error(
            "EasyHL7: group '" ~ group_name ~ "' not found in config"
        ) }}
    {% endif %}

    {% set group_seq = group_name | lower ~ '_seq' %}

    {% set ancestor_seqs = easyhl7.get_group_ancestors(
        message_config,
        group_name
        )
    %}

    {% set ns = namespace(segments=[]) %}

    {# Only direct segment children — do NOT recurse into child groups #}
    {% for child in group_config.get('children', []) %}

        {% if child.get('type') == 'segment' %}

            {% do ns.segments.append(child) %}

        {% endif %}

    {% endfor %}


    with source as (

        select *
        from {{ ref(hierarchy_ref) }}
        where {{ group_seq }} > 0

    ),

    final as (

        select

            msg_control_id,

            {% for ancestor_seq in ancestor_seqs %}
                {{ ancestor_seq }},
            {% endfor %}

            {{ group_seq }},

            {% for segment_config in ns.segments %}

                {% set segment_name = segment_config.get('name') %}
                {% set segment_max = segment_config.get('max') %}

                {% if segment_max is none or segment_max > 1 %}

                    jsonb_agg(
                        {{ easyhl7.parse_segment('segment') }}
                        order by segment_sequence
                    ) filter (
                        where segment_type = '{{ segment_name }}'
                    ) as {{ segment_name | lower }}

                {% else %}

                    max(
                        case
                            when segment_type = '{{ segment_name }}'
                                then {{ easyhl7.parse_segment('segment') }}::text
                        end
                    )::jsonb as {{ segment_name | lower }}

                {% endif %}

                {% if not loop.last %},{% endif %}

            {% endfor %}

        from source

        group by
            msg_control_id

            {% for ancestor_seq in ancestor_seqs %}
                , {{ ancestor_seq }}
            {% endfor %}

            , {{ group_seq }}

    )

    select *
    from final

{% endmacro %}