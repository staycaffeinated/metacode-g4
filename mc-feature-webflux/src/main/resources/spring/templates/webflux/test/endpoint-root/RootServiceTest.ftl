<#include "/common/Copyright.ftl">
package ${RootService.packageName()};

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import static org.assertj.core.api.Assertions.assertThat;

/**
 *
 */
@ExtendWith(MockitoExtension.class)
class ${RootService.testClass()} {

    @InjectMocks
	private ${RootService.className()} serviceUnderTest;

	@Test
	void verifyServiceIsLoaded() {
		int result = serviceUnderTest.doNothing();
		assertThat(result).isZero();
	}
}