plugins {
    id "java-library"
    id "jvm-test-suite"
    id "org.gradle.test-retry"
}

testing {
    suites {
        test {
            useJUnitJupiter()
        }
        integrationTest(JvmTestSuite) {
            dependencies {
                implementation project()
            }
            targets {
                all {
                    testTask.configure {
                        shouldRunAfter(test)
                        retry {
                            maxRetries = 2
                            failOnPassedAfterRetry = false
                        }
                    }
                }
            }
            configurations {
                integrationTestImplementation {
                    extendsFrom testImplementation
                }
            }
        }
    }
}

tasks.named('check') {
    dependsOn(testing.suites.integrationTest)
    dependsOn tasks.matching { it.name == 'integrationTestCodeCoverageReport' }
}

tasks.matching { it.name == 'sonar' }.configureEach {
    dependsOn tasks.matching { it.name == 'integrationTestCodeCoverageReport' }
}
