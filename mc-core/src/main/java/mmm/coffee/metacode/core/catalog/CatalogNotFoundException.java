package mmm.coffee.metacode.core.catalog;

public class CatalogNotFoundException extends RuntimeException {

    public CatalogNotFoundException(String message) {
        super(message);
    }

    public CatalogNotFoundException(String message, Throwable cause) {
        super(message, cause);
    }
}
