{% macro get_segment_descendant_seqs(node, segment_name, active_seq=none) %}

    {% set ns = namespace(seqs=[]) %}

    {% for child in node.get('children', []) %}

        {% if child.get('type') == 'group' %}

            {% if child.get('anchor') %}
                {% set child_seq = child.get('name') | lower ~ '_seq' %}
            {% else %}
                {% set child_seq = active_seq %}
            {% endif %}

            {# Check segments directly owned by this descendant group #}
            {% for group_child in child.get('children', []) %}

                {% if
                    group_child.get('type') == 'segment'
                    and group_child.get('name') == segment_name
                    and child_seq
                %}

                    {% if child_seq not in ns.seqs %}
                        {% do ns.seqs.append(child_seq) %}
                    {% endif %}

                {% endif %}

            {% endfor %}

            {# Search deeper descendant groups #}
            {% set deeper_seqs =
                easyhl7.get_segment_descendant_seqs(
                    child,
                    segment_name,
                    child_seq
                )
            %}

            {% for seq in deeper_seqs %}

                {% if seq not in ns.seqs %}
                    {% do ns.seqs.append(seq) %}
                {% endif %}

            {% endfor %}

        {% endif %}

    {% endfor %}

    {{ return(ns.seqs) }}

{% endmacro %}