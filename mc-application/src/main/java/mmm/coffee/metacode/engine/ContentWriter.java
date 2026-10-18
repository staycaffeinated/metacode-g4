package mmm.coffee.metacode.engine;

import java.io.IOException;

public interface ContentWriter {
    void write(String baseDirectory, String relativePath, String content) throws IOException;
}
