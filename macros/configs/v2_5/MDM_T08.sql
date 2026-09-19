{% macro config_v2_5_MDM_T08() %}

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
                'type': 'group',
                'name': 'COMMON_ORDER',
                'anchor': [
                    'ORC'
                ],
                'min': 0,
                'max': none,
                'children': [
                    {
                        'type': 'segment',
                        'name': 'ORC',
                        'min': 1,
                        'max': 1
                    },
                    {
                        'type': 'group',
                        'name': 'TIMING',
                        'anchor': [
                            'TQ1'
                        ],
                        'min': 0,
                        'max': none,
                        'children': [
                            {
                                'type': 'segment',
                                'name': 'TQ1',
                                'min': 1,
                                'max': 1
                            },
                            {
                                'type': 'segment',
                                'name': 'TQ2',
                                'min': 0,
                                'max': none
                            }
                        ]
                    },
                    {
                        'type': 'segment',
                        'name': 'OBR',
                        'min': 1,
                        'max': 1
                    },
                    {
                        'type': 'segment',
                        'name': 'NTE',
                        'min': 0,
                        'max': none
                    }
                ]
            },
            {
                'type': 'segment',
                'name': 'TXA',
                'min': 1,
                'max': 1
            },
            {
                'type': 'group',
                'name': 'OBSERVATION',
                'anchor': [
                    'OBX'
                ],
                'min': 1,
                'max': none,
                'children': [
                    {
                        'type': 'segment',
                        'name': 'OBX',
                        'min': 1,
                        'max': 1
                    },
                    {
                        'type': 'segment',
                        'name': 'NTE',
                        'min': 0,
                        'max': none
                    }
                ]
            }
        ]
    } %}

    {{ return(config) }}

{% endmacro %}
