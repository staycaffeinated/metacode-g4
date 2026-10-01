<#include "/common/Copyright.ftl">

package ${ObjectMapperConfiguration.packageName()};

import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.SerializationFeature;
import tools.jackson.databind.json.JsonMapper;


@Configuration
@Slf4j
@SuppressWarnings({
    "java:S125" // allow code examples in comment blocks
})
public class ${ObjectMapperConfiguration.className()} {

    @Bean
    public ObjectMapper objectMapper() {
        return JsonMapper.builder()
            .findAndAddModules()
            .build();
    }

    @Bean
    JsonMapper jsonMapper(JsonMapper.Builder builder) {
        return builder
            .enable(SerializationFeature.INDENT_OUTPUT)
            .build();
    }
}
