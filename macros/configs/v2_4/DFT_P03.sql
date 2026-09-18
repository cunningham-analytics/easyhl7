{% macro config_v2_4_DFT_P03() %}

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
                'type': 'segment',
                'name': 'PD1',
                'min': 0,
                'max': 1
            },
            {
                'type': 'segment',
                'name': 'ROL',
                'min': 0,
                'max': none
            },
            {
                'type': 'segment',
                'name': 'PV1',
                'min': 0,
                'max': 1
            },
            {
                'type': 'segment',
                'name': 'PV2',
                'min': 0,
                'max': 1
            },
            {
                'type': 'segment',
                'name': 'ROL',
                'min': 0,
                'max': none
            },
            {
                'type': 'segment',
                'name': 'DB1',
                'min': 0,
                'max': none
            },
            {
                'type': 'group',
                'name': 'COMMON_ORDER',
                'anchor': ['ORC'],
                'scope_entry': ['OBR', 'OBX'],
                'min': 0,
                'max': none,
                'children': [
                    {
                        'type': 'segment',
                        'name': 'ORC',
                        'min': 0,
                        'max': 1
                    },
                    {
                        'type': 'group',
                        'name': 'ORDER',
                        'anchor': ['OBR'],
                        'min': 0,
                        'max': 1,
                        'children': [
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
                        'type': 'group',
                        'name': 'OBSERVATION',
                        'anchor': ['OBX'],
                        'min': 0,
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
            },
            {
                'type': 'group',
                'name': 'FINANCIAL',
                'anchor': ['FT1'],
                'min': 1,
                'max': none,
                'children': [
                    {
                        'type': 'segment',
                        'name': 'FT1',
                        'min': 1,
                        'max': 1
                    },
                    {
                        'type': 'group',
                        'name': 'FINANCIAL_PROCEDURE',
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
                    },
                    {
                        'type': 'group',
                        'name': 'FINANCIAL_COMMON_ORDER',
                        'anchor': ['ORC'],
                        'scope_entry': ['OBR', 'OBX'],
                        'min': 0,
                        'max': none,
                        'children': [
                            {
                                'type': 'segment',
                                'name': 'ORC',
                                'min': 0,
                                'max': 1
                            },
                            {
                                'type': 'group',
                                'name': 'FINANCIAL_ORDER',
                                'anchor': ['OBR'],
                                'min': 0,
                                'max': 1,
                                'children': [
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
                                'type': 'group',
                                'name': 'FINANCIAL_OBSERVATION',
                                'anchor': ['OBX'],
                                'min': 0,
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
                        'type': 'segment',
                        'name': 'GT1',
                        'min': 0,
                        'max': none
                    },
                    {
                        'type': 'group',
                        'name': 'INSURANCE',
                        'anchor': ['IN1'],
                        'min': 0,
                        'max': none,
                        'children': [
                            {
                                'type': 'segment',
                                'name': 'IN1',
                                'min': 1,
                                'max': 1
                            },
                            {
                                'type': 'segment',
                                'name': 'IN2',
                                'min': 0,
                                'max': 1
                            },
                            {
                                'type': 'segment',
                                'name': 'IN3',
                                'min': 0,
                                'max': none
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
            },
            {
                'type': 'segment',
                'name': 'DG1',
                'min': 0,
                'max': none
            }
        ]
    } %}

    {{ return(config) }}

{% endmacro %}