plugins {
    id "java-library"
    id "jvm-test-suite"
}

configurations {
    mockitoAgent
}

dependencies {
    mockitoAgent(libs.mockito) { transitive = false }
}

tasks.withType(Test).configureEach {
    useJUnitPlatform()
    testLogging { events "passed", "skipped", "failed" }
    jvmArgs "--add-opens", "java.base/java.lang=ALL-UNNAMED"
    doFirst {
        <#noparse>jvmArgs "-javaagent:${configurations.mockitoAgent.asPath}"</#noparse>
    }
}
