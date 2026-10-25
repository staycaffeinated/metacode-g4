<#include "/common/Copyright.ftl">
package ${Application.packageName()};

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.springframework.batch.core.ExitStatus;
import org.springframework.batch.core.step.StepExecution;
import org.springframework.batch.test.JobOperatorTestUtils;
import org.springframework.batch.test.JobRepositoryTestUtils;
import org.springframework.batch.test.MetaDataInstanceFactory;
import org.springframework.batch.test.StepScopeTestUtils;
import org.springframework.batch.test.context.SpringBatchTest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.TestExecutionListeners;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.support.DependencyInjectionTestExecutionListener;
import org.springframework.test.context.support.DirtiesContextTestExecutionListener;

import java.util.Collection;

import static org.assertj.core.api.Assertions.assertThat;

/*
 * See https://docs.spring.io/spring-batch/reference/testing.html
 * for information on how to test Spring Batch applications.
 */

@SpringBatchTest
@SpringBootTest
@SuppressWarnings({
    "java:S1607" // Until Job instances are implemented, tests can't run.
})
@TestExecutionListeners({DependencyInjectionTestExecutionListener.class, DirtiesContextTestExecutionListener.class})
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_CLASS)
@TestPropertySource(properties = {
    "spring.batch.job.enabled=true"})
class ${Application.integrationTestClass()} {

    @Autowired
    private JobOperatorTestUtils jobOperatorTestUtils;

    @Autowired
    private JobRepositoryTestUtils jobRepositoryTestUtils;

    @AfterEach
    void tearDown() {
        jobRepositoryTestUtils.removeJobExecutions();
    }

    @Disabled("Will not work until the Job is implemented.")
    void contextLoads() {
        // The context won't load until the batch job configuration is defined.
        // NEXT STEPS:
        // Define Beans for an ItemReader and ItemWriter
        // Define a Step that uses the ItemReader and ItemWriter
        // Define a Job that runs the Step
        //
        // Once the Beans that make up the batch job are defined, you can enable this test.
        // Errors usually indicate a misconfiguration issue.
        //
        // Also, be mindful that these 2 properties are set:
        // 1) spring.batch.job.enabled=false
        // 2) spring.batch.jdbc.initialize-schema=always
        // The spring.batch.job.enabled _must_ be false or you will get errors that
        // a JobBuilderFactory cannot be instantiated.
        // The spring.batch.jbc.initialize-schema is set to 'always' to enable
        // Spring Batch's tables to be created.
    }

    /**
     * This test won't work until the Job is implemented.
     * Jobs are commonly configured in the BatchConfiguration class.
     * This is only a hypothetical test meant only to illustrate techniques.
     */
    @Disabled("Will not work until the Job is implemented.")
    public void whenJobExecutes_expectCompleted() throws Exception {
        var jobExecution = jobOperatorTestUtils.startJob();
        var actualJobInstance = jobExecution.getJobInstance();
        ExitStatus actualJobExitStatus = jobExecution.getExitStatus();

        assertThat(actualJobInstance.getJobName()).isEqualTo("job");
        assertThat(actualJobExitStatus.getExitCode()).isEqualTo("COMPLETED");
    }

    /**
     * This test won't work until a Step is implemented.
     * Steps are commonly implemented in the BatchConfiguration class.
     * This is only a hypothetical test meant only to illustrate techniques.
     */
    @Disabled("Will not work until the Step is implemented.")
    public void whenStepExecution_expectCompleted() throws Exception {
        var jobExecution = jobOperatorTestUtils.startStep("step1");
        Collection<StepExecution> actualStepExecutions = jobExecution.getStepExecutions();
        ExitStatus actualJobExitStatus = jobExecution.getExitStatus();

        assertThat(actualStepExecutions).hasSize(1);
        assertThat(actualJobExitStatus.getExitCode()).isEqualTo("COMPLETED");

        actualStepExecutions.forEach(stepExecution -> {
            assertThat(stepExecution.getWriteCount()).isEqualTo(1);
        });
    }

    /**
     * This test won't work until a Step is implemented.
     * Steps are commonly implemented in the BatchConfiguration class.
     * This test illustrates how to test a Bean that's in StepScope.
     */
    @Disabled("Will not work until the Step is implemented.")
    public void givenMockedStep_whenWriterCalled_thenSuccess() throws Exception {
        StepExecution stepExecution = MetaDataInstanceFactory.createStepExecution();

        StepScopeTestUtils.doInStepScope(stepExecution, () -> {
            return null;
        });
    }
}
