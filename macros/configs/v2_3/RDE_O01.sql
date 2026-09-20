{% macro config_v2_3_RDE_O01() %}

    {% set config = {
        "name": "RDE_O01",
        "version": "2.3",
        "children": [
            {"type":"segment","name":"MSH","min":1,"max":1},
            {"type":"segment","name":"NTE","min":0,"max":none},

            {
                "type":"group","name":"PATIENT","min":0,"max":1,"anchor":"PID",
                "children":[
                    {"type":"segment","name":"PID","min":1,"max":1},
                    {"type":"segment","name":"PD1","min":0,"max":1},
                    {"type":"segment","name":"NTE","min":0,"max":none},

                    {
                        "type":"group","name":"PATIENT_VISIT","min":0,"max":1,"anchor":"PV1",
                        "children":[
                            {"type":"segment","name":"PV1","min":1,"max":1},
                            {"type":"segment","name":"PV2","min":0,"max":1}
                        ]
                    },

                    {
                        "type":"group","name":"INSURANCE","min":0,"max":none,"anchor":"IN1",
                        "children":[
                            {"type":"segment","name":"IN1","min":1,"max":1},
                            {"type":"segment","name":"IN2","min":0,"max":1},
                            {"type":"segment","name":"IN3","min":0,"max":1}
                        ]
                    },

                    {"type":"segment","name":"GT1","min":0,"max":1},
                    {"type":"segment","name":"AL1","min":0,"max":none}
                ]
            },

            {
                "type":"group","name":"ORDER","min":1,"max":none,"anchor":"ORC",
                "children":[
                    {"type":"segment","name":"ORC","min":1,"max":1},

                    {
                        "type":"group","name":"ORDER_DETAIL","min":0,"max":1,"anchor":"RXO",
                        "children":[
                            {"type":"segment","name":"RXO","min":1,"max":1},
                            {"type":"segment","name":"NTE","min":0,"max":none},
                            {"type":"segment","name":"RXR","min":1,"max":none},

                            {
                                "type":"group","name":"COMPONENT","min":0,"max":1,"anchor":"RXC",
                                "children":[
                                    {"type":"segment","name":"RXC","min":1,"max":none},
                                    {"type":"segment","name":"NTE","min":0,"max":none}
                                ]
                            }
                        ]
                    },

                    {"type":"segment","name":"RXE","min":1,"max":1},
                    {"type":"segment","name":"RXR","min":1,"max":none},
                    {"type":"segment","name":"RXC","min":0,"max":none},

                    {
                        "type":"group","name":"OBSERVATION","min":0,"max":none,
                        "anchor":"OBX",
                        "scope_entry":["NTE"],
                        "children":[
                            {"type":"segment","name":"OBX","min":0,"max":1},
                            {"type":"segment","name":"NTE","min":0,"max":none}
                        ]
                    },

                    {"type":"segment","name":"CTI","min":0,"max":1}
                ]
            }
        ]
    } %}

    {{ return(config) }}

{% endmacro %}