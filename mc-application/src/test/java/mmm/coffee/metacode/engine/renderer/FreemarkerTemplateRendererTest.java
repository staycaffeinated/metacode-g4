package mmm.coffee.metacode.engine.renderer;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import freemarker.cache.FileTemplateLoader;
import freemarker.template.Configuration;
import freemarker.template.TemplateExceptionHandler;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

class FreemarkerTemplateRendererTest {

    @TempDir
    Path tempDir;

    private FreemarkerTemplateRenderer renderer;

    @BeforeEach
    void setUp() throws IOException {
        Configuration cfg = new Configuration(Configuration.VERSION_2_3_34);
        cfg.setTemplateLoader(new FileTemplateLoader(tempDir.toFile()));
        cfg.setDefaultEncoding("UTF-8");
        cfg.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);
        cfg.setLogTemplateExceptions(false);
        cfg.setWrapUncheckedExceptions(true);
        renderer = new FreemarkerTemplateRenderer(cfg);
    }

    @Test
    void render_shouldSubstituteModelVariables() throws IOException {
        writeTemplate("greeting.ftl", "Hello, ${name}!");
        String result = renderer.render("greeting.ftl", Map.of("name", "World"));
        assertThat(result).isEqualTo("Hello, World!");
    }

    @Test
    void render_shouldHandleMultipleVariables() throws IOException {
        writeTemplate("class.ftl", "package ${packageName};\n\npublic class ${className} {}");
        String result = renderer.render("class.ftl", Map.of("packageName", "com.example", "className", "MyService"));
        assertThat(result).isEqualTo("package com.example;\n\npublic class MyService {}");
    }

    @Test
    void render_shouldHandleStaticTemplateWithNoVariables() throws IOException {
        writeTemplate("static.ftl", "// generated file");
        String result = renderer.render("static.ftl", Map.of());
        assertThat(result).isEqualTo("// generated file");
    }

    @Test
    void render_shouldHandleTemplateInSubdirectory() throws IOException {
        Path subDir = tempDir.resolve("spring/templates");
        Files.createDirectories(subDir);
        Files.writeString(
                subDir.resolve("bean.ftl"), "@Component\npublic class ${className} {}", StandardCharsets.UTF_8);
        String result = renderer.render("spring/templates/bean.ftl", Map.of("className", "FooBean"));
        assertThat(result).isEqualTo("@Component\npublic class FooBean {}");
    }

    @Test
    void render_shouldThrowTemplateRenderException_whenTemplateNotFound() {
        assertThatThrownBy(() -> renderer.render("nonexistent.ftl", Map.of()))
                .isInstanceOf(TemplateRenderException.class)
                .hasMessageContaining("nonexistent.ftl");
    }

    @Test
    void render_shouldThrowTemplateRenderException_whenModelVariableMissing() throws IOException {
        writeTemplate("missing-var.ftl", "${undeclaredVariable}");
        assertThatThrownBy(() -> renderer.render("missing-var.ftl", Map.of()))
                .isInstanceOf(TemplateRenderException.class);
    }

    @Test
    void render_shouldUseDefaultConfiguration() {
        FreemarkerTemplateRenderer defaultRenderer = new FreemarkerTemplateRenderer();
        String result = defaultRenderer.render("common/Copyright.ftl", Map.of("YEAR", "2024"));
        assertThat(result).isNotNull().contains("2024");
    }

    private void writeTemplate(String name, String content) throws IOException {
        Files.writeString(tempDir.resolve(name), content, StandardCharsets.UTF_8);
    }
}
