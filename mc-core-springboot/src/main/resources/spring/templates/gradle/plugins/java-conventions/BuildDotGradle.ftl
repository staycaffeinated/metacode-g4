plugins {
    id 'groovy-gradle-plugin'
}

dependencies {
    implementation("org.sonarsource.scanner.gradle:sonarqube-gradle-plugin:6.2.0.5538")
    implementation("com.diffplug.spotless:spotless-plugin-gradle:7.0.4")
    implementation("com.google.guava:guava:33.4.8-jre")
    implementation("org.gradle:test-retry-gradle-plugin:1.6.2")
    implementation("com.google.cloud.tools:jib-gradle-plugin:3.4.4")
}
