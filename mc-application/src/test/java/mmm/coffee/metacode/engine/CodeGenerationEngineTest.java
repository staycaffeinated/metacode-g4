package mmm.coffee.metacode.engine;

import static org.assertj.core.api.Assertions.assertThat;

import mmm.coffee.metacode.core.descriptor.ProjectDescriptor;
import mmm.coffee.metacode.core.renderer.TemplateRenderer;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

public class CodeGenerationEngineTest {

    CatalogRegistry mockCatalogRegistry;
    TemplateRenderer templateRenderer;
    TemplateModelConverter templateModelConverter;
    ContentWriter noOpContentWriter;

    CodeGenerationEngine codeGenerationEngine;

    @BeforeEach
    void setUp() {
        mockCatalogRegistry = Mockito.mock(CatalogRegistry.class);
        templateModelConverter = Mockito.mock(TemplateModelConverter.class);
        noOpContentWriter = new NoOpContentToFileWriter();

        codeGenerationEngine = new CodeGenerationEngine(
                mockCatalogRegistry, templateRenderer, templateModelConverter, noOpContentWriter);
    }

    @Test
    void smokeTest() {
        ProjectDescriptor mvcProject = mvcProjectDescriptor();
        var codeGenerator = codeGenerationEngine.doPreprocessing(mvcProject);
        assertThat(codeGenerator).isNotNull();
    }

    private ProjectDescriptor mvcProjectDescriptor() {
        return Mockito.mock(ProjectDescriptor.class);
    }
}
