package mmm.coffee.metacode.engine;

import java.time.Year;
import java.util.HashMap;
import java.util.Map;
import mmm.coffee.metacode.core.archetype.ArchetypeModel;
import mmm.coffee.metacode.core.archetype.PackageLayout;
import mmm.coffee.metacode.core.descriptor.EndpointDescriptor;
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
        model.put("appModule", d.getAppModule());
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

    public Map<String, Object> toEndpointFtlModel(EndpointDescriptor d) {
        String lower = d.getEntityName().toLowerCase();
        String base = d.getBasePackage();

        var model = new HashMap<String, Object>();
        model.put("basePackage", base);
        model.put("basePackagePath", base.replace('.', '/'));
        model.put("appModule", d.getAppModule());
        model.put("flavor", d.getFlavor());
        model.put("features", d.getFeatures());
        model.put("javaVersion", d.getJavaVersion());
        model.put("YEAR", Year.now().getValue());
        model.put("endpoint", new EndpointModel(d));

        // Static archetypes from package-layout.yaml
        model.putAll(packageLayout.buildArchetypeModels(base));

        // Entity-specific archetypes (override/supplement the static map)
        String epPkg = base + ".endpoint." + lower;
        String convPkg = epPkg + ".converter";
        model.put("Controller", new ArchetypeModel(epPkg, d.getEntityName() + "Controller"));
        model.put("Routes", new ArchetypeModel(epPkg, d.getEntityName() + "Routes"));
        model.put("EntityResource", new ArchetypeModel(base + ".domain", d.getEntityName() + "Resource"));
        model.put("EntityRequest", new ArchetypeModel(epPkg, d.getEntityName() + "Request"));
        model.put("EntityResponse", new ArchetypeModel(epPkg, d.getEntityName() + "Response"));
        model.put("EntityCommandUseCase", new ArchetypeModel(epPkg, d.getEntityName() + "CommandUseCase"));
        model.put("EntityQueryUseCase", new ArchetypeModel(epPkg, d.getEntityName() + "QueryUseCase"));
        model.put("Entity", new ArchetypeModel(epPkg, d.getEntityName()));
        model.put("Repository", new ArchetypeModel(epPkg, d.getEntityName() + "Repository"));
        model.put("ServiceImpl", new ArchetypeModel(epPkg, d.getEntityName() + "ServiceProvider"));
        model.put("ConcreteDataStoreApi", new ArchetypeModel(epPkg, d.getEntityName() + "DataStore"));
        model.put("PojoToEntityConverter", new ArchetypeModel(convPkg, d.getEntityName() + "PojoToEntityConverter"));
        model.put("EntityToPojoConverter", new ArchetypeModel(convPkg, d.getEntityName() + "ToPojoConverter"));
        model.put("EjbTestFixtures", new ArchetypeModel(epPkg, d.getEntityName() + "Fixtures"));
        model.put("ModelTestFixtures", new ArchetypeModel(epPkg, d.getEntityName() + "ModelFixtures"));
        model.put("EntitySpecification", new ArchetypeModel(epPkg, d.getEntityName() + "Specification"));
        model.put("ServiceApi", new ArchetypeModel(epPkg, d.getEntityName() + "ServiceUseCase"));
        model.put("ConcreteDataStoreImpl", new ArchetypeModel(epPkg, d.getEntityName() + "DataStoreProvider"));
        model.put("TestTableInitializer", new ArchetypeModel(epPkg, d.getEntityName() + "TestTableInitializer"));

        return model;
    }

    public Map<String, String> toEndpointMustacheTokens(EndpointDescriptor d) {
        String lower = d.getEntityName().toLowerCase();
        String packagePath = d.getBasePackage().replace('.', '/');
        String appModule = d.getAppModule();

        var tokens = new HashMap<String, String>();
        tokens.put("basePackage", d.getBasePackage());
        tokens.put("appModule", appModule);
        tokens.put("entityName", d.getEntityName());
        tokens.put("lowerCaseEntityName", lower);
        tokens.put("basePackagePath", appModule + "/src/main/java/" + packagePath);
        tokens.put("testBasePackagePath", appModule + "/src/test/java/" + packagePath);
        tokens.put("integrationTestBasePackagePath", appModule + "/src/integrationTest/java/" + packagePath);
        tokens.put("testFixturesBasePackagePath", appModule + "/src/testFixtures/java/" + packagePath);
        tokens.put("createTableScriptName", "V0002__create-" + lower + "-table.sql");
        return tokens;
    }
}
