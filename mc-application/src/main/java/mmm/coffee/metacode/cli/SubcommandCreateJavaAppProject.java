package mmm.coffee.metacode.cli;

import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import mmm.coffee.metacode.core.generator.ICodeGenerator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import picocli.CommandLine;

@Component
@CommandLine.Command(
        name = "java-app",
        description = "Generate a plain Java application project",
        mixinStandardHelpOptions = true)
public class SubcommandCreateJavaAppProject extends AbstractCreateProject {

    @Autowired
    private ICodeGenerator<ProjectDescriptor> codeGenerator;

    @Override
    public void run() {
        ProjectDescriptor descriptor = ProjectDescriptor.builder()
                .applicationName(applicationName)
                .basePackage(basePackage)
                .baseDirectory(baseDirectory)
                .basePath(basePath)
                .flavor("javaapp")
                .features(activeFeatures())
                .javaVersion(javaVersion)
                .build();

        codeGenerator.doPreprocessing(descriptor).generateCode(descriptor);
    }
}
