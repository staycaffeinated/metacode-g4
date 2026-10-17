<#include "/common/Copyright.ftl">
package ${Routes.packageName()};

/**
 * Route constants for ${endpoint.entityName} resources.
 */
@SuppressWarnings({"java:S1075"})
public final class ${Routes.className()} {

    private ${Routes.className()}() {}

    public static final String BASE_PATH = "${endpoint.route}";
    public static final String ID_PARAMETER = "/{id}";

    public static final String ${endpoint.routeConstants.findAll} = BASE_PATH + "/findAll";
    public static final String ${endpoint.routeConstants.findOne} = BASE_PATH + ID_PARAMETER;
    public static final String ${endpoint.routeConstants.stream} = BASE_PATH + "/stream";
    public static final String ${endpoint.routeConstants.create} = BASE_PATH;
    public static final String ${endpoint.routeConstants.update} = BASE_PATH + ID_PARAMETER;
    public static final String ${endpoint.routeConstants.delete} = BASE_PATH + ID_PARAMETER;
    public static final String ${endpoint.routeConstants.search} = BASE_PATH + "/search";
}
