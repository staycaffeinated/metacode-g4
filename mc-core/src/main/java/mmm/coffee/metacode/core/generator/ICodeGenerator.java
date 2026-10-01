package mmm.coffee.metacode.core.generator;

/**
 * @param <T> the descriptor type (ProjectDescriptor or EndpointDescriptor)
 */
public interface ICodeGenerator<T> {

    ICodeGenerator<T> doPreprocessing(T descriptor);

    /**
     * @return 0 on success, non-zero on failure
     */
    int generateCode(T descriptor);
}
