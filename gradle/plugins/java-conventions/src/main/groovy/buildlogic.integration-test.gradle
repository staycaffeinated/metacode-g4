plugins {
    id "java-library"
    id "jvm-test-suite"
}

// --------------------------------------------------------------------------------
// Define configurations for integrationTest and performanceTest
// --------------------------------------------------------------------------------
testing {
    suites {
        test {
            useJUnitJupiter()
        }
        /*
         * Define the integration test suite
         */
        integrationTest(JvmTestSuite) {
            // This is not supported in Gradle 8.13 and newer, but is needed in older versions
            // testType.set(TestSuiteType.INTEGRATION_TEST)
            dependencies {
                implementation project()
            }
            targets {
                all {
                    testTask.configure {
                        shouldRunAfter(test)
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

/*
 * The 'check' task will trigger integration tests and generate the coverage report.
 */
tasks.named('check') {
  dependsOn(testing.suites.integrationTest)
  dependsOn tasks.matching { it.name == 'integrationTestCodeCoverageReport' }
}

/*
 * Ensure the IT coverage report is fresh before Sonar runs. Stale IT reports
 * contain old compiled line-number mappings; mixing them with a freshly compiled
 * unit-test report causes Sonar to flag newly added lines as uncovered.
 * tasks.matching returns an empty collection (no error) when sonar is not applied.
 */
tasks.matching { it.name == 'sonar' }.configureEach {
  dependsOn tasks.matching { it.name == 'integrationTestCodeCoverageReport' }
}

