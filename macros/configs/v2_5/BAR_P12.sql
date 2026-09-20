{% macro config_v2_5_BAR_P12() %}

    {% set config = {
        'name': 'BAR_P12',
        'children': [
            {
                'type': 'segment',
                'name': 'MSH',
                'min': 1,
                'max': 1
            },
            {
                'type': 'segment',
                'name': 'SFT',
                'min': 0,
                'max': none
            },
            {
                'type': 'segment',
                'name': 'EVN',
                'min': 1,
                'max': 1
            },
            {
                'type': 'segment',
                'name': 'PID',
                'min': 1,
                'max': 1
            },
            {
                'type': 'segment',
                'name': 'PV1',
                'min': 1,
                'max': 1
            },
            {
                'type': 'segment',
                'name': 'DG1',
                'min': 0,
                'max': none
            },
            {
                'type': 'segment',
                'name': 'DRG',
                'min': 0,
                'max': 1
            },
            {
                'type': 'group',
                'name': 'PROCEDURE',
                'anchor': ['PR1'],
                'min': 0,
                'max': none,
                'children': [
                    {
                        'type': 'segment',
                        'name': 'PR1',
                        'min': 1,
                        'max': 1
                    },
                    {
                        'type': 'segment',
                        'name': 'ROL',
                        'min': 0,
                        'max': none
                    }
                ]
            }
        ]
    } %}

    {{ return(config) }}

{% endmacro %}