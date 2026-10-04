<#include "/common/Copyright.ftl">
package ${BadRequestException.packageName()};

import java.io.Serial;

/**
 * Indicates the request could not be processed due to a client error (HTTP 400).
 */
public class BadRequestException extends RuntimeException {

    @Serial
    private static final long serialVersionUID = 1968592496239029423L;

    public BadRequestException() {
        super();
    }

    public BadRequestException(Throwable throwable) {
        super("The request cannot be processed due to client error", throwable);
    }

    public BadRequestException(String reason) {
        super(reason);
    }

    public BadRequestException(String reason, Throwable cause) {
        super(reason, cause);
    }
}
