<#include "/common/Copyright.ftl">
package ${BadRequestException.packageName()};

import java.io.Serial;

/**
 * Indicates the request could not be processed due to a client error (HTTP 400).
 */
public class BadRequestException extends RuntimeException {

    @Serial
    private static final long serialVersionUID = 1968592496239029423L;

    /**
     * Default Constructor
     */
    public BadRequestException() {
        super();
    }

    /**
     * Constructor
     */
    public BadRequestException(Throwable throwable) {
        super("The request cannot be processed due to client error", throwable);
    }

    /**
     * Constructor with a reason to add to the exception
     * message as explanation.
     *
     * @param reason the associated reason (optional)
     */
    public BadRequestException(String reason) {
        super(reason);
    }

    /**
     * Constructor with a reason to add to the exception
     * message as an explanation, as well as a nested exception.
     *
     * @param the reason for the exception (optional)
     * @param the cause for the exception (optional)
     */
    public BadRequestException(String reason, Throwable cause) {
        super(reason, cause);
    }
}
