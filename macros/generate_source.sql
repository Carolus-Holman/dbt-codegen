{% macro get_tables_in_schema(schema_name,database_name=target.database) %}

    {% set tables=dbt_utils.get_tables_by_prefix(
            schema=schema_name,
            prefix='',
            database=database_name
        )
    %}

    {% set table_list= tables | map(attribute = 'identifier') %}

    {{ return(table_list | sort) }}
    {{ log("*** table list ***", info=True) }}
    {{ log(table_list, info=True) }}

{% endmacro %}


---
{% macro generate_source(schema_name, database_name=target.database, generate_columns=False) %}

{% set sources_yaml=[] %}

{% do sources_yaml.append('version: 2') %}
{% do sources_yaml.append('') %}
{% do sources_yaml.append('sources:') %}
{% do sources_yaml.append('  - name: ' ~ schema_name | lower) %}
{% do sources_yaml.append('    description: "todo"') %}
{% do sources_yaml.append('') %}
{% do sources_yaml.append('    quoting:') %}
{% do sources_yaml.append('      database: false') %}
{% do sources_yaml.append('      schema: false') %}
{% do sources_yaml.append('      identifier: false') %}

{% if database_name != target.database %}
{% do sources_yaml.append('    database: ' ~ database_name | lower) %}
{% do sources_yaml.append('    schema: ' ~ schema_name | lower) %}
{% endif %}

{% do sources_yaml.append('    tables:') %}

{% set tables=codegen.get_tables_in_schema(schema_name, database_name) %}

{% for table in tables %}
    {% do sources_yaml.append('      - name: ' ~ table | lower ) %}
    {% do sources_yaml.append('        description: "todo add description for ' ~ table | lower  ~ '"' )%}
    {% do sources_yaml.append('        identifier: ' ~ table | lower ) %}

    {% if generate_columns %}
    {% do sources_yaml.append('        columns:') %}

        {% set table_relation=api.Relation.create(
            database=database_name,
            schema=schema_name,
            identifier=table
        ) %}

        {% set columns=adapter.get_columns_in_relation(table_relation) %}

        {% for column in columns %}
            {% do sources_yaml.append('          - name: ' ~ column.name | lower ) %}
            {% do sources_yaml.append('            description: todo add description for ' ~ column.name | lower ) %}
        {% endfor %}
            {% do sources_yaml.append('') %}

    {% endif %}

{% endfor %}

{% if execute %}

    {% set joined = sources_yaml | join ('\n') %}
    {{ log(joined, info=True) }}
    {% do return(joined) %}

{% endif %}

{% endmacro %}
