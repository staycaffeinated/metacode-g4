<#include "/common/Copyright.ftl">
package ${GlobalExceptionHandler.packageName()};

import lombok.extern.slf4j.Slf4j;
import ${ResourceNotFoundException.fqcn()};
import ${UnprocessableEntityException.fqcn()};
import ${BadRequestException.fqcn()};

import jakarta.validation.ConstraintViolation;
import java.util.Set;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;
import tools.jackson.databind.json.JsonMapper;
import tools.jackson.databind.node.ArrayNode;
import tools.jackson.databind.node.ObjectNode;


/**
 * Handles turning exceptions into RFC-7807 problem/json responses,
 * so instead of an exception and its stack trace leaking back
 * to the client, an RFC-7807 problem description is returned instead.
 */
@SuppressWarnings("unused")
@Slf4j
@ControllerAdvice
@ResponseBody
public class ${GlobalExceptionHandler.className()} {

    private final JsonMapper jsonMapper;

    /**
     * Constructor
     */
    public ${GlobalExceptionHandler.className()}(JsonMapper jsonMapper) {
        this.jsonMapper = jsonMapper;
    }

    @ExceptionHandler(${UnprocessableEntityException.className()}.class)
    @ResponseStatus(HttpStatus.UNPROCESSABLE_CONTENT)
    public Mono<ProblemDetail> handleUnprocessableEntityException(${UnprocessableEntityException.className()} exception) {
        return problemDescription(exception.getLocalizedMessage(), exception, HttpStatus.UNPROCESSABLE_CONTENT);
    }
    
    @ExceptionHandler(${ResourceNotFoundException.className()}.class)
	@ResponseStatus(value = HttpStatus.NOT_FOUND)
	public Mono<ProblemDetail> handleResourceNotFound(${ResourceNotFoundException.className()} exception) {
	    return problemDescription(exception.getLocalizedMessage(), exception, HttpStatus.NOT_FOUND);
	}

    @ExceptionHandler(${BadRequestException.className()}.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Mono<ProblemDetail> handleBadRequestException(${BadRequestException.className()} exception) {
        return problemDescription(exception.getLocalizedMessage(), exception, HttpStatus.BAD_REQUEST);
        }

	@ExceptionHandler(NumberFormatException.class)
	@ResponseStatus(HttpStatus.UNPROCESSABLE_CONTENT)
	public Mono<ProblemDetail> handleNumberFormatException(NumberFormatException exception) {
	    return problemDescription("Bad request: request contains an invalid parameter", exception, HttpStatus.UNPROCESSABLE_CONTENT);
	}

    @ExceptionHandler({jakarta.validation.ConstraintViolationException.class})
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Mono<ProblemDetail> handleConstraintViolationException(jakarta.validation.ConstraintViolationException exception)
    {
        Set<ConstraintViolation<?>> constraintViolations = exception.getConstraintViolations();
        ProblemDetail problemDetail = ProblemDetail.forStatus(HttpStatus.BAD_REQUEST);

        ArrayNode jsonArray = jsonMapper.createArrayNode();

        for (final var constraint : constraintViolations) {
            ObjectNode objectNode = jsonMapper.createObjectNode();

            String className = constraint.getLeafBean().getClass().getSimpleName();
            String message = constraint.getMessage();
            String fullPath = constraint.getPropertyPath().toString();
            String propertyPath =  fullPath.contains(".") ? fullPath.substring(0, fullPath.indexOf('.')) : fullPath;
            Object invalidValue = constraint.getInvalidValue();

            log.error(
                    "Constraint violation: {} on property {} with value {} in class {}",
                    message,
                    propertyPath,
                    invalidValue,
                    className);

            objectNode.put("reason", message);
            if (invalidValue != null) {
                objectNode.put("invalid value", invalidValue.toString());
            }
            objectNode.put("method", propertyPath);

            jsonArray.add(objectNode);
        }
        problemDetail.setProperty("errors", jsonArray);
        return Mono.just(problemDetail);
    }

    @ExceptionHandler(ResponseStatusException.class)
    public Mono<ResponseEntity<ProblemDetail>> handleResponseStatusException(ResponseStatusException exception) {
        HttpStatusCode statusCode = exception.getStatusCode();
        ProblemDetail problem = ProblemDetail.forStatus(statusCode);
        String reason = exception.getReason();
        if (reason != null) {
            problem.setDetail(reason);
        }
        return Mono.just(ResponseEntity.status(statusCode).body(problem));
    }

    /**
     * Catch anything not caught by other handlers
     */
    @ExceptionHandler(Throwable.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    @SuppressWarnings({
        "java:S1172" // `exchange` is unused but needed for the method signature
    })
    public Mono<ProblemDetail> handle(ServerWebExchange exchange, Throwable ex) {
        return problemDescription("Unexpected server error", ex, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    private Mono<ProblemDetail> problemDescription(String title, Throwable throwable, HttpStatus status) {
        ProblemDetail problem = ProblemDetail.forStatus(status);
        problem.setDetail(throwable.getMessage());
        problem.setTitle(title);
        return Mono.just(problem);
    }
}
