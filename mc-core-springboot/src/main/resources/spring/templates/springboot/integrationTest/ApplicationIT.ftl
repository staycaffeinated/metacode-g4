<#-- Template: ApplicationIT.java -->
package ${basePackage};

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class ApplicationIT extends AbstractIntegrationTest {

    @Test
    void contextLoads() {
    }
}
