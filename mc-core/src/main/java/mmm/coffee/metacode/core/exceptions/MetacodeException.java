package mmm.coffee.metacode.core.exceptions;

public class MetacodeException extends RuntimeException {

    public MetacodeException(String message) {
        super(message);
    }

    public MetacodeException(String message, Throwable cause) {
        super(message, cause);
    }
}
