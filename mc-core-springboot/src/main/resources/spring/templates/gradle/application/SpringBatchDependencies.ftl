dependencies {
    <#noparse>mockitoAgent("org.mockito:mockito-core") { transitive = false }</#noparse>

    annotationProcessor libs.spring.boot.config.processor

    developmentOnly libs.spring.boot.devtools

    implementation libs.spring.boot.starter.web
    implementation libs.spring.boot.starter.batch
    implementation libs.spring.boot.starter.data.jpa

    runtimeOnly libs.spring.boot.properties.migrator

    testImplementation libs.spring.boot.starter.test
    testImplementation libs.spring.boot.starter.jdbc.test
    testImplementation libs.junit.jupiter
    testImplementation libs.spring.batch.test
}
