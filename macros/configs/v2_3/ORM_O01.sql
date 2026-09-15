{% macro config_v2_3_ORM_O01() %}

    {% set config = {
        "name": "ORM_O01",
        "version": "2.3",
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
                        "type": "segment",
                        "name": "AL1",
                        "min": 0,
                        "max": none
                    },

                    {
                        "type": "segment",
                        "name": "PV1",
                        "min": 0,
                        "max": 1
                    },

                    {
                        "type": "segment",
                        "name": "PV2",
                        "min": 0,
                        "max": 1
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
                        "type": "group",
                        "name": "ORDER_DETAIL",
                        "min": 0,
                        "max": 1,
                        "children": [

                            {
                                "type": "group",
                                "name": "ORDER_DETAIL_SEGMENT",
                                "min": 1,
                                "max": 1,
                                "children": [

                                    {
                                        "type": "segment",
                                        "name": "OBR",
                                        "min": 0,
                                        "max": 1
                                    },

                                    {
                                        "type": "segment",
                                        "name": "RQD",
                                        "min": 0,
                                        "max": 1
                                    },

                                    {
                                        "type": "segment",
                                        "name": "RQ1",
                                        "min": 0,
                                        "max": 1
                                    },

                                    {
                                        "type": "segment",
                                        "name": "RXO",
                                        "min": 0,
                                        "max": 1
                                    },

                                    {
                                        "type": "segment",
                                        "name": "ODS",
                                        "min": 0,
                                        "max": 1
                                    },

                                    {
                                        "type": "segment",
                                        "name": "ODT",
                                        "min": 0,
                                        "max": 1
                                    }

                                ]
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
                                "min": 0,
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
                    },

                    {
                        "type": "segment",
                        "name": "BLG",
                        "min": 0,
                        "max": 1
                    }

                ]
            }

        ]
    } %}

    {{ return(config) }}

{% endmacro %}