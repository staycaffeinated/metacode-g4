package mmm.coffee.metacode.engine;

import java.time.Year;
import java.time.ZoneId;
import java.util.HashMap;
import java.util.Map;
import mmm.coffee.metacode.core.archetype.PackageLayout;
import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import org.springframework.stereotype.Component;

@Component
@SuppressWarnings({"java:S1192" // allow duplicate string constants
})
public class ProjectTemplateModelConverter {

    private final PackageLayout packageLayout;

    public ProjectTemplateModelConverter(PackageLayout packageLayout) {
        this.packageLayout = packageLayout;
    }

    public Map<String, Object> toFtlModel(ProjectDescriptor d) {
        var model = new HashMap<String, Object>();
        model.put("applicationName", d.getApplicationName());
        model.put("basePackage", d.getBasePackage());
        model.put("basePackagePath", d.getBasePackage().replace('.', '/'));
        model.put("appModule", d.getAppModule());
        model.put("flavor", d.getFlavor() != null ? d.getFlavor().id() : "");
        model.put("features", d.getFeatures());
        model.put("javaVersion", d.getJavaVersion());
        model.put("YEAR", Year.now(ZoneId.systemDefault()).getValue());
        model.put("project", new ProjectModel(d));

        model.putAll(packageLayout.buildArchetypeModels(d.getBasePackage()));

        return model;
    }

    public Map<String, String> toMustacheTokens(ProjectDescriptor d) {
        var tokens = new HashMap<String, String>();
        String packagePath = d.getBasePackage().replace('.', '/');
        String appModule = d.getAppModule();
        tokens.put("applicationName", d.getApplicationName());
        tokens.put("basePackage", d.getBasePackage());
        tokens.put("appModule", appModule);
        tokens.put("basePackagePath", appModule + "/src/main/java/" + packagePath);
        tokens.put("testBasePackagePath", appModule + "/src/test/java/" + packagePath);
        tokens.put("integrationTestBasePackagePath", appModule + "/src/integrationTest/java/" + packagePath);
        tokens.put("testFixturesBasePackagePath", appModule + "/src/testFixtures/java/" + packagePath);
        return tokens;
    }
}
