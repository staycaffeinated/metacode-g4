plugins {
    id "com.diffplug.spotless"
}

subprojects {
    apply {
        plugin("com.diffplug.spotless")
    }
}

spotless {
    java {
        target fileTree(projectDir) { include 'src/**/*.java' }
        palantirJavaFormat('2.102.0')
        removeUnusedImports()
        importOrder()
        leadingTabsToSpaces(4)
        trimTrailingWhitespace()
        toggleOffOn()
    }
    format 'misc', {
        target '*.gradle', '*.md', '.gitignore'
        trimTrailingWhitespace()
        leadingTabsToSpaces(4)
        endWithNewline()
    }
}

build.dependsOn 'spotlessApply'
check.dependsOn 'spotlessApply'
