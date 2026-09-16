{% macro config_v2_6_ORU_R01() %}

    {% set config = {
        "name": "ORU_R01",
        "version": "2.6",
        "children": [
            {"type":"segment","name":"MSH","min":1,"max":1},
            {"type":"segment","name":"SFT","min":0,"max":none},
            {"type":"segment","name":"UAC","min":0,"max":1},

            {
                "type":"group","name":"PATIENT_RESULT","min":1,"max":none,
                "children":[
                    {
                        "type":"group","name":"PATIENT","min":0,"max":1,"anchor":"PID",
                        "children":[
                            {"type":"segment","name":"PID","min":1,"max":1},
                            {"type":"segment","name":"PD1","min":0,"max":1},
                            {"type":"segment","name":"NTE","min":0,"max":none},
                            {"type":"segment","name":"NK1","min":0,"max":none},
                            {"type":"segment","name":"OBX","min":0,"max":none},
                            {
                                "type":"group","name":"VISIT","min":0,"max":1,"anchor":"PV1",
                                "children":[
                                    {"type":"segment","name":"PV1","min":1,"max":1},
                                    {"type":"segment","name":"PV2","min":0,"max":1}
                                ]
                            }
                        ]
                    },

                    {
                        "type":"group","name":"ORDER_OBSERVATION","min":1,"max":none,
                        "anchor":"OBR",
                        "preamble":["ORC"],
                        "children":[
                            {"type":"segment","name":"ORC","min":0,"max":1},
                            {"type":"segment","name":"OBR","min":1,"max":1},
                            {"type":"segment","name":"NTE","min":0,"max":none},
                            {"type":"segment","name":"ROL","min":0,"max":none},

                            {
                                "type":"group","name":"TIMING_QTY","min":0,"max":none,"anchor":"TQ1",
                                "children":[
                                    {"type":"segment","name":"TQ1","min":1,"max":1},
                                    {"type":"segment","name":"TQ2","min":0,"max":none}
                                ]
                            },

                            {"type":"segment","name":"CTD","min":0,"max":1},

                            {
                                "type":"group","name":"OBSERVATION","min":0,"max":none,"anchor":"OBX",
                                "children":[
                                    {"type":"segment","name":"OBX","min":1,"max":1},
                                    {"type":"segment","name":"NTE","min":0,"max":none}
                                ]
                            },

                            {"type":"segment","name":"FT1","min":0,"max":none},
                            {"type":"segment","name":"CTI","min":0,"max":none},

                            {
                                "type":"group","name":"SPECIMEN","min":0,"max":none,"anchor":"SPM",
                                "children":[
                                    {"type":"segment","name":"SPM","min":1,"max":1},
                                    {"type":"segment","name":"OBX","min":0,"max":none}
                                ]
                            }
                        ]
                    }
                ]
            },

            {"type":"segment","name":"DSC","min":0,"max":1}
        ]
    } %}

    {{ return(config) }}

{% endmacro %}