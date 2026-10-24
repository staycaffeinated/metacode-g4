package mmm.coffee.metacode.engine;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import org.apache.commons.io.FileUtils;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

class ContentToFileWriterTest {

    private final ContentToFileWriter writer = new ContentToFileWriter();

    @TempDir
    Path tempDir;

    @Test
    void write_shouldCreateFileWithExpectedContent() throws IOException {
        String content = "Hello, world!";

        writer.write(tempDir.toString(), "Output.java", content);

        File written = tempDir.resolve("Output.java").toFile();
        assertThat(written).exists();
        assertThat(FileUtils.readFileToString(written, StandardCharsets.UTF_8)).isEqualTo(content);
    }

    @Test
    void write_shouldCreateIntermediateDirectories() throws IOException {
        String relativePath = "com/example/service/MyService.java";
        String content = "public class MyService {}";

        writer.write(tempDir.toString(), relativePath, content);

        File written = tempDir.resolve(relativePath).toFile();
        assertThat(written).exists();
        assertThat(written.getParentFile()).isDirectory();
    }

    @Test
    void write_shouldPreserveUtf8Content() throws IOException {
        String content = "// Copyright © 2025 – résumé naïve";

        writer.write(tempDir.toString(), "Unicode.java", content);

        File written = tempDir.resolve("Unicode.java").toFile();
        assertThat(FileUtils.readFileToString(written, StandardCharsets.UTF_8)).isEqualTo(content);
    }

    @Test
    void write_shouldOverwriteExistingFile() throws IOException {
        String relativePath = "Overwrite.java";
        writer.write(tempDir.toString(), relativePath, "original content");

        writer.write(tempDir.toString(), relativePath, "updated content");

        File written = tempDir.resolve(relativePath).toFile();
        assertThat(FileUtils.readFileToString(written, StandardCharsets.UTF_8)).isEqualTo("updated content");
    }
}
