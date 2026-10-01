package mmm.coffee.metacode;

import mmm.coffee.metacode.cli.MetaCodeCommand;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.ExitCodeGenerator;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import picocli.CommandLine;

@SpringBootApplication
public class Application implements CommandLineRunner, ExitCodeGenerator {

    private int exitCode;

    @Autowired
    private MetaCodeCommand metaCodeCommand;

    @Autowired
    private CommandLine.IFactory factory;

    @Override
    public void run(String... args) {
        exitCode = new CommandLine(metaCodeCommand, factory).execute(args);
    }

    @Override
    public int getExitCode() {
        return exitCode;
    }

    public static void main(String[] args) {
        System.exit(SpringApplication.exit(SpringApplication.run(Application.class, args)));
    }
}
