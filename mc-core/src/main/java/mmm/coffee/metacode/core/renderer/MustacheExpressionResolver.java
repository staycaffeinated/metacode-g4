package mmm.coffee.metacode.core.renderer;

import com.samskivert.mustache.Mustache;
import com.samskivert.mustache.MustacheException;
import com.samskivert.mustache.Template;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;

/**
 * Resolves {@code {{token}}} expressions in catalog entry destination paths.
 * Thread-safe; compiled templates are cached.
 */
@Slf4j
public class MustacheExpressionResolver {

    private static final ConcurrentHashMap<String, Template> CACHE = new ConcurrentHashMap<>();

    private MustacheExpressionResolver() {}

    /**
     * Resolves {@code expression} against {@code values}.
     * Example: {@code resolve("{{basePackagePath}}/api", Map.of("basePackagePath", "org/example"))}
     * returns {@code "org/example/api"}.
     */
    public static String resolve(@NonNull String expression, Map<String, String> values) {
        try {
            Template template = CACHE.computeIfAbsent(
                    expression, expr -> Mustache.compiler().compile(expr));
            return template.execute(values);
        } catch (MustacheException e) {
            String msg = String.format("Could not resolve expression '%s': %s", expression, e.getMessage());
            log.warn(msg, e);
            throw new MustacheException(msg, e);
        }
    }
}
