package mmm.coffee.metacode.cli;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Properties;
import java.util.Set;
import mmm.coffee.metacode.core.descriptor.EndpointDescriptor;
import mmm.coffee.metacode.core.exceptions.MetacodeException;
import mmm.coffee.metacode.engine.EndpointCodeGenerationEngine;
import org.springframework.stereotype.Component;
import picocli.CommandLine;

@Component
@CommandLine.Command(
        name = "endpoint",
        description = "Generate a REST endpoint for an existing project",
        mixinStandardHelpOptions = true)
public class SubcommandCreateEndpoint implements Runnable {

    @CommandLine.Option(
            names = {"-e", "--resource"},
            required = true,
            description = "The resource (entity) name (e.g. Book)")
    private String resource;

    @CommandLine.Option(
            names = {"-r", "--route"},
            required = true,
            description = "The base route for this resource (e.g. /books)")
    private String route;

    @CommandLine.Option(
            names = {"-d", "--directory"},
            description = "Project directory containing metacode.properties (default: current directory)",
            defaultValue = ".")
    private String directory;

    private final EndpointCodeGenerationEngine codeGenerator;

    public SubcommandCreateEndpoint(EndpointCodeGenerationEngine codeGenerator) {
        this.codeGenerator = codeGenerator;
    }

    @Override
    public void run() {
        Properties props = readMetaProperties(directory);

        String flavor = props.getProperty("framework", "");
        String pkg = props.getProperty("basePackage", "");
        String basePath = props.getProperty("basePath", "/");
        String appModule = props.getProperty("appModule", "application");
        String java = props.getProperty("javaVersion", "21");
        Set<String> features = parseFeatures(props.getProperty("features", ""));

        EndpointDescriptor descriptor = EndpointDescriptor.builder()
                .entityName(capitalize(resource))
                .route(route)
                .flavor(flavor)
                .basePackage(pkg)
                .basePath(basePath)
                .baseDirectory(directory)
                .appModule(appModule)
                .javaVersion(java)
                .features(features)
                .build();

        codeGenerator.doPreprocessing(descriptor).generateCode(descriptor);
    }

    private Properties readMetaProperties(String dir) {
        File file = new File(dir, "metacode.properties");
        if (!file.exists()) {
            throw new CommandLine.ExecutionException(
                    new CommandLine(this),
                    "metacode.properties not found in " + new File(dir).getAbsolutePath()
                            + ". Run 'metacode create project' first.");
        }
        Properties props = new Properties();
        try (FileReader fr = new FileReader(file)) {
            props.load(fr);
        } catch (IOException e) {
            throw new MetacodeException("Failed to read metacode.properties: " + e.getMessage(), e);
        }
        return props;
    }

    private Set<String> parseFeatures(String csv) {
        Set<String> result = new HashSet<>();
        if (csv != null && !csv.isBlank()) {
            Arrays.stream(csv.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .forEach(result::add);
        }
        return result;
    }

    private String capitalize(String s) {
        if (s == null || s.isEmpty()) return s;
        return Character.toUpperCase(s.charAt(0)) + s.substring(1);
    }
}
