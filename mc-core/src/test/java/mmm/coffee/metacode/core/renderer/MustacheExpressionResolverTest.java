package mmm.coffee.metacode.core.renderer;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.samskivert.mustache.MustacheException;
import java.util.Map;
import org.junit.jupiter.api.Test;

class MustacheExpressionResolverTest {

    @Test
    void resolve_shouldSubstituteTokenWithValue() {
        String result =
                MustacheExpressionResolver.resolve("{{basePackagePath}}/api", Map.of("basePackagePath", "org/example"));

        assertThat(result).isEqualTo("org/example/api");
    }

    @Test
    void resolve_shouldHandleMultipleTokens() {
        String result = MustacheExpressionResolver.resolve(
                "{{basePackagePath}}/{{resourceName}}/{{resourceName}}Controller.java",
                Map.of("basePackagePath", "org/example", "resourceName", "Widget"));

        assertThat(result).isEqualTo("org/example/Widget/WidgetController.java");
    }

    @Test
    void resolve_shouldReturnExpressionUnchanged_whenNoTokensPresent() {
        String result = MustacheExpressionResolver.resolve("src/main/java/Application.java", Map.of());

        assertThat(result).isEqualTo("src/main/java/Application.java");
    }

    @Test
    void resolve_shouldRenderEmptyString_whenTokenValueIsEmpty() {
        String result = MustacheExpressionResolver.resolve("{{prefix}}Service.java", Map.of("prefix", ""));

        assertThat(result).isEqualTo("Service.java");
    }

    @Test
    void resolve_shouldThrow_whenTokenMissingFromMap() {
        // jmustache strict mode: missing key → MustacheException
        assertThatThrownBy(() -> MustacheExpressionResolver.resolve("{{missing}}/path", Map.of()))
                .isInstanceOf(MustacheException.class)
                .hasMessageContaining("missing");
    }

    @Test
    void resolve_shouldHandleExpressionWithNoTokens() {
        String result = MustacheExpressionResolver.resolve("literal-path/Foo.java", Map.of("unused", "x"));

        assertThat(result).isEqualTo("literal-path/Foo.java");
    }

    @Test
    void resolve_shouldThrowOnNullExpression() {
        assertThatThrownBy(() -> MustacheExpressionResolver.resolve(null, Map.of()))
                .isInstanceOf(NullPointerException.class);
    }

    @Test
    void resolve_shouldCacheCompiledTemplate() {
        // Same expression resolved twice — should not throw and should produce consistent output
        String expr = "{{pkg}}/Service.java";
        Map<String, String> values = Map.of("pkg", "com/example");

        String first = MustacheExpressionResolver.resolve(expr, values);
        String second = MustacheExpressionResolver.resolve(expr, values);

        assertThat(first).isEqualTo(second).isEqualTo("com/example/Service.java");
    }
}
