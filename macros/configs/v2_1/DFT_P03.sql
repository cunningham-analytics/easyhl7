{% macro config_v2_1_DFT_P03() %}

    {% set config = {
        'name': 'DFT_P03',
        'children': [
            {
                'type': 'segment',
                'name': 'MSH',
                'min': 1,
                'max': 1
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
                'type': 'group',
                'name': 'PATIENT_VISIT',
                'anchor': ['PV1'],
                'min': 0,
                'max': 1,
                'children': [
                    {
                        'type': 'segment',
                        'name': 'PV1',
                        'min': 1,
                        'max': 1
                    }
                ]
            },
            {
                'type': 'group',
                'name': 'FINANCIAL',
                'anchor': ['FT1'],
                'min': 0,
                'max': none,
                'children': [
                    {
                        'type': 'segment',
                        'name': 'FT1',
                        'min': 1,
                        'max': 1
                    }
                ]
            }
        ]
    } %}

    {{ return(config) }}

{% endmacro %}