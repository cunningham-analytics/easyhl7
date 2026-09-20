{% macro config_v2_2_BAR_P01() %}

    {% set config = {
        'name': 'BAR_P01',
        'version': '2.2',
        'children': [
            {'type': 'segment', 'name': 'MSH', 'min': 1, 'max': 1},
            {'type': 'segment', 'name': 'EVN', 'min': 1, 'max': 1},
            {'type': 'segment', 'name': 'PID', 'min': 1, 'max': 1},
            {
                'type': 'group',
                'name': 'VISIT',
                'min': 1,
                'max': none,
                'anchor': ['PV1'],
                'children': [
                    {'type': 'segment', 'name': 'PV1', 'min': 0, 'max': 1},
                    {'type': 'segment', 'name': 'PV2', 'min': 0, 'max': 1},
                    {'type': 'segment', 'name': 'OBX', 'min': 0, 'max': none},
                    {'type': 'segment', 'name': 'AL1', 'min': 0, 'max': none},
                    {'type': 'segment', 'name': 'DG1', 'min': 0, 'max': none},
                    {'type': 'segment', 'name': 'PR1', 'min': 0, 'max': none},
                    {'type': 'segment', 'name': 'GT1', 'min': 0, 'max': none},
                    {'type': 'segment', 'name': 'NK1', 'min': 0, 'max': none},
                    {
                        'type': 'group',
                        'name': 'INSURANCE',
                        'min': 0,
                        'max': none,
                        'anchor': ['IN1'],
                        'children': [
                            {'type': 'segment', 'name': 'IN1', 'min': 1, 'max': 1},
                            {'type': 'segment', 'name': 'IN2', 'min': 0, 'max': 1},
                            {'type': 'segment', 'name': 'IN3', 'min': 0, 'max': none}
                        ]
                    },
                    {'type': 'segment', 'name': 'ACC', 'min': 0, 'max': 1},
                    {'type': 'segment', 'name': 'UB1', 'min': 0, 'max': 1},
                    {'type': 'segment', 'name': 'UB2', 'min': 0, 'max': 1}
                ]
            }
        ]
    } %}

    {{ return(config) }}

{% endmacro %}