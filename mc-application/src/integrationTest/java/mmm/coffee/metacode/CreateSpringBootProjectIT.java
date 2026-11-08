package mmm.coffee.metacode;

import static org.assertj.core.api.Assertions.assertThat;

import java.nio.file.Path;
import mmm.coffee.metacode.cli.MetaCodeCommand;
import mmm.coffee.metacode.engine.ContentWriter;
import mmm.coffee.metacode.engine.NoOpContentToFileWriter;
import mmm.coffee.metacode.infrastructure.profiles.SpringProfiles;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.test.context.ActiveProfiles;
import picocli.CommandLine;

/**
 * Exercises the full "metacode create project java-app" pipeline:
 * catalog loading → template rendering → (no-op) write.
 * No files are written to disk; the NoOpContentToFileWriter swallows all write calls.
 * .metacode is written to a JUnit-managed temp directory and cleaned up automatically.
 */
@SpringBootTest(args = {})
@ActiveProfiles({SpringProfiles.TEST, SpringProfiles.INTEGRATION_TEST})
class CreateSpringBootProjectIT {

    @TestConfiguration
    static class NoOpWriterConfiguration {
        @Bean
        @Primary
        ContentWriter noOpContentWriter() {
            return new NoOpContentToFileWriter();
        }
    }

    @Autowired
    MetaCodeCommand metaCodeCommand;

    @Autowired
    CommandLine.IFactory factory;

    @Test
    void createSpringBootProject_loadsAndRendersAllTemplates(@TempDir Path tempDir) {
        int exitCode = new CommandLine(metaCodeCommand, factory)
                .execute(
                        "create",
                        "project",
                        "spring-boot",
                        "--application-name",
                        "MyApp",
                        "--package",
                        "com.example.myapp",
                        "--directory",
                        tempDir.toString());

        assertThat(exitCode).isZero();
    }
}
