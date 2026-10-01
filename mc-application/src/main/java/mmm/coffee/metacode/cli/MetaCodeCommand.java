package mmm.coffee.metacode.cli;

import org.springframework.stereotype.Component;
import picocli.CommandLine;

@Component
@CommandLine.Command(
        name = "metacode",
        subcommands = {CreateCommand.class, CommandLine.HelpCommand.class},
        mixinStandardHelpOptions = true,
        description = "MetaCode - Spring project code generator")
public class MetaCodeCommand implements Runnable {

    @Override
    public void run() {
        CommandLine.usage(this, System.out);
    }
}
