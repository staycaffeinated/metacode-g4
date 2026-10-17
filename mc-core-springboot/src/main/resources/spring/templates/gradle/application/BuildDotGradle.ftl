plugins {
    id 'buildlogic.application-conventions'
    id 'buildlogic.integration-test'
    id 'jacoco-report-aggregation'
    alias(libs.plugins.spring.boot)
    alias(libs.plugins.dependency.management)
    alias(libs.plugins.versions)
    alias(libs.plugins.lombok.plugin)
}

version = '0.0.1'

<#if project.isSpringBatch()>
/*
 * Until integration tests are written, a build will fail because no integration
 * tests are discovered. The code generator cannot generate integration tests because
 * it has no idea what ItemReaders/ItemProcessors/ItemWriters will be implemented,
 * nor what order the Steps will be in.  On the other hand, we want the directory
 * structure and a placeholder test to be available as a starting point. To have the
 * placeholder while also avoiding a build failure, the `failOnNoDiscoveredTests`
 * flag is set to `false`.  Once integration tests are written, `failOnNoDiscoveredTests`
 * should be set to `true`, or just remove this block.
 */
integrationTest {
    failOnNoDiscoveredTests = false
}

</#if>
<#if project.isWebFlux()>
<#include "WebFluxDependencies.ftl">
<#elseif project.isWebMvc()>
<#include "WebMvcDependencies.ftl">
<#elseif project.isSpringBatch()>
<#include "SpringBatchDependencies.ftl">
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
