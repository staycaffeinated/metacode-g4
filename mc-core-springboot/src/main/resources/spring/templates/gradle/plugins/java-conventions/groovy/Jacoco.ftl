plugins {
    id "java-library"
    id "jacoco"
}

tasks.jacocoTestReport {
    reports {
        xml.required = true
        html.required = true
    }
}

test {
    finalizedBy "jacocoTestReport"
}

configurations {
    binaryTestResultsElements {
        canBeResolved = false
        canBeConsumed = true
        attributes {
            attribute(Category.CATEGORY_ATTRIBUTE, objects.named(Category, Category.DOCUMENTATION))
            attribute(DocsType.DOCS_TYPE_ATTRIBUTE, objects.named(DocsType, 'test-report-data'))
        }
        outgoing.artifact(test.binaryResultsDirectory)
    }
}
