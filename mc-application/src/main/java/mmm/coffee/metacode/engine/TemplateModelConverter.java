package mmm.coffee.metacode.engine;

import java.time.Year;
import java.util.HashMap;
import java.util.Map;
import mmm.coffee.metacode.core.archetype.ArchetypeModel;
import mmm.coffee.metacode.core.archetype.PackageLayout;
import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import org.springframework.stereotype.Component;

@Component
public class TemplateModelConverter {

    private final PackageLayout packageLayout;

    public TemplateModelConverter(PackageLayout packageLayout) {
        this.packageLayout = packageLayout;
    }

    public Map<String, Object> toFtlModel(ProjectDescriptor d) {
        var model = new HashMap<String, Object>();
        model.put("applicationName", d.getApplicationName());
        model.put("basePackage", d.getBasePackage());
        model.put("basePackagePath", d.getBasePackage().replace('.', '/'));
        model.put("flavor", d.getFlavor());
        model.put("features", d.getFeatures());
        model.put("javaVersion", d.getJavaVersion());
        model.put("YEAR", Year.now().getValue());
        model.put("project", new ProjectModel(d));

        Map<String, ArchetypeModel> archetypes = packageLayout.buildArchetypeModels(d.getBasePackage());
        model.putAll(archetypes);

        return model;
    }

    public Map<String, String> toMustacheTokens(ProjectDescriptor d) {
        var tokens = new HashMap<String, String>();
        String packagePath = d.getBasePackage().replace('.', '/');
        tokens.put("applicationName", d.getApplicationName());
        tokens.put("basePackage", d.getBasePackage());
        tokens.put("basePackagePath", "src/main/java/" + packagePath);
        tokens.put("testBasePackagePath", "src/test/java/" + packagePath);
        tokens.put("integrationTestBasePackagePath", "src/integrationTest/java/" + packagePath);
        return tokens;
    }
}
