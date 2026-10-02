plugins {
    alias(libs.plugins.sonar)
    alias(libs.plugins.lombok.plugin)
    id "buildlogic.subproject-configurations"
    id "jacoco-report-aggregation"
}

dependencies {
    jacocoAggregation project(":application")
}

reporting {
    reports {
        testCodeCoverageReport(JacocoCoverageReport) {
            testSuiteName = "test"
        }
        integrationTestCodeCoverageReport(JacocoCoverageReport) {
            testSuiteName = "integrationTest"
        }
    }
}
