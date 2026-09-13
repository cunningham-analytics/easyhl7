{% macro config_v2_1_ORU_R01() %}

    {% set config = {
        "name": "ORU_R01",
        "version": "2.1",

        "children": [
            {
                "type": "segment",
                "name": "MSH",
                "min": 1,
                "max": 1
            },
            {
                "type": "group",
                "name": "PATIENT_RESULT",
                "min": 1,
                "max": none,
                "children": [
                    {
                        "type": "group",
                        "name": "PATIENT",
                        "min": 0,
                        "max": 1,
                        "anchor": "PID",
                        "children": [
                            {
                                "type": "segment",
                                "name": "PID",
                                "min": 1,
                                "max": 1
                            },
                            {
                                "type": "group",
                                "name": "VISIT",
                                "min": 0,
                                "max": 1,
                                "anchor": "PV1",
                                "children": [
                                    {
                                        "type": "segment",
                                        "name": "PV1",
                                        "min": 1,
                                        "max": 1
                                    }
                                ]
                            }
                        ]
                    },
                    {
                        "type": "group",
                        "name": "ORDER_OBSERVATION",
                        "min": 1,
                        "max": none,
                        "anchor": "OBR",
                        "preamble": ["ORC"],
                        "children": [
                            {
                                "type": "segment",
                                "name": "ORC",
                                "min": 0,
                                "max": 1
                            },
                            {
                                "type": "segment",
                                "name": "OBR",
                                "min": 1,
                                "max": 1
                            },
                            {
                                "type": "segment",
                                "name": "NTE",
                                "min": 0,
                                "max": none
                            },
                            {
                                "type": "group",
                                "name": "OBSERVATION",
                                "min": 1,
                                "max": none,
                                "anchor": "OBX",
                                "children": [
                                    {
                                        "type": "segment",
                                        "name": "OBX",
                                        "min": 1,
                                        "max": 1
                                    },
                                    {
                                        "type": "segment",
                                        "name": "NTE",
                                        "min": 0,
                                        "max": none
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }
        ]
    } %}

    {{ return(config) }}

{% endmacro %}