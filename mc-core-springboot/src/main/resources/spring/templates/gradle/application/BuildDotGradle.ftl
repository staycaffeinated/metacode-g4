plugins {
    id 'buildlogic.application-conventions'
    id 'buildlogic.integration-test'
    id 'jacoco-report-aggregation'
    alias(libs.plugins.spring.boot)
    alias(libs.plugins.dependency.management)
    alias(libs.plugins.versions)
    alias(libs.plugins.lombok.plugin)
    alias(libs.plugins.jib)
}

version = '0.0.1'

<#if project.isWebFlux()>
<#include "WebFluxDependencies.ftl">
<#elseif project.isWebMvc()>
<#include "WebMvcDependencies.ftl">
<#else>
<#include "SpringBootDependencies.ftl">
</#if>

jib {
    dockerClient {
        executable = project.findProperty('dockerExecutable') ?: '/usr/local/bin/docker'
    }
    from {
        image = 'eclipse-temurin:21-jre-jammy'
        platforms {
            platform {
                os = 'linux'
                architecture = 'arm64'
            }
            platform {
                os = 'linux'
                architecture = 'amd64'
            }
        }
    }
    to {
        image = '${project.applicationName}'
        <#noparse>tags = ['latest', version]</#noparse>
    }
    container {
        format = 'OCI'
    }
}

sonar {
    properties {
        property "sonar.projectName", "${project.applicationName}"
        property "sonar.projectKey", "${project.applicationName}"
        property "sonar.gradle.skipCompile", "true"
    }
}
