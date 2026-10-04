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
            CommandLine.HelpCommand.class
        },
        mixinStandardHelpOptions = true,
        description = "Create a new project")
public class SubcommandCreateProject implements Runnable {

    @Override
    public void run() {
        CommandLine.usage(this, System.out);
    }
}
