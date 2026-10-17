<#include "/common/Copyright.ftl">
package ${JobCompletionNotificationListener.packageName()};

import lombok.extern.slf4j.Slf4j;
import org.springframework.batch.core.BatchStatus;
import org.springframework.batch.core.job.JobExecution;
import org.springframework.batch.core.listener.JobExecutionListener;
import org.springframework.stereotype.Component;

/**
 * This is an example of a JobCompletionNotificationListener.
 * Modify the signature of the Job bean (in the BatchConfiguration class)
 * to use it. That is, do something like:
 *
 *   // the Job bean...
 *   @Bean
 *   public Job importWidgetsJob(JobRepository jobRepository,
 *                                JobCompletionNotificationListener listener,
 *                               Step step1) {
 *       return new JobBuilder("importWidgetsJob", jobRepository)
 *           .listener(listener)
 *           .flow( startStep )
 *           .end()
 *           .build()
 *   }
 *
 */
@Component
@Slf4j
public class ${JobCompletionNotificationListener.className()} implements JobExecutionListener {

    @Override
    public void afterJob(JobExecution jobExecution) {
        if (jobExecution.getStatus() == BatchStatus.COMPLETED) {
            log.info("Job finished. Perhaps print some summary information, like the number of records processed.");
        }
    }
}
