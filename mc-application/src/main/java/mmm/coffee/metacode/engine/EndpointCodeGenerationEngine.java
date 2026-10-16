package mmm.coffee.metacode.engine;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import mmm.coffee.metacode.core.catalog.CatalogEntry;
import mmm.coffee.metacode.core.catalog.TemplateFacet;
import mmm.coffee.metacode.core.descriptor.EndpointDescriptor;
import mmm.coffee.metacode.core.generator.ICodeGenerator;
import mmm.coffee.metacode.core.renderer.MustacheExpressionResolver;
import mmm.coffee.metacode.core.renderer.TemplateRenderer;

public class EndpointCodeGenerationEngine implements ICodeGenerator<EndpointDescriptor> {

    private final CatalogRegistry registry;
    private final TemplateRenderer renderer;
    private final TemplateModelConverter converter;
    private final ContentToFileWriter writer;

    public EndpointCodeGenerationEngine(
            CatalogRegistry registry,
            TemplateRenderer renderer,
            TemplateModelConverter converter,
            ContentToFileWriter writer) {
        this.registry = registry;
        this.renderer = renderer;
        this.converter = converter;
        this.writer = writer;
    }

    @Override
    public ICodeGenerator<EndpointDescriptor> doPreprocessing(EndpointDescriptor descriptor) {
        return this;
    }

    @Override
    public int generateCode(EndpointDescriptor descriptor) {
        List<CatalogEntry> entries = registry.endpointEntriesFor(descriptor);
        Map<String, Object> ftlModel = converter.toEndpointFtlModel(descriptor);
        Map<String, String> tokens = converter.toEndpointMustacheTokens(descriptor);

        for (CatalogEntry entry : entries) {
            for (TemplateFacet facet : entry.getFacets()) {
                if (facet.getDestination() == null || facet.getDestination().isEmpty()) continue;
                String path = MustacheExpressionResolver.resolve(facet.getDestination(), tokens);
                String content = renderer.render(facet.getSourceTemplate(), ftlModel);
                try {
                    writer.write(descriptor.getBaseDirectory(), path, content);
                } catch (IOException e) {
                    throw new RuntimeException("Failed to write: " + path, e);
                }
            }
        }
        return 0;
    }
}
