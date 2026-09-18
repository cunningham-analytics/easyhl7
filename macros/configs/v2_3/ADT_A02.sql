{% macro config_v2_3_ADT_A02() %}

    {% set config = {
        'name': 'ADT_A02',
        'children': [
            {'type': 'segment', 'name': 'MSH', 'min': 1, 'max': 1},
            {'type': 'segment', 'name': 'EVN', 'min': 1, 'max': 1},
            {'type': 'segment', 'name': 'PID', 'min': 1, 'max': 1},
            {'type': 'segment', 'name': 'PD1', 'min': 0, 'max': 1},
            {'type': 'segment', 'name': 'PV1', 'min': 1, 'max': 1},
            {'type': 'segment', 'name': 'PV2', 'min': 0, 'max': 1},
            {'type': 'segment', 'name': 'DB1', 'min': 0, 'max': none},
            {'type': 'segment', 'name': 'OBX', 'min': 0, 'max': none}
        ]
    } %}

    {{ return(config) }}

{% endmacro %}