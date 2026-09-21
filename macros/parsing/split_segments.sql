{% macro split_segments(args) %}

    {% set message_ref = args.get('message_ref') %}
    {% set message_column = args.get('message_column') %}
    {% set passthrough_fields = args.get('passthrough_fields', []) %}

    with messages as (

        select
            {{ message_column }} as msg

            {% for field in passthrough_fields %}
                , {{ field }}
            {% endfor %}

            ,
            split_part(
                split_part(
                    replace({{ message_column }}, chr(13), chr(10)),
                    chr(10),
                    1
                ),
                '|',
                10
            ) as msg_control_id

        from {{ ref(message_ref) }}

    ),

    segments as (

        select
            msg,
            msg_control_id

            {% for field in passthrough_fields %}
                , {{ field }}
            {% endfor %}

            ,
            trim(segment) as segment,
            ordinal as segment_sequence

        from messages

        cross join lateral unnest(
            string_to_array(
                replace(msg, chr(13), chr(10)),
                chr(10)
            )
        ) with ordinality as s(segment, ordinal)

    ),

    final as (

        select
            msg_control_id

            {% for field in passthrough_fields %}
                , {{ field }}
            {% endfor %}

            ,
            segment_sequence,
            split_part(segment, '|', 1) as segment_type,
            segment,
            msg

        from segments

        where trim(segment) <> ''

    )

    select *
    from final

{% endmacro %}