package mmm.coffee.metacode.core.renderer;

import java.util.Map;

/**
 * Renders a FreeMarker template given a data model.
 */
public interface TemplateRenderer {

    /**
     * @param templatePath classpath path to the .ftl template
     * @param model        key/value pairs available inside the template
     * @return rendered content
     */
    String render(String templatePath, Map<String, Object> model);
}
