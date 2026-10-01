<#include "/common/Copyright.ftl">
package ${Application.packageName()};

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ${Application.className()} {
    public static void main(String[] args) {
        SpringApplication.run(${Application.className()}.class, args);
    }
}
