pluginManagement {
    includeBuild("./gradle/plugins")
}

dependencyResolutionManagement {
    repositories {
        gradlePluginPortal()
        mavenCentral()
        mavenLocal()
    }
}
