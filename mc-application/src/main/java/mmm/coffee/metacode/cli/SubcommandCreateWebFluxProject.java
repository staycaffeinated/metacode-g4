package mmm.coffee.metacode.cli;

import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import mmm.coffee.metacode.core.generator.ICodeGenerator;
import org.springframework.stereotype.Component;
import picocli.CommandLine;

@Component
@CommandLine.Command(
        name = "spring-webflux",
        description = "Generate a Spring WebFlux project",
        mixinStandardHelpOptions = true)
public class SubcommandCreateWebFluxProject extends AbstractCreateProject {

    private final ICodeGenerator<ProjectDescriptor> codeGenerator;

    public SubcommandCreateWebFluxProject(ICodeGenerator<ProjectDescriptor> codeGenerator) {
        this.codeGenerator = codeGenerator;
    }

    @Override
    public void run() {
        ProjectDescriptor descriptor = ProjectDescriptor.builder()
                .applicationName(applicationName)
                .basePackage(basePackage)
                .baseDirectory(baseDirectory)
                .basePath(basePath)
                .flavor("webflux")
                .features(activeFeatures())
                .javaVersion(javaVersion)
                .build();

        codeGenerator.doPreprocessing(descriptor).generateCode(descriptor);
    }
}
