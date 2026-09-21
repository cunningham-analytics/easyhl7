{% macro parse_group(args) %}

    {% set hierarchy_ref = args.get('hierarchy_ref') %}
    {% set version = args.get('version') %}
    {% set message_type = args.get('message_type') %}
    {% set group_name = args.get('group') %}
    {% set config = args.get('config') %}
    {% set config_override = args.get('config_override') %}
    {% set passthrough_fields = args.get('passthrough_fields', []) %}


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


    {% set ancestor_seqs =
        easyhl7.get_group_ancestors(
            message_config,
            group_name
        )
    %}


    {% if ancestor_seqs is none %}
        {% set ancestor_seqs = [] %}
    {% endif %}


    {% set group_seq =
        group_name | lower ~ '_seq'
    %}


    {% set segment_children = [] %}


    {% for child in group_config.get('children', []) %}

        {% if child.get('type') == 'segment' %}

            {% do segment_children.append(child) %}

        {% endif %}

    {% endfor %}


    select
        msg_control_id


        {% for field in passthrough_fields %}

            , max({{ field }}) as {{ field }}

        {% endfor %}


        {% for ancestor_seq in ancestor_seqs %}

            , {{ ancestor_seq }}

        {% endfor %}


        , {{ group_seq }}


        {% for segment in segment_children %}

            {% set segment_name =
                segment.get('name')
            %}

            {% set segment_max =
                segment.get('max')
            %}


            {% set segment_owners =
                easyhl7.get_segment_owners(
                    message_config,
                    segment_name
                )
            %}


            {% set owner_ns = namespace(
                target_start_seq=none,
                competing_start_seqs=[]
            ) %}


            {#
                Find the anchor-position column belonging to
                the group currently being parsed.
            #}

            {% for owner in segment_owners %}

                {% if owner.get('group') == group_name %}

                    {% set owner_ns.target_start_seq =
                        owner.get('start_seq')
                    %}

                {% endif %}

            {% endfor %}


            {#
                Every other configured owner of this segment
                competes for ownership.

                The owner whose anchor occurred most recently
                wins the row.
            #}

            {% for owner in segment_owners %}

                {% if
                    owner.get('group') != group_name
                    and owner.get('start_seq')
                    and owner.get('start_seq')
                        not in owner_ns.competing_start_seqs
                %}

                    {% do owner_ns.competing_start_seqs.append(
                        owner.get('start_seq')
                    ) %}

                {% endif %}

            {% endfor %}


            {% if segment_max is none or segment_max > 1 %}

                ,
                jsonb_agg(
                    {{ easyhl7.parse_segment('segment') }}
                    order by segment_sequence
                ) filter (

                    where segment_type = '{{ segment_name }}'

                    {% if owner_ns.target_start_seq %}

                        {% for competing_start_seq
                            in owner_ns.competing_start_seqs %}

                            and coalesce(
                                {{ owner_ns.target_start_seq }},
                                0
                            ) >= coalesce(
                                {{ competing_start_seq }},
                                0
                            )

                        {% endfor %}

                    {% endif %}

                ) as {{ segment_name | lower }}


            {% else %}

                ,
                max(
                    case

                        when segment_type = '{{ segment_name }}'

                        {% if owner_ns.target_start_seq %}

                            {% for competing_start_seq
                                in owner_ns.competing_start_seqs %}

                                and coalesce(
                                    {{ owner_ns.target_start_seq }},
                                    0
                                ) >= coalesce(
                                    {{ competing_start_seq }},
                                    0
                                )

                            {% endfor %}

                        {% endif %}

                        then
                            {{ easyhl7.parse_segment(
                                'segment'
                            ) }}::text

                    end
                )::jsonb as {{ segment_name | lower }}

            {% endif %}

        {% endfor %}


    from {{ ref(hierarchy_ref) }}


    where {{ group_seq }} > 0


    group by
        msg_control_id


        {% for ancestor_seq in ancestor_seqs %}

            , {{ ancestor_seq }}

        {% endfor %}


        , {{ group_seq }}

{% endmacro %}