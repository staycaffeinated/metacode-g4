<#include "/common/Copyright.ftl">
package ${AlphabeticValidator.packageName()};

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

public class ${AlphabeticValidator.className()} implements ConstraintValidator<${AlphabeticAnnotation.className()}, String> {
    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        return value != null && value.chars().allMatch(Character::isAlphabetic);
    }
}
