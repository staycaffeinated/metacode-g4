<#include "/common/Copyright.ftl">

package ${ApplicationConfiguration.packageName()};

import ${SecureRandomSeries.fqcn()};
import ${ResourceIdSupplier.fqcn()};
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Configure application dependencies
 */
@Configuration
public class ${ApplicationConfiguration.className()} {

    @Bean
    public ${ResourceIdSupplier.className()} resourceIdSupplier() {
        return new ${SecureRandomSeries.className()}();
    }
}