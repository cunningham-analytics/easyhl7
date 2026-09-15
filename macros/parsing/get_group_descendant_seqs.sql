{% macro get_group_descendant_seqs(node) %}

    {% set ns = namespace(seqs=[]) %}

    {% for child in node.get('children', []) %}

        {% if child.get('type') == 'group' %}

            {% if child.get('anchor') %}

                {% set child_seq =
                    child.get('name') | lower ~ '_seq'
                %}

                {% do ns.seqs.append(child_seq) %}

            {% endif %}

            {% set child_seqs =
                easyhl7.get_group_descendant_seqs(child)
            %}

            {% for child_seq in child_seqs %}
                {% do ns.seqs.append(child_seq) %}
            {% endfor %}

        {% endif %}

    {% endfor %}

    {{ return(ns.seqs) }}

{% endmacro %}