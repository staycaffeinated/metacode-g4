plugins {
    id 'buildlogic.application-conventions'
    id 'buildlogic.integration-test'
    id 'jacoco-report-aggregation'
    alias(libs.plugins.versions)
    alias(libs.plugins.lombok.plugin)
}

version = '0.0.1'

dependencies {
    <#noparse>mockitoAgent("org.mockito:mockito-core") { transitive = false }</#noparse>

    testImplementation platform(libs.junit.bom)
    testImplementation libs.assertJ
    testImplementation libs.junit.jupiter
    testImplementation libs.mockito
    testRuntimeOnly libs.junit.platform.launcher
}
