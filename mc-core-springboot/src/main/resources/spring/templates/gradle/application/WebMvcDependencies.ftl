dependencies {
    <#noparse>mockitoAgent("org.mockito:mockito-core") { transitive = false }</#noparse>

    annotationProcessor libs.spring.boot.config.processor

    developmentOnly libs.spring.boot.devtools

    implementation libs.spring.boot.autoconfigure
    implementation libs.spring.boot.starter.actuator
    implementation libs.spring.boot.starter.web
    implementation libs.spring.boot.starter.data.jpa
    implementation libs.spring.boot.starter.validation
    implementation libs.jakarta.persistence.api
    implementation libs.spring.boot.starter.hateoas
    implementation libs.rsql.jpa.spring.boot.starter
    implementation libs.jackson.core
    implementation libs.jackson.databind
<#if project.isWithOpenApi()>
    implementation libs.swagger.annotations
    implementation libs.openapi.starter.webmvc.ui
</#if>
<#if project.isWithLiquibase()>
    implementation libs.liquibase.core
    implementation libs.spring.boot.starter.liquibase
</#if>
<#if project.isWithFlyway()>
    implementation libs.flyway.core
    implementation libs.spring.boot.starter.flyway
</#if>

    runtimeOnly libs.spring.boot.properties.migrator
<#if project.isWithPostgres()>
    runtimeOnly libs.postgresql
    <#if project.isWithFlyway()>
    runtimeOnly libs.flyway.database.postgresql
    </#if>
<#else>
    runtimeOnly libs.h2
</#if>

    testAnnotationProcessor libs.lombok
    testCompileOnly libs.lombok
    testImplementation libs.archunit.junit5
    testImplementation libs.assertJ
    testImplementation libs.datafaker
    testImplementation libs.spring.boot.starter.test
    testImplementation libs.junit.jupiter
    testImplementation libs.spring.boot.starter.webmvc.test
    testImplementation libs.spring.boot.starter.data.jpa.test
    testImplementation libs.spring.boot.starter.jdbc.test
    testImplementation libs.spring.boot.test.autoconfigure
<#if project.isWithTestContainers()>
    testImplementation(platform(libs.testcontainers.bom))
    testImplementation libs.spring.boot.testcontainers
    testImplementation libs.testcontainers.jupiter
    <#if project.isWithPostgres()>
    testImplementation libs.testcontainers.postgres
    </#if>
<#else>
    testRuntimeOnly libs.h2
</#if>
<#if project.isWithFlyway()>
    testImplementation libs.flyway.spring.test
    testImplementation libs.flyway.test
</#if>
<#if project.isWithLiquibase()>
    testImplementation libs.spring.boot.starter.liquibase
</#if>

    testFixturesImplementation libs.jakarta.persistence.api
    testFixturesImplementation libs.datafaker
}
