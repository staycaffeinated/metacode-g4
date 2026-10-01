<#include "/common/Copyright.ftl">
package ${Exception.packageName()};

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.server.ResponseStatusException;

/**
 * An ResourceNotFoundException indicates the desired resource was not found.
 */
@ResponseStatus(value = HttpStatus.NOT_FOUND)
public class ResourceNotFoundException extends ResponseStatusException {

    private static final long serialVersionUID = 2377850524866118555L;

    /**
     * Default Constructor
     */
    public ResourceNotFoundException() {
        super(HttpStatus.NOT_FOUND);
    }

    /**
     * Constructor with a reason to add to the exception
     * message as explanation.
     *
     * @param reason the associated reason (optional)
     */
    public ResourceNotFoundException(String reason) {
        super(HttpStatus.NOT_FOUND, reason);
    }

    /**
    * Constructor with a reason to add to the exception
    * message as explanation, as well as a nested exception.
    *
    * @param reason the associated reason (optional)
    * @param cause  a nested exception (optional)
    */
    public ResourceNotFoundException(String reason, Throwable cause) {
        super(HttpStatus.NOT_FOUND, reason, cause);
    }
}