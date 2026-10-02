pluginManagement {
    includeBuild("./gradle/settings")
}

plugins {
    id "buildlogic.repositories"
    id 'org.gradle.toolchains.foojay-resolver-convention' version '0.9.0'
}

rootProject.name = '${project.applicationName}'

include "application"
