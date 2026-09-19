{% macro config_v2_6_RAS_O17() %}

    {% set config = {
        'name': 'RAS_O17',
        'children': [

            {'type': 'segment', 'name': 'MSH', 'min': 1, 'max': 1},
            {'type': 'segment', 'name': 'SFT', 'min': 0, 'max': none},
            {'type': 'segment', 'name': 'UAC', 'min': 0, 'max': 1},
            {'type': 'segment', 'name': 'NTE', 'min': 0, 'max': none},

            {
                'type': 'group',
                'name': 'PATIENT',
                'anchor': ['PID'],
                'min': 0,
                'max': 1,
                'children': [
                    {'type': 'segment', 'name': 'PID', 'min': 1, 'max': 1},
                    {'type': 'segment', 'name': 'PD1', 'min': 0, 'max': 1},
                    {'type': 'segment', 'name': 'NTE', 'min': 0, 'max': none},
                    {'type': 'segment', 'name': 'AL1', 'min': 0, 'max': none},

                    {
                        'type': 'group',
                        'name': 'PATIENT_VISIT',
                        'anchor': ['PV1'],
                        'min': 0,
                        'max': 1,
                        'children': [
                            {'type': 'segment', 'name': 'PV1', 'min': 1, 'max': 1},
                            {'type': 'segment', 'name': 'PV2', 'min': 0, 'max': 1}
                        ]
                    }
                ]
            },

            {
                'type': 'group',
                'name': 'ORDER',
                'anchor': ['ORC'],
                'min': 1,
                'max': none,
                'children': [

                    {'type': 'segment', 'name': 'ORC', 'min': 1, 'max': 1},

                    {
                        'type': 'group',
                        'name': 'TIMING',
                        'anchor': ['TQ1'],
                        'min': 0,
                        'max': none,
                        'children': [
                            {'type': 'segment', 'name': 'TQ1', 'min': 1, 'max': 1},
                            {'type': 'segment', 'name': 'TQ2', 'min': 0, 'max': none}
                        ]
                    },

                    {
                        'type': 'group',
                        'name': 'ORDER_DETAIL',
                        'anchor': ['RXO'],
                        'min': 0,
                        'max': 1,
                        'children': [
                            {'type': 'segment', 'name': 'RXO', 'min': 1, 'max': 1},

                            {
                                'type': 'group',
                                'name': 'ORDER_DETAIL_SUPPLEMENT',
                                'min': 0,
                                'max': 1,
                                'children': [
                                    {'type': 'segment', 'name': 'NTE', 'min': 1, 'max': none},
                                    {'type': 'segment', 'name': 'RXR', 'min': 1, 'max': none},

                                    {
                                        'type': 'group',
                                        'name': 'COMPONENTS',
                                        'anchor': ['RXC'],
                                        'min': 0,
                                        'max': none,
                                        'children': [
                                            {'type': 'segment', 'name': 'RXC', 'min': 1, 'max': 1},
                                            {'type': 'segment', 'name': 'NTE', 'min': 0, 'max': none}
                                        ]
                                    }
                                ]
                            }
                        ]
                    },

                    {
                        'type': 'group',
                        'name': 'ENCODING',
                        'anchor': ['RXE'],
                        'min': 0,
                        'max': 1,
                        'children': [
                            {'type': 'segment', 'name': 'RXE', 'min': 1, 'max': 1},

                            {
                                'type': 'group',
                                'name': 'TIMING_ENCODED',
                                'anchor': ['TQ1'],
                                'min': 1,
                                'max': none,
                                'children': [
                                    {'type': 'segment', 'name': 'TQ1', 'min': 1, 'max': 1},
                                    {'type': 'segment', 'name': 'TQ2', 'min': 0, 'max': none}
                                ]
                            },

                            {'type': 'segment', 'name': 'RXR', 'min': 1, 'max': none},
                            {'type': 'segment', 'name': 'RXC', 'min': 0, 'max': none}
                        ]
                    },

                    {
                        'type': 'group',
                        'name': 'ADMINISTRATION',
                        'anchor': ['RXA'],
                        'min': 1,
                        'max': none,
                        'children': [
                            {'type': 'segment', 'name': 'RXA', 'min': 1, 'max': none},
                            {'type': 'segment', 'name': 'RXR', 'min': 1, 'max': 1},

                            {
                                'type': 'group',
                                'name': 'OBSERVATION',
                                'anchor': ['OBX'],
                                'min': 0,
                                'max': none,
                                'children': [
                                    {'type': 'segment', 'name': 'OBX', 'min': 1, 'max': 1},
                                    {'type': 'segment', 'name': 'NTE', 'min': 0, 'max': none}
                                ]
                            }
                        ]
                    },

                    {'type': 'segment', 'name': 'CTI', 'min': 0, 'max': none}
                ]
            }
        ]
    } %}

    {{ return(config) }}

{% endmacro %}
