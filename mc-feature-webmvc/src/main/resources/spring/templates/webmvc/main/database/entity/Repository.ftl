<#include "/common/Copyright.ftl">
package ${Repository.packageName()};

import ${Entity.fqcn()};
import jakarta.persistence.QueryHint;
import java.util.List;
import java.util.Optional;
import org.hibernate.jpa.HibernateHints;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.QueryHints;

public interface ${Repository.className()} extends JpaRepository<${Entity.className()}, Long>,
                                                   JpaSpecificationExecutor<${Entity.className()}>
{
    /**
     * Find ${Entity.className()} by its resourceId
     *
     * @param resourceId the identifier
     * @return an Optional containing either ${Entity.className()} or empty.
     */
    Optional<${Entity.className()}> findByResourceId(String resourceId);

    /*
     * If the underlying table has, say, hundreds of thousands of rows (or more), then fetching all
     * the rows will probably be detrimental to performance. More often than not, a reasonable
     * limit on the number of rows returned should be applied; thus the query hints. The limit
     * chosen here is arbitrary; adjust as desired.
     * <p>
     * To read more on this topic, see:
     *  https://vladmihalcea.com/spring-data-jpa-stream/
     *  https://vladmihalcea.com/whats-new-in-jpa-2-2-stream-the-result-of-a-query-execution/
     *  https://vladmihalcea.com/jpa-hibernate-query-hints/
     */
    @QueryHints(@QueryHint(name = HibernateHints.HINT_FETCH_SIZE, value = "25"))
    @Override
    List<${Entity.className()}> findAll();

}

