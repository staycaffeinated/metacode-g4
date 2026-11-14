package mmm.coffee.metacode.cli;

import java.io.InputStream;
import java.util.Properties;
import picocli.CommandLine;

public class VersionProvider implements CommandLine.IVersionProvider {

    @Override
    public String[] getVersion() throws Exception {
        try (InputStream is = getClass().getResourceAsStream("/META-INF/build-info.properties")) {
            if (is == null) {
                return new String[] {"unknown"};
            }
            Properties props = new Properties();
            props.load(is);
            return new String[] {props.getProperty("build.version", "unknown")};
        }
    }
}
