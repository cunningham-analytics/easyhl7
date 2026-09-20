{% macro config_v2_5_BAR_P02() %}

    {% set config = {
        'name': 'BAR_P02',
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
                'type': 'group',
                'name': 'PATIENT',
                'anchor': ['PID'],
                'min': 1,
                'max': none,
                'children': [
                    {
                        'type': 'segment',
                        'name': 'PID',
                        'min': 1,
                        'max': 1
                    },
                    {
                        'type': 'segment',
                        'name': 'PD1',
                        'min': 0,
                        'max': 1
                    },
                    {
                        'type': 'segment',
                        'name': 'PV1',
                        'min': 0,
                        'max': 1
                    },
                    {
                        'type': 'segment',
                        'name': 'DB1',
                        'min': 0,
                        'max': none
                    }
                ]
            }
        ]
    } %}

    {{ return(config) }}

{% endmacro %}