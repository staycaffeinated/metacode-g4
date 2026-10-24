package mmm.coffee.metacode.core.archetype;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.NullAndEmptySource;

class ArchetypeModelTest {

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

    @Nested
    class VarNameUseCases {

        @Test
        void shouldReturnVarName() {
            assertThat(model.varName()).isEqualTo("helloWorld");
        }

        @ParameterizedTest
        @NullAndEmptySource
        void shouldReturnDefaultVarNameForEmptyClassName(String className) {
            ArchetypeModel archetypeModel = new ArchetypeModel("org.acme.tools", className);
            assertThat(archetypeModel.varName()).isEqualTo("obj");
        }
    }
}
