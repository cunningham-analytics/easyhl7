{% macro parse_field_value(value_column) %}

    case

        when {{ value_column }} like '%^%'
        then (
            select jsonb_object_agg(
                component_number::text,
                case

                    when component_value like '%&%'
                    then (
                        select jsonb_object_agg(
                            subcomponent_number::text,
                            to_jsonb(subcomponent_value)
                            order by subcomponent_number
                        )
                        from unnest(
                            string_to_array(component_value, '&')
                        ) with ordinality as s(
                            subcomponent_value,
                            subcomponent_number
                        )
                    )

                    else to_jsonb(component_value)

                end
                order by component_number
            )

            from unnest(
                string_to_array({{ value_column }}, '^')
            ) with ordinality as c(
                component_value,
                component_number
            )
        )

        when {{ value_column }} like '%&%'
        then (
            select jsonb_object_agg(
                subcomponent_number::text,
                to_jsonb(subcomponent_value)
                order by subcomponent_number
            )
            from unnest(
                string_to_array({{ value_column }}, '&')
            ) with ordinality as s(
                subcomponent_value,
                subcomponent_number
            )
        )

        else to_jsonb({{ value_column }})

    end

{% endmacro %}