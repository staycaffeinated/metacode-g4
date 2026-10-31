package mmm.coffee.metacode.cli;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Path;
import java.util.Properties;
import mmm.coffee.metacode.core.descriptor.EndpointDescriptor;
import mmm.coffee.metacode.core.descriptor.Feature;
import mmm.coffee.metacode.core.descriptor.Flavor;
import mmm.coffee.metacode.core.generator.ICodeGenerator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.mockito.ArgumentCaptor;
import picocli.CommandLine;

@SuppressWarnings("unchecked")
class SubcommandCreateEndpointTest {

    @TempDir
    Path tempDir;

    private ICodeGenerator<EndpointDescriptor> mockGenerator;
    private SubcommandCreateEndpoint subcommand;

    @BeforeEach
    void setUp() {
        mockGenerator = mock(ICodeGenerator.class);
        when(mockGenerator.doPreprocessing(any())).thenReturn(mockGenerator);
        when(mockGenerator.generateCode(any())).thenReturn(0);
        subcommand = new SubcommandCreateEndpoint(mockGenerator);
    }

    @Test
    void run_buildsDescriptorFromPropertiesFile() throws IOException {
        writeProperties("webmvc", "com.example", "/api/v1", "application", "21", "");

        execute("--resource", "Book", "--route", "/books");

        EndpointDescriptor d = capturedDescriptor();
        assertThat(d.getEntityName()).isEqualTo("Book");
        assertThat(d.getRoute()).isEqualTo("/books");
        assertThat(d.getFlavor()).isEqualTo(Flavor.WEBMVC);
        assertThat(d.getBasePackage()).isEqualTo("com.example");
        assertThat(d.getBasePath()).isEqualTo("/api/v1");
        assertThat(d.getAppModule()).isEqualTo("application");
        assertThat(d.getJavaVersion()).isEqualTo("21");
    }

    @Test
    void run_capitalizesResourceName() throws IOException {
        writeProperties("webmvc", "com.example", "/", "application", "21", "");

        execute("--resource", "book", "--route", "/books");

        assertThat(capturedDescriptor().getEntityName()).isEqualTo("Book");
    }

    @Test
    void run_parsesFeaturesFromPropertiesFile() throws IOException {
        writeProperties("webflux", "com.example", "/", "application", "21", "postgres,openapi");

        execute("--resource", "Pet", "--route", "/pets");

        assertThat(capturedDescriptor().getFeatures()).containsExactlyInAnyOrder(Feature.POSTGRES, Feature.OPENAPI);
    }

    @Test
    void run_emptyFeaturesProducesEmptySet() throws IOException {
        writeProperties("webmvc", "com.example", "/", "application", "21", "");

        execute("--resource", "Pet", "--route", "/pets");

        assertThat(capturedDescriptor().getFeatures()).isEmpty();
    }

    @Test
    void run_returnsNonZeroWhenPropertiesFileMissing() {
        int exitCode = new CommandLine(subcommand)
                .execute("--resource", "Book", "--route", "/books", "--directory", tempDir.toString());
        assertThat(exitCode).isNotZero();
    }

    // ── helpers ──────────────────────────────────────────────────────────────

    private void writeProperties(
            String framework, String pkg, String basePath, String appModule, String javaVersion, String features)
            throws IOException {
        Properties props = new Properties();
        props.setProperty("framework", framework);
        props.setProperty("basePackage", pkg);
        props.setProperty("basePath", basePath);
        props.setProperty("appModule", appModule);
        props.setProperty("javaVersion", javaVersion);
        props.setProperty("features", features);
        try (FileWriter fw =
                new FileWriter(tempDir.resolve("metacode.properties").toFile())) {
            props.store(fw, null);
        }
    }

    private void execute(String... args) {
        String[] fullArgs = new String[args.length + 2];
        fullArgs[0] = "--directory";
        fullArgs[1] = tempDir.toString();
        System.arraycopy(args, 0, fullArgs, 2, args.length);
        new CommandLine(subcommand).execute(fullArgs);
    }

    private EndpointDescriptor capturedDescriptor() {
        ArgumentCaptor<EndpointDescriptor> captor = ArgumentCaptor.forClass(EndpointDescriptor.class);
        verify(mockGenerator).doPreprocessing(captor.capture());
        return captor.getValue();
    }
}
