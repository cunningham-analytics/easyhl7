{% macro config_v2_1_ADT_A02() %}

    {% set config = {
        'name': 'ADT_A02',
        'children': [
            {'type': 'segment', 'name': 'MSH', 'min': 1, 'max': 1},
            {'type': 'segment', 'name': 'EVN', 'min': 1, 'max': 1},
            {'type': 'segment', 'name': 'PID', 'min': 1, 'max': 1},
            {'type': 'segment', 'name': 'PV1', 'min': 1, 'max': 1}
        ]
    } %}

    {{ return(config) }}

{% endmacro %}