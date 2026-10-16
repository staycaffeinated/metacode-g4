<#include "/common/Copyright.ftl">
package ${AlphabeticAnnotation.packageName()};

import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.Target;

import static java.lang.annotation.ElementType.FIELD;
import static java.lang.annotation.ElementType.METHOD;
import static java.lang.annotation.ElementType.TYPE_USE;
import static java.lang.annotation.RetentionPolicy.RUNTIME;

@Target({ METHOD, FIELD, TYPE_USE })
@Retention(RUNTIME)
@Constraint(validatedBy = ${AlphabeticValidator.className()}.class)
@Documented
public @interface ${AlphabeticAnnotation.className()} {
    String message() default "{Alphabetic.invalid}";
    Class<?>[] groups() default { };
    Class<? extends Payload>[] payload() default { };
}
