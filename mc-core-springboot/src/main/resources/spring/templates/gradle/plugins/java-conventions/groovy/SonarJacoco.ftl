plugins {
    id "org.sonarqube"
    id "jacoco"
}

def ignoredClasses =
    "**/Exception.java," +
    "**/*Test*.java," +
    "**/*IT.java," +
    "**/ResourceIdTrait.java," +
    "**/*Application.java," +
    "**/*Configuration.java," +
    "**/*Exception.java"

sonarqube {
    properties {
        property("sonar.coverage.exclusions", ignoredClasses)
    }
}

tasks.named('sonar') {
    dependsOn tasks.named('jacocoTestReport')
    dependsOn tasks.matching { it.name == 'testCodeCoverageReport' }
}
