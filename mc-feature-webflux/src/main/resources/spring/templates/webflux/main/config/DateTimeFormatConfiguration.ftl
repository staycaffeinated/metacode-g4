<#include "/common/Copyright.ftl">

package ${DateTimeFormatConfiguration.packageName()};

import org.springframework.context.annotation.Configuration;
import org.springframework.format.FormatterRegistry;
import org.springframework.format.datetime.standard.DateTimeFormatterRegistrar;
import org.springframework.web.reactive.config.WebFluxConfigurer;

/**
* Configure the converters to use the ISO format for dates by default.
*/
@Configuration
public class ${DateTimeFormatConfiguration.className()} implements WebFluxConfigurer {

    @Override
    public void addFormatters(FormatterRegistry registry) {
        DateTimeFormatterRegistrar registrar = new DateTimeFormatterRegistrar();
        registrar.setUseIsoFormat(true);
        registrar.registerFormatters(registry);
    }
}