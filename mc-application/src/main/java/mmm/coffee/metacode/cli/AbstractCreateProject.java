package mmm.coffee.metacode.cli;

import java.util.Set;
import picocli.CommandLine;

public abstract class AbstractCreateProject implements Runnable {

    @CommandLine.Option(
            names = {"-p", "--package"},
            required = true,
            description = "Base package name (e.g. com.example.demo)")
    protected String basePackage;

    @CommandLine.Option(
            names = {"-a", "--application-name"},
            required = true,
            description = "Application name (e.g. DemoApplication)")
    protected String applicationName;

    @CommandLine.Option(
            names = {"-d", "--directory"},
            description = "Output directory (default: current directory)",
            defaultValue = ".")
    protected String baseDirectory;

    @CommandLine.Option(
            names = {"--add"},
            description = "Features: postgres, liquibase, flyway, openapi, testcontainers",
            split = ",")
    protected String[] features = new String[0];

    @CommandLine.Option(
            names = {"--java"},
            description = "Java version (default: 21)",
            defaultValue = "21")
    protected String javaVersion;

    protected Set<String> activeFeatures() {
        return features == null || features.length == 0 ? Set.of() : Set.of(features);
    }
}
