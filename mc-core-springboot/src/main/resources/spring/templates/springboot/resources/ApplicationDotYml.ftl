
server:
  port: 8080
  shutdown: graceful
  servlet:
<#if (project.basePath)??>
    context-path: ${project.basePath}
<#else>
    context-path: /
</#if>

<#if (project.isWithOpenApi())>
springdoc:
  api-docs:
    enabled: true
  swagger-ui:
    enabled: true
</#if>

management:
  endpoints:
    web:
      exposure:
        include: health,info
  endpoint:
    health:
      probes:
        enabled: true
  health:
    livenessState:
      enabled: true
    readinessState:
      enabled: true

spring:
  application:
<#if (project.applicationName)??>
    name: ${project.applicationName}
<#else>
    name: example-service
</#if>

<#if (project.isWithPostgres())>
  jpa:
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        id:
          new_generator_mappings: false

  datasource:
    driver-class-name: org.postgresql.Driver
    <#noparse>
    username: ${DB_USERNAME:root}
    password: ${DB_PASSWORD:secret}
    </#noparse>
    url: jdbc:postgresql://localhost:5432
</#if>

<#if (project.isWithKafka())>
  # -------------------------------------------------------------------------------------------
  # Kafka
  # -------------------------------------------------------------------------------------------
  kafka:
    bootstrap-servers: localhost:9092
    consumer:
      auto-commit-interval: 1s
      bootstrap-servers: <#noparse>${spring.kafka.bootstrap-servers}</#noparse>
      client-id: <#noparse>${spring.application.name}-${HOSTNAME:localhost}</#noparse>
      enable-auto-commit: true
      group-id: <#noparse>${spring.application.name}</#noparse>
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.apache.kafka.common.serialization.StringDeserializer
    producer:
      bootstrap-servers: <#noparse>${spring.kafka.bootstrap-servers}</#noparse>
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.apache.kafka.common.serialization.StringSerializer
      properties:
        acks: all
        retries: 10
        retry:
          backoff:
            ms: 1000
    listener:
      ack-count: 3
      client-id: <#noparse>${spring.application.name}</#noparse>
      concurrency: 2
      missing-topics-fatal: false
    #
    # Kafka Streams. Remove this stanza if it doesn't apply to your project.
    #
    streams:
      application-id: <#noparse>"${spring.application.name}"</#noparse>
      # This is optional if `spring.kafka.bootstrap-servers` is configured.
      bootstrap-servers: <#noparse>${spring.kafka.bootstrap-servers}</#noparse>
      properties:
        default:
          key:
            serde: 'org.apache.kafka.common.serialization.Serdes$StringSerde'
          value:
            serde: 'org.apache.kafka.common.serialization.Serdes$StringSerde'
          deserialization:
            exception:
              handler: 'org.apache.kafka.streams.errors.LogAndContinueExceptionHandler'
          serialization:
            exception:
              handler: 'org.apache.kafka.streams.errors.LogAndContinueExceptionHandler'
</#if>

  # -------------------------------------------------------------------------
  # Threading
  # -------------------------------------------------------------------------
  threads:
    virtual:
      enabled: true
