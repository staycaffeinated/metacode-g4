package ${Architecture.packageName()};

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.classes;
import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;
import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noFields;

import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.RestController;

@AnalyzeClasses(packages = "${project.basePackage}", importOptions = {ImportOption.DoNotIncludeTests.class})
class ${Architecture.testClass()} {

    // ──────────────────────────────────────────────────────────────────────
    // Layer dependency rules
    //      domain → nothing
    //      application → domain only
    //      adapter → no infrastructure, can use domain and application
    //      infrastructure → no adapter
    // ──────────────────────────────────────────────────────────────────────

    @ArchTest
    static final ArchRule domain_must_not_depend_on_other_layers =
        noClasses()
            .that()
            .resideInAPackage("${project.basePackage}.domain..")
            .should()
            .dependOnClassesThat()
            .resideInAnyPackage(
                "${project.basePackage}.application..",
                "${project.basePackage}.adapter..",
                "${project.basePackage}.infrastructure..");


    @ArchTest
    static final ArchRule application_must_not_depend_on_outer_layers =
        noClasses()
            .that()
            .resideInAPackage("${project.basePackage}.application..")
            .should()
            .dependOnClassesThat()
            .resideInAnyPackage(
                    "${project.basePackage}.adapter..",
                    "${project.basePackage}.infrastructure..");


    @ArchTest
    static final ArchRule adapters_must_not_depend_on_infrastructure =
        noClasses()
            .that()
            .resideInAPackage("${project.basePackage}.adapter..")
            .should()
            .dependOnClassesThat()
            .resideInAPackage("${project.basePackage}.infrastructure..");

    @ArchTest
    static final ArchRule infrastructure_must_not_depend_on_adapters =
        noClasses()
            .that()
            .resideInAPackage("${project.basePackage}.infrastructure..")
            .should()
            .dependOnClassesThat()
            .resideInAPackage("${project.basePackage}.adapter..");

    // ──────────────────────────────────────────────────────────────────────
    // Naming conventions
    // ──────────────────────────────────────────────────────────────────────

    @ArchTest
    static final ArchRule rest_controllers_must_be_suffixed_controller =
        classes().that()
            .areAnnotatedWith(RestController.class)
            .should()
            .haveSimpleNameEndingWith("Controller");


    @ArchTest
    static final ArchRule rest_controllers_must_reside_in_adapter_inbound =
        classes().that()
            .areAnnotatedWith(RestController.class)
            .should()
            .resideInAPackage("${project.basePackage}.adapter.inbound..");

    @ArchTest
    static final ArchRule controller_advice_must_reside_in_infrastructure_advice =
        classes().that()
            .areAnnotatedWith(ControllerAdvice.class)
            .should()
            .resideInAPackage("${project.basePackage}.infrastructure.advice..");


    @ArchTest
    static final ArchRule configuration_classes_must_be_suffixed_configuration =
        classes().that()
            .resideInAPackage("${project.basePackage}.infrastructure.config..")
            .and()
            .areAnnotatedWith(Configuration.class)
            .and()
            .areNotAnnotatedWith(SpringBootApplication.class)
            .should()
            .haveSimpleNameEndingWith("Configuration");

    @ArchTest
    static final ArchRule exception_classes_must_be_suffixed_exception =
        classes().that()
            .resideInAPackage("${project.basePackage}..")
            .and()
            .areAssignableTo(Exception.class)
            .should()
            .haveSimpleNameEndingWith("Exception");

    // ──────────────────────────────────────────────────────────────────────
    // Spring best practices
    // ──────────────────────────────────────────────────────────────────────

    @ArchTest
    static final ArchRule no_field_injection =
        noFields()
            .that()
            .areDeclaredInClassesThat()
            .resideInAPackage("${project.basePackage}..")
            .should()
            .beAnnotatedWith(Autowired.class);

}