package mmm.coffee.metacode.cli;

import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import mmm.coffee.metacode.core.generator.ICodeGenerator;
import org.springframework.stereotype.Component;
import picocli.CommandLine;

@Component
@CommandLine.Command(
        name = "spring-boot",
        description = "Generate a plain Spring Boot project (no web framework)",
        mixinStandardHelpOptions = true)
public class SubcommandCreateSpringBootProject extends AbstractCreateProject {

    private final ICodeGenerator<ProjectDescriptor> codeGenerator;

    public SubcommandCreateSpringBootProject(ICodeGenerator<ProjectDescriptor> codeGenerator) {
        this.codeGenerator = codeGenerator;
    }

    @Override
    public void run() {
        ProjectDescriptor descriptor = ProjectDescriptor.builder()
                .applicationName(applicationName)
                .basePackage(basePackage)
                .baseDirectory(baseDirectory)
                .basePath(basePath)
                .flavor("springboot")
                .features(activeFeatures())
                .javaVersion(javaVersion)
                .build();

        codeGenerator.doPreprocessing(descriptor).generateCode(descriptor);
    }
}
