package mmm.coffee.metacode.engine;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import mmm.coffee.metacode.core.catalog.CatalogEntry;
import mmm.coffee.metacode.core.catalog.TemplateFacet;
import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import mmm.coffee.metacode.core.generator.ICodeGenerator;
import mmm.coffee.metacode.core.renderer.MustacheExpressionResolver;
import mmm.coffee.metacode.core.renderer.TemplateRenderer;
import org.springframework.stereotype.Component;

@Component
public class CodeGenerationEngine implements ICodeGenerator<ProjectDescriptor> {

    private final CatalogRegistry registry;
    private final TemplateRenderer renderer;
    private final TemplateModelConverter converter;
    private final ContentToFileWriter writer;

    public CodeGenerationEngine(
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
    public ICodeGenerator<ProjectDescriptor> doPreprocessing(ProjectDescriptor descriptor) {
        return this;
    }

    @Override
    public int generateCode(ProjectDescriptor descriptor) {
        List<CatalogEntry> entries = registry.entriesFor(descriptor);
        Map<String, Object> ftlModel = converter.toFtlModel(descriptor);
        Map<String, String> tokens = converter.toMustacheTokens(descriptor);

        for (CatalogEntry entry : entries) {
            for (TemplateFacet facet : entry.getFacets()) {
                String content = renderer.render(facet.getSourceTemplate(), ftlModel);
                String path = MustacheExpressionResolver.resolve(facet.getDestination(), tokens);
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
