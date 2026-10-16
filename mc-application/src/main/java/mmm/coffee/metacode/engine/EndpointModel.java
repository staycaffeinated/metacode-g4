package mmm.coffee.metacode.engine;

import mmm.coffee.metacode.core.descriptor.EndpointDescriptor;

/**
 * Exposes endpoint-specific checks and names to FreeMarker templates via
 * the "endpoint" variable. Templates call ${endpoint.entityName},
 * ${endpoint.isWithOpenApi()}, ${endpoint.routeConstants.findAll}, etc.
 */
public class EndpointModel {

    private final String entityName;
    private final String entityVarName;
    private final String lowerCaseEntityName;
    private final String pojoName;
    private final String ejbName;
    private final String tableName;
    private final String route;
    private final boolean withOpenApi;
    private final boolean withPostgres;
    private final boolean withTestContainers;
    private final RouteConstants routeConstants;

    public EndpointModel(EndpointDescriptor d) {
        this.entityName = d.getEntityName();
        this.entityVarName = Character.toLowerCase(d.getEntityName().charAt(0))
                + d.getEntityName().substring(1);
        this.lowerCaseEntityName = d.getEntityName().toLowerCase();
        this.pojoName = d.getEntityName();
        this.ejbName = d.getEntityName() + "Entity";
        this.tableName = d.getEntityName().toLowerCase();
        this.route = d.getRoute();
        this.withOpenApi = d.getFeatures().contains("openapi");
        this.withPostgres = d.getFeatures().contains("postgres");
        this.withTestContainers = d.getFeatures().contains("testcontainers");
        this.routeConstants = new RouteConstants();
    }

    public String getEntityName() {
        return entityName;
    }

    public String getEntityVarName() {
        return entityVarName;
    }

    public String getLowerCaseEntityName() {
        return lowerCaseEntityName;
    }

    public String getPojoName() {
        return pojoName;
    }

    public String getEjbName() {
        return ejbName;
    }

    public String getTableName() {
        return tableName;
    }

    public String getRoute() {
        return route;
    }

    public boolean isWithOpenApi() {
        return withOpenApi;
    }

    public boolean isWithPostgres() {
        return withPostgres;
    }

    public boolean isWithTestContainers() {
        return withTestContainers;
    }

    public RouteConstants getRouteConstants() {
        return routeConstants;
    }

    /**
     * Route constant names used in the generated Routes class.
     * Templates reference: ${endpoint.routeConstants.findAll}, etc.
     */
    public static class RouteConstants {
        public String getFindAll() {
            return "FIND_ALL";
        }

        public String getFindOne() {
            return "FIND_ONE";
        }

        public String getCreate() {
            return "CREATE";
        }

        public String getUpdate() {
            return "UPDATE";
        }

        public String getDelete() {
            return "DELETE";
        }

        public String getSearch() {
            return "SEARCH";
        }

        public String getFindByProperty() {
            return "FIND_BY_PROPERTY";
        }

        public String getStream() {
            return "STREAM";
        }
    }
}
