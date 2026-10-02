subprojects {
    sonarqube {
        properties {
            property "sonar.sources", "src/main"
            def testDirs = ["src/test", "src/integrationTest"].findAll {
                new File(projectDir, it).exists() }
            if (!testDirs.isEmpty()) {
                property "sonar.tests", testDirs
            }
            property "sonar.coverage.jacoco.xmlReportPaths", [
<#noparse>
                "${project.buildDir}/reports/jacoco/testCodeCoverageReport/testCodeCoverageReport.xml",
                "${project.buildDir}/reports/jacoco/integrationTestCodeCoverageReport/integrationTestCodeCoverageReport.xml"
</#noparse>
            ]
        }
    }
    task("sonar").dependsOn("jacocoTestReport")
}
