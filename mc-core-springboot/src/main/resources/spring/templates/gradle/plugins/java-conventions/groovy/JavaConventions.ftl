plugins {
    id "java-library"
    id "java-test-fixtures"
    id "buildlogic.testing"
    id "buildlogic.sonar-jacoco"
    id "buildlogic.jacoco"
    id "buildlogic.spotless"
}

java {
    def javaVersion = 21
    try {
        javaVersion = rootProject.file('.java-version').text.trim()
    }
    catch (Exception e) {
        javaVersion = 21
    }
    toolchain {
        languageVersion = JavaLanguageVersion.of(javaVersion as String)
    }
    sourceCompatibility = JavaLanguageVersion.of(javaVersion as String)
    targetCompatibility = JavaLanguageVersion.of(javaVersion as String)
}

tasks.withType(JavaCompile).configureEach {
    options.compilerArgs << '-Xlint:unchecked'
    options.compilerArgs << '-Xlint:-processing'
    options.compilerArgs << '-Xlint:-serial'
    options.compilerArgs << '-Werror'
}

configurations.create("transitiveSourcesElements") {
    visible = false
    canBeResolved = false
    canBeConsumed = true
    extendsFrom(configurations.implementation)
    attributes {
        attribute(Usage.USAGE_ATTRIBUTE, objects.named(Usage, Usage.JAVA_RUNTIME))
        attribute(Category.CATEGORY_ATTRIBUTE, objects.named(Category, Category.DOCUMENTATION))
        attribute(DocsType.DOCS_TYPE_ATTRIBUTE, objects.named(DocsType, "source-folders"))
    }
    sourceSets.main.java.srcDirs.forEach { outgoing.artifact(it) }
}
