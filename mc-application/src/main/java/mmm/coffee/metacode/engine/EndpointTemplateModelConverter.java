package mmm.coffee.metacode.engine;

import java.time.Year;
import java.time.ZoneId;
import java.util.HashMap;
import java.util.Map;
import mmm.coffee.metacode.core.archetype.ArchetypeModel;
import mmm.coffee.metacode.core.archetype.PackageLayout;
import mmm.coffee.metacode.core.descriptor.Architecture;
import mmm.coffee.metacode.core.descriptor.EndpointDescriptor;
import org.springframework.stereotype.Component;

@Component
@SuppressWarnings({"java:S1192" // allow duplicate string constants
})
public class EndpointTemplateModelConverter {

    public Map<String, Object> toFtlModel(EndpointDescriptor d) {
        String lower = d.getEntityName().toLowerCase();
        String base = d.getBasePackage();
        Architecture arch = d.getArchitecture();

        var model = new HashMap<String, Object>();
        model.put("basePackage", base);
        model.put("basePackagePath", base.replace('.', '/'));
        model.put("appModule", d.getAppModule());
        model.put("flavor", d.getFlavor() != null ? d.getFlavor().id() : "");
        model.put("features", d.getFeatures());
        model.put("javaVersion", d.getJavaVersion());
        model.put("YEAR", Year.now(ZoneId.systemDefault()).getValue());
        model.put("endpoint", new EndpointModel(d));

        model.putAll(PackageLayout.load(arch.layoutResource()).buildArchetypeModels(base));

        String webPkg, persistPkg, inboundPkg, outboundPkg, entityPkg, dataStoreClass, dataStoreImplClass;
        if (arch == Architecture.CLEAN) {
            webPkg = base + ".interfaces.rest." + lower;
            persistPkg = base + ".infrastructure.persistence." + lower;
            inboundPkg = base + ".application.usecase." + lower;
            outboundPkg = base + ".application.gateway." + lower;
            entityPkg = base + ".domain.model";
            dataStoreClass = d.getEntityName() + "Gateway";
            dataStoreImplClass = d.getEntityName() + "GatewayProvider";
        } else {
            webPkg = base + ".adapter.inbound.web." + lower;
            persistPkg = base + ".adapter.outbound.persistence." + lower;
            inboundPkg = base + ".application.port.inbound." + lower;
            outboundPkg = base + ".application.port.outbound." + lower;
            entityPkg = base + ".domain";
            dataStoreClass = d.getEntityName() + "DataStore";
            dataStoreImplClass = d.getEntityName() + "DataStoreProvider";
        }
        String convPkg = persistPkg + ".converter";
        String svcPkg = base + ".application.service";

        model.put("Controller", new ArchetypeModel(webPkg, d.getEntityName() + "Controller"));
        model.put("Routes", new ArchetypeModel(webPkg, d.getEntityName() + "Routes"));
        model.put("EntityRequest", new ArchetypeModel(webPkg, d.getEntityName() + "Request"));
        model.put("EntityResponse", new ArchetypeModel(webPkg, d.getEntityName() + "Response"));
        model.put("EntityResource", new ArchetypeModel(entityPkg, d.getEntityName()));
        model.put("EntityCommandUseCase", new ArchetypeModel(inboundPkg, d.getEntityName() + "CommandUseCase"));
        model.put("EntityQueryUseCase", new ArchetypeModel(inboundPkg, d.getEntityName() + "QueryUseCase"));
        model.put("ServiceApi", new ArchetypeModel(inboundPkg, d.getEntityName() + "ServiceUseCase"));
        model.put("ConcreteDataStoreApi", new ArchetypeModel(outboundPkg, dataStoreClass));
        model.put("ServiceImpl", new ArchetypeModel(svcPkg, d.getEntityName() + "Service"));
        model.put("Entity", new ArchetypeModel(persistPkg, d.getEntityName() + "Entity"));
        model.put("Repository", new ArchetypeModel(persistPkg, d.getEntityName() + "Repository"));
        model.put(
                "EntitySpecification",
                new ArchetypeModel(persistPkg + ".predicate", d.getEntityName() + "Specification"));
        model.put("ConcreteDataStoreImpl", new ArchetypeModel(persistPkg, dataStoreImplClass));
        model.put("PojoToEntityConverter", new ArchetypeModel(convPkg, d.getEntityName() + "PojoToEntityConverter"));
        model.put("EntityToPojoConverter", new ArchetypeModel(convPkg, d.getEntityName() + "ToPojoConverter"));
        model.put("EjbTestFixtures", new ArchetypeModel(persistPkg, d.getEntityName() + "Fixtures"));
        model.put("ModelTestFixtures", new ArchetypeModel(webPkg, d.getEntityName() + "ModelFixtures"));
        model.put("TestTableInitializer", new ArchetypeModel(persistPkg, d.getEntityName() + "TestTableInitializer"));

        return model;
    }

    public Map<String, String> toMustacheTokens(EndpointDescriptor d) {
        String lower = d.getEntityName().toLowerCase();
        String packagePath = d.getBasePackage().replace('.', '/');
        String appModule = d.getAppModule();
        Architecture arch = d.getArchitecture();

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

        if (arch == Architecture.CLEAN) {
            tokens.put("webSegment", "interfaces/rest");
            tokens.put("persistSegment", "infrastructure/persistence");
            tokens.put("inboundSegment", "application/usecase");
            tokens.put("outboundSegment", "application/gateway");
            tokens.put("domainSegment", "domain/model");
            tokens.put("dataStoreSuffix", "Gateway");
            tokens.put("dataStoreImplSuffix", "GatewayProvider");
        } else {
            tokens.put("webSegment", "adapter/inbound/web");
            tokens.put("persistSegment", "adapter/outbound/persistence");
            tokens.put("inboundSegment", "application/port/inbound");
            tokens.put("outboundSegment", "application/port/outbound");
            tokens.put("domainSegment", "domain");
            tokens.put("dataStoreSuffix", "DataStore");
            tokens.put("dataStoreImplSuffix", "DataStoreProvider");
        }
        return tokens;
    }
}
