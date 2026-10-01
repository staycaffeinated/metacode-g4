<#include "/common/Copyright.ftl">
package ${GlobalExceptionHandler.packageName()};

import static org.assertj.core.api.Assertions.assertThat;

import ${ResourceNotFoundException.fqcn()};
import ${UnprocessableEntityException.fqcn()};
import ${BadRequestException.fqcn()};
import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import jakarta.validation.Validation;
import jakarta.validation.ValidatorFactory;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.executable.ExecutableValidator;
import java.lang.reflect.Method;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Stream;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;
import org.mockito.Mockito;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.server.ServerWebExchange;
import reactor.test.StepVerifier;
import tools.jackson.databind.json.JsonMapper;
import tools.jackson.databind.node.ArrayNode;



/**
 * Unit tests of the GlobalExceptionHandler
 */
class ${GlobalExceptionHandler.testClass()} {

    private ${GlobalExceptionHandler.className()} exceptionHandlerUnderTest;

    @BeforeEach
    void setUp() {
        exceptionHandlerUnderTest = new GlobalExceptionHandler(new JsonMapper());
    }

    @Test
    void whenUnprocessableEntityException_expectHttpStatusIsUnprocessableEntity() {
        // when
        var publisher = exceptionHandlerUnderTest .handleUnprocessableEntityException(new UnprocessableEntityException("test"));

        // then
        StepVerifier.create(publisher).expectSubscription()
            .consumeNextWith(p -> assertThat(p.getStatus()).isEqualTo(HttpStatus.UNPROCESSABLE_CONTENT.value()))
            .verifyComplete();
    }

    @Test
    void whenResourceNotFoundException_expectHttpStatusIsNotFound() {
        // when
        var publisher = exceptionHandlerUnderTest.handleResourceNotFound(new ResourceNotFoundException("test"));

        // then
        StepVerifier.create(publisher).expectSubscription()
            .consumeNextWith(p -> assertThat(p.getStatus()).isEqualTo(HttpStatus.NOT_FOUND.value()))
            .verifyComplete();
    }

    @Test
    void whenBadRequestException_expectHttpStatusIsBadRequest() {
        // when
        var publisher = exceptionHandlerUnderTest.handleBadRequestException(new BadRequestException("test"));

        // then
        StepVerifier.create(publisher)
                    .expectSubscription()
                    .consumeNextWith(p -> assertThat(p.getStatus()).isEqualTo(HttpStatus.BAD_REQUEST.value()))
                    .verifyComplete();
    }

    @Test
    void whenNumberFormatExceptionException_expectHttpStatusIsUnprocessableEntity() {
        // when
        var publisher = exceptionHandlerUnderTest.handleNumberFormatException(new NumberFormatException("test"));

        // then
        StepVerifier.create(publisher).expectSubscription()
            .consumeNextWith(p -> assertThat(p.getStatus()).isEqualTo(HttpStatus.UNPROCESSABLE_CONTENT.value()))
            .verifyComplete();
    }

    @Test
    void verifyHandleMethodReturnProblemDetail() {
        var serverWebExchange = Mockito.mock(ServerWebExchange.class);
        var publisher = exceptionHandlerUnderTest.handle(serverWebExchange, new Throwable());

        StepVerifier.create(publisher)
                    .expectSubscription()
                    .consumeNextWith(p -> assertThat(p.getStatus()).isEqualTo(HttpStatus.INTERNAL_SERVER_ERROR.value()))
                    .verifyComplete();
    }

    @Test
    void whenResponseStatusExceptionWithReason_expectDetailEqualsReason() {
        // given
        var exception = new ResponseStatusException(HttpStatus.NOT_FOUND, "Widget not found");

        // when
        var publisher = exceptionHandlerUnderTest.handleResponseStatusException(exception);

        // then
        StepVerifier.create(publisher)
                .expectSubscription()
                .consumeNextWith(re -> {
                    assertThat(re.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
                    assertThat(re.getBody()).isNotNull();
                    assertThat(re.getBody().getDetail()).isEqualTo("Widget not found");
                })
            .verifyComplete();
    }

    @Test
    void whenResponseStatusExceptionWithoutReason_expectDetailIsNull() {
        // given
        var exception = new ResponseStatusException(HttpStatus.NOT_FOUND);

        // when
        var publisher = exceptionHandlerUnderTest.handleResponseStatusException(exception);

        // then
        StepVerifier.create(publisher)
            .expectSubscription()
            .consumeNextWith(re -> {
                assertThat(re.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
                assertThat(re.getBody()).isNotNull();
                assertThat(re.getBody().getDetail()).isNull();
            })
            .verifyComplete();
    }

    @ParameterizedTest
    @MethodSource("provideSampleObject")
    void whenConstraintViolationException_expectProblemDetail(SampleObject sampleObject) {
        // given
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        ConstraintViolationException exception = getConstraintViolationException(factory, sampleObject);

        // when
        var publisher = exceptionHandlerUnderTest.handleConstraintViolationException(exception);

        // then
        StepVerifier.create(publisher)
            .expectSubscription()
            .consumeNextWith(p -> {
                assertThat(p).isNotNull();
                assertThat(p.getStatus()).isEqualTo(HttpStatus.BAD_REQUEST.value());
                assertThat(p.getProperties()).isNotNull().containsKey("errors");
                var errors = (ArrayNode) p.getProperties().get("errors");
                assertThat(errors).isNotEmpty();
            })
            .verifyComplete();
    }


    /**
     * dotIndex < 0: field-level constraint produces a path with no dot (e.g. "name"),
     * so the handler uses the full path as-is.
     */
    @Test
    void whenConstraintViolationPathHasNoDot_expectFullPathUsed() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        jakarta.validation.Validator validator = factory.getValidator();

        Set<ConstraintViolation<SingleFieldBean>> violations = validator.validate(new SingleFieldBean(null));
        assertThat(violations).hasSize(1);

        String fullPath = violations.iterator().next().getPropertyPath().toString();
        assertThat(fullPath).doesNotContain(".");

        ConstraintViolationException exception = new ConstraintViolationException(violations);
        var publisher = exceptionHandlerUnderTest.handleConstraintViolationException(exception);

        // then
        StepVerifier.create(publisher)
                    .expectSubscription()
                    .consumeNextWith(p -> {
                        assertThat(p).isNotNull();
                        assertThat(p.getStatus()).isEqualTo(HttpStatus.BAD_REQUEST.value());
                        assertThat(p.getProperties()).isNotNull().containsKey("errors");
                        var errors = (ArrayNode) p.getProperties().get("errors");
                        assertThat(errors).hasSize(1);
                        assertThat(errors.get(0).get("method").asString()).isEqualTo(fullPath);
                    })
                    .verifyComplete();
    }


    /**
     * dotIndex >= 0: method-parameter constraint produces a path like "process.name", ]
     * so the handler truncates at the dot and stores only "process"
     */
    @Test
    void whenConstraintViolationPathHasDot_expectPathTruncatedBeforeDot() throws NoSuchMethodException {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        ExecutableValidator executableValidator = factory.getValidator().forExecutables();

        // validateParameters with null triggers @NotNull; Hibernate Validator builds a path
        // of the form "process.name" (or "process.arg0" without -parameters flag) — either
        // way the dot is present, which is the condition under test.
        ConstrainedParamService service = new ConstrainedParamService();
        Method method = ConstrainedParamService.class.getMethod("process", String.class);
        Set<ConstraintViolation<ConstrainedParamService>> violations =
                executableValidator.validateParameters(service, method, new Object[] {null});

        assertThat(violations).hasSize(1);
        String fullPath = violations.iterator().next().getPropertyPath().toString();
        assertThat(fullPath).contains(".");

        ConstraintViolationException exception = new ConstraintViolationException(violations);
        var publisher = exceptionHandlerUnderTest.handleConstraintViolationException(exception);

        // then
        StepVerifier.create(publisher)
                    .expectSubscription()
                    .consumeNextWith(p -> {
                        assertThat(p).isNotNull();
                        assertThat(p.getStatus()).isEqualTo(HttpStatus.BAD_REQUEST.value());
                        assertThat(p.getProperties()).isNotNull().containsKey("errors");
                        var errors = (ArrayNode) p.getProperties().get("errors");
                        assertThat(errors).hasSize(1);
                        // handler must store only the part before the first dot
                        String expectedTruncated = fullPath.substring(0, fullPath.indexOf('.'));
                        assertThat(errors.get(0).get("method").asString()).isEqualTo(expectedTruncated);
                })
                .verifyComplete();
    }

    /* =======================================================================================
     * HELPER METHODS
     * ======================================================================================= */

    static Stream<Arguments> provideSampleObject() {
        // example of bad data
        SampleObject sample1 = new SampleObject("abc123", 12, false, "1234568", -1);
        // example of null data
        SampleObject sample2 = new SampleObject(null, 12, false, null, -1);

        return Stream.of(Arguments.of(sample1), Arguments.of(sample2));
    }

    private static ConstraintViolationException getConstraintViolationException(ValidatorFactory factory, SampleObject ts)
    {
        jakarta.validation.Validator validator = factory.getValidator();
        // Invoke validate() to trigger the validation
        Set<ConstraintViolation<SampleObject>> violations = validator.validate(ts);
        // Create an exception that wraps the constraint violations
        return new ConstraintViolationException(violations);
    }

    private static class SingleFieldBean {
        @NotNull(message = "name must not be null")
        final String name;

        SingleFieldBean(String name) {
            this.name = name;
        }
    }

    public static class ConstrainedParamService {
        public void process(@NotNull(message = "name must not be null") String name) {
            // no-op method
        }
    }


    /**
     * A sample class that contains validation annotations.
     * Instances of this class can be used to verify how validation errors are handled
     * and how the ProblemDetail is populated.
     * <p>
     * This is borrowed from:
     * https://www.geeksforgeeks.org/spring-boot-data-and-field-validation-using-jakarta-validation-constraints/
     */
    private static class SampleObject {
        public interface AllLevels {}

        public interface Junior {}

        public interface MidSenior {}

        public interface Senior {}

        <#noparse>
        @Size(min = 5, max = 20, message = "Name must be between 5 and 20 characters long")
        @Pattern(regexp = "[0-9]", message = "Name must not contain numbers")
        @NotBlank(message = "Name is a mandatory field")
        </#noparse>
        final String name;

        <#noparse>
        @Min(value = 5, groups = Junior.class, message = "Junior level requires at least 5 years of experience")
        @Min(value = 10, groups = MidSenior.class, message = "Mid-Senior level requires at least 10 years of experience")
        @Min(value = 15, groups = Senior.class, message = "Senior level requires at least 15 years of experience")
        </#noparse>
        final int exp;

        <#noparse>@AssertTrue(message = "You are not an admin")</#noparse>
        final boolean isAdmin;

        <#noparse>@Pattern(regexp = "\\d{10}", message = "Mobile number must have exactly 10 digits")</#noparse>
        final String mobilNumber;

        <#noparse>final Optional<@Min(value = 0, message = "Weight must be at least 0") Long> weight;</#noparse>

        public SampleObject(String name, int exp, boolean isAdmin, String mobilNumber, long weight) {
            this.name = name;
            this.exp = exp;
            this.isAdmin = isAdmin;
            this.mobilNumber = mobilNumber;
            this.weight = Optional.of(weight);
        }
    }
}