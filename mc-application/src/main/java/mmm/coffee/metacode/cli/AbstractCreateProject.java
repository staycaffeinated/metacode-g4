package mmm.coffee.metacode.cli;

import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;
import mmm.coffee.metacode.core.descriptor.Feature;
import picocli.CommandLine;

public abstract class AbstractCreateProject implements Runnable {

    @CommandLine.Option(
            names = {"-p", "--package"},
            required = true,
            description = "Base package name (e.g. com.example.demo)")
    protected String basePackage;

    @CommandLine.Option(
            names = {"-n", "--application-name"},
            required = true,
            description = "Application name (e.g. DemoApplication)")
    protected String applicationName;

    @CommandLine.Option(
            names = {"-d", "--directory"},
            description = "Output directory (default: current directory)",
            defaultValue = ".")
    protected String baseDirectory;

    @CommandLine.Option(
            names = {"-r", "--route", "--base-path"},
            description = "The base path (URL) of this application (e.g. /petstore)",
            defaultValue = "/")
    protected String basePath;

    @CommandLine.Option(
            names = {"--schema"},
            description = "PostgreSQL schema name (default: public)",
            defaultValue = "public")
    protected String schema;

    @CommandLine.Option(
            names = {"--add"},
            description = "Features: postgres, liquibase, flyway, openapi, testcontainers, mongodb, kafka",
            arity = "1..*",
            split = ",")
    protected String[] features = new String[0];

    @CommandLine.Option(
            names = {"--java"},
            description = "Java version (default: 21)",
            defaultValue = "21")
    protected String javaVersion;

    protected Set<Feature> activeFeatures() {
        if (features == null || features.length == 0) return Set.of();
        return Arrays.stream(features).map(Feature::fromId).collect(Collectors.toUnmodifiableSet());
    }
}
