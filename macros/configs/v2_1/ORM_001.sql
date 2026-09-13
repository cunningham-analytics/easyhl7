{% macro config_v2_1_ORM_O01() %}

    {% set config = {
        "name": "ORM_O01",
        "version": "2.1",
        "children": [

            {
                "type": "segment",
                "name": "MSH",
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
                        "type": "segment",
                        "name": "NTE",
                        "min": 0,
                        "max": none
                    },

                    {
                        "type": "group",
                        "name": "PATIENT_VISIT",
                        "min": 0,
                        "max": 1,
                        "anchor": "PV1",
                        "children": [

                            {
                                "type": "segment",
                                "name": "PV1",
                                "min": 1,
                                "max": 1
                            },

                            {
                                "type": "segment",
                                "name": "PV2",
                                "min": 0,
                                "max": 1
                            }

                        ]
                    }

                ]
            },

            {
                "type": "group",
                "name": "ORDER",
                "min": 1,
                "max": none,
                "anchor": "ORC",
                "children": [

                    {
                        "type": "segment",
                        "name": "ORC",
                        "min": 1,
                        "max": 1
                    },

                    {
                        "type": "segment",
                        "name": "OBR",
                        "min": 0,
                        "max": 1
                    },

                    {
                        "type": "segment",
                        "name": "NTE",
                        "min": 0,
                        "max": none
                    },

                    {
                        "type": "segment",
                        "name": "DG1",
                        "min": 0,
                        "max": none
                    }

                ]
            }

        ]
    } %}

    {{ return(config) }}

{% endmacro %}