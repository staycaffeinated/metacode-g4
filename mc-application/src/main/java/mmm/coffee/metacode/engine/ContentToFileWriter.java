package mmm.coffee.metacode.engine;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import org.apache.commons.io.FileUtils;
import org.springframework.stereotype.Component;

@Component
public class ContentToFileWriter {

    public void write(String baseDirectory, String relativePath, String content) throws IOException {
        File target = new File(baseDirectory, relativePath);
        FileUtils.forceMkdirParent(target);
        FileUtils.writeStringToFile(target, content, StandardCharsets.UTF_8);
    }
}
