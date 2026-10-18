import static org.assertj.core.api.Assertions.assertThat;

import mmm.coffee.metacode.core.archetype.ArchetypeModel;
import org.junit.jupiter.api.Test;

public class ArchetypeModelTest {

    private final ArchetypeModel model = new ArchetypeModel("org.acme.tools", "HelloWorld");

    @Test
    void shouldReturnPackageName() {
        assertThat(model.packageName()).isEqualTo("org.acme.tools");
    }

    @Test
    void shouldReturnClassname() {
        assertThat(model.className()).isEqualTo("HelloWorld");
    }

    @Test
    void shouldReturnFqcn() {
        assertThat(model.fqcn()).isEqualTo("org.acme.tools.HelloWorld");
    }

    @Test
    void shouldReturnTestClassName() {
        assertThat(model.testClass()).isEqualTo("HelloWorldTest");
    }

    @Test
    void shouldReturnIntegrationTestClassName() {
        assertThat(model.integrationTestClass()).isEqualTo("HelloWorldIT");
    }

    @Test
    void shouldReturnVarName() {
        assertThat(model.varName()).isEqualTo("helloWorld");
    }
}
