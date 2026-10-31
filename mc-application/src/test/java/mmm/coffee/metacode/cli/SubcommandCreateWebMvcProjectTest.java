package mmm.coffee.metacode.cli;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import mmm.coffee.metacode.core.descriptor.Feature;
import mmm.coffee.metacode.core.descriptor.Flavor;
import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import mmm.coffee.metacode.core.generator.ICodeGenerator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import picocli.CommandLine;

@SuppressWarnings("unchecked")
class SubcommandCreateWebMvcProjectTest {

    private ICodeGenerator<ProjectDescriptor> mockGenerator;
    private SubcommandCreateWebMvcProject subcommand;

    @BeforeEach
    void setUp() {
        mockGenerator = mock(ICodeGenerator.class);
        when(mockGenerator.doPreprocessing(any())).thenReturn(mockGenerator);
        when(mockGenerator.generateCode(any())).thenReturn(0);
        subcommand = new SubcommandCreateWebMvcProject(mockGenerator);
    }

    @Test
    void run_setsWebMvcFlavor() {
        execute("--application-name", "MyApp", "--package", "com.example");

        assertThat(capturedDescriptor().getFlavor()).isEqualTo(Flavor.WEBMVC);
    }

    @Test
    void run_passesCliArgsToDescriptor() {
        execute(
                "--application-name", "MyApp",
                "--package", "com.example",
                "--route", "/api/v1",
                "--directory", "/tmp/out",
                "--java", "21");

        ProjectDescriptor d = capturedDescriptor();
        assertThat(d.getApplicationName()).isEqualTo("MyApp");
        assertThat(d.getBasePackage()).isEqualTo("com.example");
        assertThat(d.getBasePath()).isEqualTo("/api/v1");
        assertThat(d.getBaseDirectory()).isEqualTo("/tmp/out");
        assertThat(d.getJavaVersion()).isEqualTo("21");
    }

    @Test
    void run_defaultBasePathIsSlash() {
        execute("--application-name", "MyApp", "--package", "com.example");

        assertThat(capturedDescriptor().getBasePath()).isEqualTo("/");
    }

    @Test
    void run_defaultJavaVersionIs21() {
        execute("--application-name", "MyApp", "--package", "com.example");

        assertThat(capturedDescriptor().getJavaVersion()).isEqualTo("21");
    }

    @Test
    void run_parsesFeatures() {
        execute("--application-name", "MyApp", "--package", "com.example", "--add", "postgres,openapi");

        assertThat(capturedDescriptor().getFeatures()).containsExactlyInAnyOrder(Feature.POSTGRES, Feature.OPENAPI);
    }

    @Test
    void run_noFeaturesProducesEmptySet() {
        execute("--application-name", "MyApp", "--package", "com.example");

        assertThat(capturedDescriptor().getFeatures()).isEmpty();
    }

    @Test
    void run_rejectsUnknownFeature() {
        int exitCode = new CommandLine(subcommand)
                .execute("--application-name", "MyApp", "--package", "com.example", "--add", "unknown");
        assertThat(exitCode).isNotZero();
    }

    @Test
    void run_callsDoPreprocessingThenGenerateCode() {
        execute("--application-name", "MyApp", "--package", "com.example");

        ArgumentCaptor<ProjectDescriptor> captor = ArgumentCaptor.forClass(ProjectDescriptor.class);
        verify(mockGenerator).doPreprocessing(captor.capture());
        verify(mockGenerator).generateCode(captor.getValue());
    }

    // ── helpers ──────────────────────────────────────────────────────────────

    private void execute(String... args) {
        new CommandLine(subcommand).execute(args);
    }

    private ProjectDescriptor capturedDescriptor() {
        ArgumentCaptor<ProjectDescriptor> captor = ArgumentCaptor.forClass(ProjectDescriptor.class);
        verify(mockGenerator).doPreprocessing(captor.capture());
        return captor.getValue();
    }
}
