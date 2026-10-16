<#include "/common/Copyright.ftl">
package ${SearchTextValidator.packageName()};

import org.springframework.util.ObjectUtils;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

public class ${SearchTextValidator.className()} implements ConstraintValidator<${SearchTextAnnotation.className()}, String> {

    private static final int MAXLENGTH = 24;

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (ObjectUtils.isEmpty(value)) return true;
        return value.length() <= MAXLENGTH;
    }
}
