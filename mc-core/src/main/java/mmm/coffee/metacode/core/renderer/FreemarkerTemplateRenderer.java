package mmm.coffee.metacode.core.renderer;

import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import freemarker.template.TemplateExceptionHandler;
import java.io.IOException;
import java.io.StringWriter;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class FreemarkerTemplateRenderer implements TemplateRenderer {

    private final Configuration configuration;

    public FreemarkerTemplateRenderer() {
        this.configuration = defaultConfiguration();
    }

    public FreemarkerTemplateRenderer(Configuration configuration) {
        this.configuration = configuration;
    }

    @Override
    public String render(String templatePath, Map<String, Object> model) {
        try {
            Template template = configuration.getTemplate(templatePath);
            StringWriter writer = new StringWriter();
            template.process(model, writer);
            return writer.toString();
        } catch (IOException | TemplateException e) {
            throw new TemplateRenderException("Failed to render template: " + templatePath, e);
        }
    }

    private static Configuration defaultConfiguration() {
        Configuration cfg = new Configuration(Configuration.VERSION_2_3_34);
        cfg.setClassLoaderForTemplateLoading(FreemarkerTemplateRenderer.class.getClassLoader(), "/");
        cfg.setDefaultEncoding("UTF-8");
        cfg.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);
        cfg.setLogTemplateExceptions(false);
        cfg.setWrapUncheckedExceptions(true);
        return cfg;
    }
}
