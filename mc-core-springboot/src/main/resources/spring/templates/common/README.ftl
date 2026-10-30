<#-- Template: README.adoc -->
= ${applicationName}

== Developer's Guide
=== Prerequisites

* You must have Java 21 or higher installed to compile and run the project.
* You must have Gradle 9 or higher installed to build the project.

=== First Steps

The code generator does not create a Gradle wrapper; to create one:

```[shell]
gradle wrapper
```

==== Compile the Code

```[shell]
./gradlew build
```

==== Build with Code Coverage

Update the ```gradle.properties``` file and
set the `systemProp.sonar` properties to what's appropriate
for your environment.  Then run this command:

```[shell]
./gradlew clean build sonar
```

==== Change the Java Version

The Java version is defined in the ```.java-version``` file in the
project's root directory, with ```21``` being the default value.
Simply change that number to use a different version of Java.


==== Build a Docker Image

```[shell]
./gradlew jibDockerBuild
```

==== Run the application in Docker

```[shell]
# build the docker image, if you haven't already
./gradlew jibDockerBuild

# navigate to the docker-compose subdirectory
cd docker-compose

# run docker-compose to launch the container
docker-compose up -d
```

==== Check for the latest dependency updates
Ben Manes' `versions` plugin is included in the `build.gradle` file.
This plugin checks for new versions of any dependencies. To check, run

```[shell]
./gradlew dependencyUpdates
```
<#if project.isWithOpenApi()>
==== OpenAPI Documentation

This project was generated with OpenAPI documentation enabled, which enables
viewing the OpenAPI documents for this application in your browser.  Simply
start the application locally (e.g., ```./gradlew bootRun```), then open
<#if project.isWebMvc()>
either of these links in your browser:
<#else>
the following link in your browser
</#if>

```[bash]
<#if project.isWebMvc()>
http://localhost:8080${project.basePath}/swagger-ui/index.html
</#if>
http://localhost:8080${project.basePath}/v3/api-docs
```
</#if>

