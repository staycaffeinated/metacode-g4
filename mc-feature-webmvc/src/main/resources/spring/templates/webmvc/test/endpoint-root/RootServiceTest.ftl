<#include "/common/Copyright.ftl">

package ${RootService.packageName()};

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
* Test the RootService
*/
class RootServiceTest {
    ${RootService.className()} serviceUnderTest = new ${RootService.className()}();

    /**
     * Test the single method of the RootService
     */
    @Test
    void testRootService() {
        assertThat(serviceUnderTest.doNothing()).isZero();
    }
}