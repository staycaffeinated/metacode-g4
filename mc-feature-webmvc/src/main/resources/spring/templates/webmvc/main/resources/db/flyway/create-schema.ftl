
/*
 * Define the database schema
 */
<#if (project.schema?has_content)>
create schema if not exists ${project.schema};
<#else>
/* No schema name was provided when this code was generated.
 * If you add a schema, remember to add a create-schema statement
 * within your Flyway scripts; to wit:
 *
 *      create schema if not exists [schema-name];
 */
</#if>