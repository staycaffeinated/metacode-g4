<#include "/common/Copyright.ftl">
package ${ResourceIdAnnotation.packageName()};

import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.Target;

import static java.lang.annotation.ElementType.*;
import static java.lang.annotation.RetentionPolicy.RUNTIME;

@Target({METHOD, FIELD, PARAMETER})
@Retention(RUNTIME)
@Constraint(validatedBy = ${ResourceIdValidator.className()}.class)
@Documented
public @interface ${ResourceIdAnnotation.className()} {
    String message() default "{ResourceId.invalid}";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}
