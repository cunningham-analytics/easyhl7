{% macro config_v2_4_BAR_P05() %}

    {% set config = {
        'name': 'BAR_P05',
        'children': [
            {'type': 'segment', 'name': 'MSH', 'min': 1, 'max': 1},
            {'type': 'segment', 'name': 'EVN', 'min': 1, 'max': 1},
            {'type': 'segment', 'name': 'PID', 'min': 1, 'max': 1},
            {'type': 'segment', 'name': 'PD1', 'min': 0, 'max': 1},
            {'type': 'segment', 'name': 'ROL', 'min': 0, 'max': none},
            {
                'type': 'group',
                'name': 'VISIT',
                'anchor': ['PV1'],
                'min': 1,
                'max': none,
                'children': [
                    {'type': 'segment', 'name': 'PV1', 'min': 1, 'max': 1},
                    {'type': 'segment', 'name': 'PV2', 'min': 0, 'max': 1},
                    {'type': 'segment', 'name': 'DB1', 'min': 0, 'max': none},
                    {'type': 'segment', 'name': 'OBX', 'min': 0, 'max': none},
                    {'type': 'segment', 'name': 'AL1', 'min': 0, 'max': none},
                    {'type': 'segment', 'name': 'DG1', 'min': 0, 'max': none},
                    {'type': 'segment', 'name': 'DRG', 'min': 0, 'max': 1},
                    {
                        'type': 'group',
                        'name': 'PROCEDURE',
                        'anchor': ['PR1'],
                        'min': 0,
                        'max': none,
                        'children': [
                            {'type': 'segment', 'name': 'PR1', 'min': 1, 'max': 1},
                            {'type': 'segment', 'name': 'ROL', 'min': 0, 'max': none}
                        ]
                    },
                    {'type': 'segment', 'name': 'GT1', 'min': 0, 'max': none},
                    {'type': 'segment', 'name': 'NK1', 'min': 0, 'max': none},
                    {
                        'type': 'group',
                        'name': 'INSURANCE',
                        'anchor': ['IN1'],
                        'min': 0,
                        'max': none,
                        'children': [
                            {'type': 'segment', 'name': 'IN1', 'min': 1, 'max': 1},
                            {'type': 'segment', 'name': 'IN2', 'min': 0, 'max': 1},
                            {'type': 'segment', 'name': 'IN3', 'min': 0, 'max': none},
                            {'type': 'segment', 'name': 'ROL', 'min': 0, 'max': none}
                        ]
                    },
                    {'type': 'segment', 'name': 'ACC', 'min': 0, 'max': 1},
                    {'type': 'segment', 'name': 'UB1', 'min': 0, 'max': 1},
                    {'type': 'segment', 'name': 'UB2', 'min': 0, 'max': 1},
                    {'type': 'segment', 'name': 'ABS', 'min': 0, 'max': 1},
                    {'type': 'segment', 'name': 'BLC', 'min': 0, 'max': none},
                    {'type': 'segment', 'name': 'RMI', 'min': 0, 'max': 1}
                ]
            }
        ]
    } %}

    {{ return(config) }}

{% endmacro %}