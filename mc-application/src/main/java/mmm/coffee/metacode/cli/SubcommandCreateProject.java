package mmm.coffee.metacode.cli;

import org.springframework.stereotype.Component;
import picocli.CommandLine;

@Component
@CommandLine.Command(
        name = "project",
        subcommands = {
            SubcommandCreateWebMvcProject.class,
            SubcommandCreateWebFluxProject.class,
            SubcommandCreateSpringBootProject.class,
            SubcommandCreateSpringBatchProject.class,
            SubcommandCreateJavaAppProject.class,
            CommandLine.HelpCommand.class
        },
        mixinStandardHelpOptions = true,
        description = "Create a new project")
@SuppressWarnings({"java:S106" // send output to stdout
})
public class SubcommandCreateProject implements Runnable {

    @Override
    public void run() {
        CommandLine.usage(this, System.out);
    }
}
