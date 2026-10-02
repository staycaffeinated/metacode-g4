dependencies {
    <#noparse>mockitoAgent("org.mockito:mockito-core") { transitive = false }</#noparse>

    annotationProcessor libs.spring.boot.config.processor

    developmentOnly libs.spring.boot.devtools

    implementation libs.spring.boot.starter.actuator
    implementation libs.spring.boot.starter.web

    runtimeOnly libs.spring.boot.properties.migrator

    testImplementation libs.spring.boot.starter.test
    testImplementation libs.junit.jupiter
}
