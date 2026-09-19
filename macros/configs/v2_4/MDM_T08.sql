{% macro config_v2_4_MDM_T08() %}

    {% set config = {
        'name': 'MDM_T08',
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
                'type': 'segment',
                'name': 'PV1',
                'min': 1,
                'max': 1
            },
            {
                'type': 'segment',
                'name': 'TXA',
                'min': 1,
                'max': 1
            },
            {
                'type': 'segment',
                'name': 'OBX',
                'min': 1,
                'max': none
            }
        ]
    } %}

    {{ return(config) }}

{% endmacro %}
