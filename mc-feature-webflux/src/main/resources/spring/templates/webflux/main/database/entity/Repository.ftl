<#include "/common/Copyright.ftl">
package ${Repository.packageName()};

import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.data.repository.reactive.ReactiveSortingRepository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

public interface ${Repository.className()} extends ReactiveSortingRepository<${Entity.className()}, Long>, ReactiveCrudRepository<${endpoint.ejbName}, Long> {

    // Find by the resource ID known by external applications
    Mono<${Entity.className()}> findByResourceId ( String id );

    // Find by the database ID
    Mono<${Entity.className()}> findById ( Long id );

    /* returns the number of entities deleted */
    Mono<Long> deleteByResourceId( String id );

    Flux<${Entity.className()}> findAllByText(String text);
}

