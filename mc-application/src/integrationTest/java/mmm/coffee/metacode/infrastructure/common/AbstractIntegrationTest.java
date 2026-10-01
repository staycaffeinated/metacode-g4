package mmm.coffee.metacode.infrastructure.common;

import static mmm.coffee.metacode.infrastructure.profiles.SpringProfiles.INTEGRATION_TEST;
import static mmm.coffee.metacode.infrastructure.profiles.SpringProfiles.TEST;

import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@ActiveProfiles({TEST, INTEGRATION_TEST})
@SpringBootTest(args = {})
public abstract class AbstractIntegrationTest {}
