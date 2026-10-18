package mmm.coffee.metacode.engine;

import java.io.IOException;

@SuppressWarnings("all")
public class NoOpContentToFileWriter implements ContentWriter {

    public void write(String baseDirectory, String relativePath, String content) throws IOException {
        // This is intentionally a no-op
    }
}
