{% macro parse_segment(segment_column) %}

    (
        select jsonb_object_agg(
            field_number::text,
            case

                when field_value like '%~%'
                then (
                    select jsonb_agg(
                        {{ easyhl7.parse_field_value('repetition_value') }}
                        order by repetition_number
                    )
                    from unnest(
                        string_to_array(field_value, '~')
                    ) with ordinality as r(
                        repetition_value,
                        repetition_number
                    )
                )

                else {{ easyhl7.parse_field_value('field_value') }}

            end
            order by field_number
        )

        from unnest(
            string_to_array({{ segment_column }}, '|')
        ) with ordinality as f(
            field_value,
            field_number
        )

        where field_number > 1
    )

{% endmacro %}