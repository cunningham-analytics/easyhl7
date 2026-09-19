{% macro config_v2_2_ADT_A03() %}

    {% set config = {
        'name': 'ADT_A03',
        'children': [
            {'type': 'segment', 'name': 'MSH', 'min': 1, 'max': 1},
            {'type': 'segment', 'name': 'EVN', 'min': 1, 'max': 1},
            {'type': 'segment', 'name': 'PID', 'min': 1, 'max': 1},
            {'type': 'segment', 'name': 'PV1', 'min': 1, 'max': 1},
            {'type': 'segment', 'name': 'PV2', 'min': 0, 'max': 1},
            {'type': 'segment', 'name': 'DG1', 'min': 0, 'max': none},
            {'type': 'segment', 'name': 'DRG', 'min': 0, 'max': 1},
            {'type': 'segment', 'name': 'PR1', 'min': 0, 'max': none},
            {'type': 'segment', 'name': 'OBX', 'min': 0, 'max': none}
        ]
    } %}

    {{ return(config) }}

{% endmacro %}