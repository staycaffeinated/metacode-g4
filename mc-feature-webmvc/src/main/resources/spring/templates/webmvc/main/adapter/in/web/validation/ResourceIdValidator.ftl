<#include "/common/Copyright.ftl">
package ${ResourceIdValidator.packageName()};

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import ${ResourceIdFormat.fqcn()};

public class ${ResourceIdValidator.className()} implements ConstraintValidator<${ResourceIdAnnotation.className()}, String> {
    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        return value != null
            && value.length() == ${ResourceIdFormat.className()}.RESOURCE_ID_LENGTH
            && value.chars().allMatch(Character::isLetterOrDigit);
    }
}
