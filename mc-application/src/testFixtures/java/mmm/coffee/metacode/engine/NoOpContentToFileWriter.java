package mmm.coffee.metacode.engine;

import java.io.IOException;

@SuppressWarnings("all")
public class NoOpContentToFileWriter extends ContentToFileWriter {

    @Override
    public void write(String baseDirectory, String relativePath, String content) throws IOException {
        // intentional no-op
    }
}
