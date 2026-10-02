[versions]
archunit = '1.5.0'
assertJ = '3.27.7'
datafaker = '2.7.0'
flyway = '13.3.0'
flyway-test = '10.0.0'
guava = '33.4.8-jre'
gradle-retry = '1.6.2'
h2 = '2.5.250'
junit = '6.1.3'
liquibase = '5.0.2'
lombok = '1.18.46'
lombokPlugin = '9.2.0'
mockito = '5.23.0'
openApiStarterWebMvc = '3.1.1'
openApiStarterWebflux = '3.1.1'
postgresql = '42.7.13'
r2dbcH2 = '1.1.0.RELEASE'
r2dbcPostgres = '1.1.2.RELEASE'
r2dbcSpi = '1.0.0.RELEASE'
reactorTest = '3.8.6'
rsql = '7.0.2'
sonar = '7.5.0.8588'
spotless = '7.0.4'
springBoot = '4.1.0'
springDependencyManagement = '1.1.7'
swaggerAnnotations = '2.2.55'
testContainers = '2.0.5'
truth = '1.4.4'
jib = '3.4.4'
benManesPlugin = '0.62.0'
problemSpringWeb = '0.29.1'
problemJacksonDataType = '0.27.1'

[libraries]
archunit-junit5 = { module = "com.tngtech.archunit:archunit-junit5", version.ref = "archunit" }

assertJ = { module = "org.assertj:assertj-core", version.ref = "assertJ" }

datafaker = { module = "net.datafaker:datafaker", version.ref = "datafaker" }

flyway-core = { module = "org.flywaydb:flyway-core", version.ref = "flyway" }
flyway-database-postgresql = { module = "org.flywaydb:flyway-database-postgresql", version.ref = "flyway" }
flyway-spring-test = { module = "org.flywaydb.flyway-test-extensions:flyway-spring-test", version.ref = "flyway-test" }
flyway-test = { module = "org.flywaydb.flyway-test-extensions:flyway-test", version.ref = "flyway-test" }

h2 = { module = "com.h2database:h2", version.ref = "h2" }

jackson-datatype-jsr310 = { module = "com.fasterxml.jackson.datatype:jackson-datatype-jsr310" }
jackson-core = { module = "tools.jackson.core:jackson-core" }
jackson-databind = { module = "tools.jackson.core:jackson-databind" }

jakarta-persistence-api = { module = "jakarta.persistence:jakarta.persistence-api" }
jakarta-validation-api = { module = "jakarta.validation:jakarta.validation-api" }

junit-jupiter = { module = "org.junit.jupiter:junit-jupiter", version.ref = "junit" }
junit-jupiter-api = { module = "org.junit.jupiter:junit-jupiter-api", version.ref = "junit" }
junit-jupiter-params = { module = "org.junit.jupiter:junit-jupiter-params", version.ref = "junit" }
junit-platform-launcher = { module = "org.junit.platform:junit-platform-launcher" }

liquibase-core = { module = "org.liquibase:liquibase-core", version.ref = "liquibase" }

lombok = { module = "org.projectlombok:lombok", version.ref = "lombok" }

mockito = { module = "org.mockito:mockito-core", version.ref = "mockito" }
mockito-junit-jupiter = { module = "org.mockito:mockito-junit-jupiter", version.ref = "mockito" }

openapi-starter-webmvc-ui = { module = "org.springdoc:springdoc-openapi-starter-webmvc-ui", version.ref = "openApiStarterWebMvc" }
openapi-starter-webflux-ui = { module = "org.springdoc:springdoc-openapi-starter-webflux-ui", version.ref = "openApiStarterWebflux" }

postgresql = { module = "org.postgresql:postgresql", version.ref = "postgresql" }

problem-spring-web-starter = { module = "org.zalando:problem-spring-web-starter", version.ref = "problemSpringWeb" }
problem-spring-webflux = { module = "org.zalando:problem-spring-webflux", version.ref = "problemSpringWeb" }
problem-jackson-datatype = { module = "org.zalando:jackson-datatype-problem", version.ref = "problemJacksonDataType" }

r2dbc-h2 = { module = "io.r2dbc:r2dbc-h2", version.ref = "r2dbcH2" }
r2dbc-postgres = { module = "org.postgresql:r2dbc-postgresql", version.ref = "r2dbcPostgres" }
r2dbc-spi = { module = "io.r2dbc:r2dbc-spi", version.ref = "r2dbcSpi" }

reactor-test = { module = "io.projectreactor:reactor-test", version.ref = "reactorTest" }
rsql-jpa-spring-boot-starter = { module = "io.github.perplexhub:rsql-jpa-spring-boot-starter", version.ref = "rsql" }

spring-boot-autoconfigure = { module = "org.springframework.boot:spring-boot-autoconfigure" }
spring-boot-config-processor = { module = "org.springframework.boot:spring-boot-configuration-processor" }
spring-boot-devtools = { module = "org.springframework.boot:spring-boot-devtools" }
spring-boot-properties-migrator = { module = "org.springframework.boot:spring-boot-properties-migrator" }
spring-boot-starter-actuator = { module = "org.springframework.boot:spring-boot-starter-actuator" }
spring-boot-starter-data-jpa = { module = "org.springframework.boot:spring-boot-starter-data-jpa" }
spring-boot-starter-data-r2dbc = { module = "org.springframework.boot:spring-boot-starter-data-r2dbc" }
spring-boot-starter-flyway = { module = "org.springframework.boot:spring-boot-starter-flyway" }
spring-boot-starter-hateoas = { module = "org.springframework.boot:spring-boot-starter-hateoas" }
spring-boot-starter-liquibase = { module = "org.springframework.boot:spring-boot-starter-liquibase" }
spring-boot-starter-test = { module = "org.springframework.boot:spring-boot-starter-test" }
spring-boot-starter-validation = { module = "org.springframework.boot:spring-boot-starter-validation" }
spring-boot-starter-web = { module = "org.springframework.boot:spring-boot-starter-web" }
spring-boot-starter-webflux = { module = "org.springframework.boot:spring-boot-starter-webflux" }
spring-boot-test-autoconfigure = { module = "org.springframework.boot:spring-boot-test-autoconfigure" }
spring-boot-testcontainers = { module = "org.springframework.boot:spring-boot-testcontainers" }

swagger-annotations = { module = "io.swagger.core.v3:swagger-annotations", version.ref = "swaggerAnnotations" }

testcontainers-bom = { module = "org.testcontainers:testcontainers-bom", version.ref = "testContainers" }
testcontainers-jupiter = { module = "org.testcontainers:junit-jupiter" }
testcontainers-postgres = { module = "org.testcontainers:postgresql" }
testcontainers-r2dbc = { module = "org.testcontainers:r2dbc" }

truth = { module = "com.google.truth:truth", version.ref = "truth" }

[plugins]
dependency-management = { id = "io.spring.dependency-management", version.ref = "springDependencyManagement" }
jib = { id = "com.google.cloud.tools.jib", version.ref = "jib" }
lombok-plugin = { id = "io.freefair.lombok", version.ref = "lombokPlugin" }
sonar = { id = "org.sonarqube", version.ref = "sonar" }
spring-boot = { id = "org.springframework.boot", version.ref = "springBoot" }
versions = { id = "com.github.ben-manes.versions", version.ref = "benManesPlugin" }
