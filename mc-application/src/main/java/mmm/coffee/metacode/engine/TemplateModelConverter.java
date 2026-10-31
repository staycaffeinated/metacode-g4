package mmm.coffee.metacode.engine;

import java.time.Year;
import java.time.ZoneId;
import java.util.HashMap;
import java.util.Map;
import mmm.coffee.metacode.core.archetype.ArchetypeModel;
import mmm.coffee.metacode.core.archetype.PackageLayout;
import mmm.coffee.metacode.core.descriptor.EndpointDescriptor;
import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import org.springframework.stereotype.Component;

@Component
@SuppressWarnings({"java:S1192" // allow duplicate string constants
})
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
        model.put("flavor", d.getFlavor() != null ? d.getFlavor().id() : "");
        model.put("features", d.getFeatures());
        model.put("javaVersion", d.getJavaVersion());
        model.put("YEAR", Year.now(ZoneId.systemDefault()).getValue());
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
        model.put("flavor", d.getFlavor() != null ? d.getFlavor().id() : "");
        model.put("features", d.getFeatures());
        model.put("javaVersion", d.getJavaVersion());
        model.put("YEAR", Year.now(ZoneId.systemDefault()).getValue());
        model.put("endpoint", new EndpointModel(d));

        // Static archetypes from package-layout.yaml
        model.putAll(packageLayout.buildArchetypeModels(base));

        // Entity-specific archetypes (override/supplement the static map)
        String webPkg = base + ".adapter.inbound.web." + lower;
        String persistPkg = base + ".adapter.outbound.persistence." + lower;
        String convPkg = persistPkg + ".converter";
        String inboundPkg = base + ".application.port.inbound." + lower;
        String outboundPkg = base + ".application.port.outbound." + lower;
        String svcPkg = base + ".application.service";
        // adapter.inbound.web
        model.put("Controller", new ArchetypeModel(webPkg, d.getEntityName() + "Controller"));
        model.put("Routes", new ArchetypeModel(webPkg, d.getEntityName() + "Routes"));
        model.put("EntityRequest", new ArchetypeModel(webPkg, d.getEntityName() + "Request"));
        model.put("EntityResponse", new ArchetypeModel(webPkg, d.getEntityName() + "Response"));
        // domain
        model.put("EntityResource", new ArchetypeModel(base + ".domain", d.getEntityName()));
        // application.port.inbound
        model.put("EntityCommandUseCase", new ArchetypeModel(inboundPkg, d.getEntityName() + "CommandUseCase"));
        model.put("EntityQueryUseCase", new ArchetypeModel(inboundPkg, d.getEntityName() + "QueryUseCase"));
        model.put("ServiceApi", new ArchetypeModel(inboundPkg, d.getEntityName() + "ServiceUseCase"));
        // application.port.outbound
        model.put("ConcreteDataStoreApi", new ArchetypeModel(outboundPkg, d.getEntityName() + "DataStore"));
        // application.service
        model.put("ServiceImpl", new ArchetypeModel(svcPkg, d.getEntityName() + "Service"));
        // adapter.outbound.persistence
        model.put("Entity", new ArchetypeModel(persistPkg, d.getEntityName() + "Entity"));
        model.put("Repository", new ArchetypeModel(persistPkg, d.getEntityName() + "Repository"));
        model.put(
                "EntitySpecification",
                new ArchetypeModel(persistPkg + ".predicate", d.getEntityName() + "Specification"));
        model.put("ConcreteDataStoreImpl", new ArchetypeModel(persistPkg, d.getEntityName() + "DataStoreProvider"));
        model.put("PojoToEntityConverter", new ArchetypeModel(convPkg, d.getEntityName() + "PojoToEntityConverter"));
        model.put("EntityToPojoConverter", new ArchetypeModel(convPkg, d.getEntityName() + "ToPojoConverter"));
        // test fixtures
        model.put("EjbTestFixtures", new ArchetypeModel(persistPkg, d.getEntityName() + "Fixtures"));
        model.put("ModelTestFixtures", new ArchetypeModel(webPkg, d.getEntityName() + "ModelFixtures"));
        model.put("TestTableInitializer", new ArchetypeModel(persistPkg, d.getEntityName() + "TestTableInitializer"));

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
