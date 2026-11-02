package mmm.coffee.metacode.cli;

import mmm.coffee.metacode.core.descriptor.Flavor;
import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import mmm.coffee.metacode.core.generator.ICodeGenerator;
import org.springframework.stereotype.Component;
import picocli.CommandLine;

@Component
@CommandLine.Command(
        name = "spring-batch",
        description = "Generate a Spring Batch project",
        mixinStandardHelpOptions = true)
public class SubcommandCreateSpringBatchProject extends AbstractCreateProject {

    private final ICodeGenerator<ProjectDescriptor> codeGenerator;

    public SubcommandCreateSpringBatchProject(ICodeGenerator<ProjectDescriptor> codeGenerator) {
        this.codeGenerator = codeGenerator;
    }

    @Override
    public void run() {
        ProjectDescriptor descriptor = ProjectDescriptor.builder()
                .applicationName(applicationName)
                .basePackage(basePackage)
                .baseDirectory(baseDirectory)
                .basePath(basePath)
                .flavor(Flavor.SPRING_BATCH)
                .features(activeFeatures())
                .javaVersion(javaVersion)
                .schema(schema)
                .architecture(selectedArchitecture())
                .build();

        codeGenerator.doPreprocessing(descriptor).generateCode(descriptor);
    }
}
