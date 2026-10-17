<#include "/common/Copyright.ftl">
package ${BatchConfiguration.packageName()};

import lombok.RequiredArgsConstructor;
import org.springframework.batch.core.job.Job;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.job.parameters.RunIdIncrementer;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.Step;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * References:
 *  https://github.com/spring-projects/spring-batch/tree/main/spring-batch-samples
 *  https://docs.spring.io/spring-batch/docs/current/reference/html/index.html
 *  https://docs.spring.io/spring-batch/docs/current/reference/html/readersAndWriters.html
 */
@Configuration
@RequiredArgsConstructor
public class ${BatchConfiguration.className()} {

    /**
     * Next steps:
     * 1. Create a @Bean for an ItemReader that consumes the input source
     * 2. Create a @Bean for an ItemWriter that writes the output
     * 3. Optional: create a @Bean for any ItemProcessors needed
     * 4. Create a @Bean that returns each Step of the batch Job; for example:
     *    @Bean
     *    public Step step1(JobRepository jobRepository,
     *                   PlatformTransactionManager transactionManager,
     *                   ItemReader<WidgetIn> theReader,
     *                   ItemProcessor<WidgetIn, WidgetOut> theProcessor,
     *                   ItemWriter<WidgetOut> theWriter) {
     *    return new StepBuilder("step1", jobRepository)
     *          .<WidgetIn, WidgetOut>chunk(10, transactionManager)
     *          .reader(theReader)
     *          .processor(theProcessor)
     *          .writer(theWriter)
     *          .build();
     *   }
     *
     * 5. Create a @Bean that returns the Job; for example:
     *    @Bean
     *    public Job getJob(JobRepository jobRepository, JobCompletionNotificationListener listener, Step step1) {
     *
     *        return new JobBuilder("importWidgetsJob", jobRepository)
     *            .incrementer(new RunIdIncrementer())
     *            .listener(listener)
     *            .flow(step1)
     *            .end()
     *            .build();
     *    }
     *
     */
}
