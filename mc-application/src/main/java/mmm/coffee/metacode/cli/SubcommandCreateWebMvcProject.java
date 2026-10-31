package mmm.coffee.metacode.cli;

import mmm.coffee.metacode.core.descriptor.Flavor;
import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import mmm.coffee.metacode.core.generator.ICodeGenerator;
import org.springframework.stereotype.Component;
import picocli.CommandLine;

@Component
@CommandLine.Command(
        name = "spring-webmvc",
        description = "Generate a Spring WebMVC project",
        mixinStandardHelpOptions = true)
public class SubcommandCreateWebMvcProject extends AbstractCreateProject {

    private final ICodeGenerator<ProjectDescriptor> codeGenerator;

    public SubcommandCreateWebMvcProject(ICodeGenerator<ProjectDescriptor> codeGenerator) {
        this.codeGenerator = codeGenerator;
    }

    @Override
    public void run() {
        ProjectDescriptor descriptor = ProjectDescriptor.builder()
                .applicationName(applicationName)
                .basePackage(basePackage)
                .baseDirectory(baseDirectory)
                .basePath(basePath)
                .flavor(Flavor.WEBMVC)
                .features(activeFeatures())
                .javaVersion(javaVersion)
                .schema(schema)
                .build();

        codeGenerator.doPreprocessing(descriptor).generateCode(descriptor);
    }
}
