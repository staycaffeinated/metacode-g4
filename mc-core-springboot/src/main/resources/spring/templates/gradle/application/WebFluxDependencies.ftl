dependencies {
    <#noparse>mockitoAgent("org.mockito:mockito-core") { transitive = false }</#noparse>

    annotationProcessor libs.spring.boot.config.processor

    developmentOnly libs.spring.boot.devtools

    implementation libs.jackson.datatype.jsr310
    implementation libs.r2dbc.spi
    implementation libs.spring.boot.autoconfigure
    implementation libs.spring.boot.starter.data.r2dbc
    implementation libs.spring.boot.starter.actuator
    implementation libs.spring.boot.starter.webflux
    implementation libs.spring.boot.starter.validation
    implementation libs.jakarta.persistence.api
<#if project.isWithOpenApi()>
    implementation libs.swagger.annotations
    implementation libs.openapi.starter.webflux.ui
</#if>
<#if project.isWithLiquibase()>
    implementation libs.liquibase.core
    implementation libs.spring.boot.starter.liquibase
</#if>
<#if project.isWithFlyway()>
    implementation libs.flyway.core
    implementation libs.spring.boot.starter.flyway
</#if>
<#if project.isWithPostgres()>
    implementation libs.r2dbc.postgres
    runtimeOnly libs.postgresql
    <#if project.isWithFlyway()>
    runtimeOnly libs.flyway.database.postgresql
    </#if>
<#else>
    implementation libs.r2dbc.h2
    runtimeOnly libs.h2
</#if>

    runtimeOnly libs.spring.boot.properties.migrator

    testAnnotationProcessor libs.lombok
    testCompileOnly libs.lombok
    testImplementation libs.archunit.junit5
    testImplementation libs.spring.boot.starter.test
    testImplementation libs.spring.boot.starter.webflux.test
    testImplementation libs.junit.jupiter
    testImplementation libs.reactor.test
    testImplementation libs.datafaker
<#if project.isWithTestContainers()>
    testImplementation(platform(libs.testcontainers.bom))
    testImplementation libs.spring.boot.testcontainers
    testImplementation libs.testcontainers.jupiter
    <#if project.isWithPostgres()>
    testImplementation libs.testcontainers.postgres
    testImplementation libs.testcontainers.r2dbc
    </#if>
<#else>
    testRuntimeOnly libs.h2
</#if>
<#if project.isWithFlyway()>
    testImplementation libs.flyway.spring.test
    testImplementation libs.flyway.test
</#if>

    testFixturesImplementation libs.reactor.test
    testFixturesImplementation libs.spring.boot.starter.data.r2dbc
    testFixturesImplementation libs.jakarta.persistence.api
    testFixturesImplementation libs.datafaker
}
