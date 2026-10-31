package mmm.coffee.metacode.cli;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import mmm.coffee.metacode.core.descriptor.Flavor;
import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import mmm.coffee.metacode.core.generator.ICodeGenerator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import picocli.CommandLine;

@SuppressWarnings("unchecked")
class SubcommandCreateJavaAppProjectTest {

    private ICodeGenerator<ProjectDescriptor> mockGenerator;
    private SubcommandCreateJavaAppProject subcommand;

    @BeforeEach
    void setUp() {
        mockGenerator = mock(ICodeGenerator.class);
        when(mockGenerator.doPreprocessing(any())).thenReturn(mockGenerator);
        when(mockGenerator.generateCode(any())).thenReturn(0);
        subcommand = new SubcommandCreateJavaAppProject(mockGenerator);
    }

    @Test
    void run_setsJavaAppFlavor() {
        new CommandLine(subcommand).execute("--application-name", "MyApp", "--package", "com.example");

        ArgumentCaptor<ProjectDescriptor> captor = ArgumentCaptor.forClass(ProjectDescriptor.class);
        verify(mockGenerator).doPreprocessing(captor.capture());
        assertThat(captor.getValue().getFlavor()).isEqualTo(Flavor.JAVA_APP);
    }
}
