package mmm.coffee.metacode.engine;

import java.util.HashMap;
import java.util.Map;
import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import org.springframework.stereotype.Component;

@Component
public class TemplateModelConverter {

    public Map<String, Object> toFtlModel(ProjectDescriptor d) {
        var model = new HashMap<String, Object>();
        model.put("applicationName", d.getApplicationName());
        model.put("basePackage", d.getBasePackage());
        model.put("basePackagePath", d.getBasePackage().replace('.', '/'));
        model.put("flavor", d.getFlavor());
        model.put("features", d.getFeatures());
        model.put("javaVersion", d.getJavaVersion());
        return model;
    }

    public Map<String, String> toMustacheTokens(ProjectDescriptor d) {
        var tokens = new HashMap<String, String>();
        tokens.put("applicationName", d.getApplicationName());
        tokens.put("basePackage", d.getBasePackage());
        tokens.put("basePackagePath", d.getBasePackage().replace('.', '/'));
        return tokens;
    }
}
