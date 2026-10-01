<#if (project.schema?has_content)>
    <#if project.isWithPostgres()>
create schema if not exists ${project.schema};
    <#elseif !(project.isWithMongoDb())>  <#-- i.e., is H2 database -->
create schema if not exists ${project.schema};
set schema ${project.schema}
    </#if>
</#if>