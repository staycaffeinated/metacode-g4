<#include "/common/Copyright.ftl">
package ${Controller.packageName()};

import ${ResourceIdentity.fqcn()};
import ${EntityResource.fqcn()};
import ${OnCreateAnnotation.fqcn()};
import ${OnUpdateAnnotation.fqcn()};
import ${ResourceIdAnnotation.fqcn()};
import ${ServiceApi.fqcn()};
import ${UnprocessableEntityException.fqcn()};
import ${ResourceNotFoundException.fqcn()};
import ${ServiceApi.fqcn()};
import ${EntityRequest.fqcn()};
import ${EntityResponse.fqcn()};

<#if endpoint.isWithOpenApi()>
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
</#if>
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.Objects;
import java.time.Duration;

@RestController
<#noparse>
@RequestMapping("")
</#noparse>
@Slf4j
@Validated
@RequiredArgsConstructor
public class ${Controller.className()} {

    private final ${ServiceApi.className()} ${endpoint.entityVarName}Service;


<#if endpoint.isWithOpenApi()>
    @Operation(summary = "Retrieve all ${endpoint.entityName}s")
    @ApiResponses(value = {@ApiResponse(responseCode = "200", description = "Found all ${endpoint.entityName}s")})
</#if>
    @GetMapping (value=${Routes.className()}.${endpoint.routeConstants.findAll}, produces = MediaType.APPLICATION_JSON_VALUE )
    public Flux<${EntityResponse.className()}> getAll${endpoint.entityName}s() {
        return ${endpoint.entityVarName}Service.findAll${endpoint.entityName}s().map(${EntityResponse.className()}::fromDomain);
    }


<#if endpoint.isWithOpenApi()>
    @Operation(summary = "Retrieve a single ${endpoint.entityName} based on its public identifier")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Found the ${endpoint.entityName}", content = {
                @Content(mediaType = "application/json", schema = @Schema(implementation = ${EntityResponse.className()}.class))}),
        @ApiResponse(responseCode = "400", description = "An invalid ID was supplied")})
</#if>
    @GetMapping(value=${Routes.className()}.${endpoint.routeConstants.findOne}, produces = MediaType.APPLICATION_JSON_VALUE )
    public Mono<${EntityResponse.className()}> get${endpoint.entityName}ById(@PathVariable @${ResourceIdAnnotation.className()} String id) {
        return ${endpoint.entityVarName}Service.findByResourceId(id)
                .switchIfEmpty(Mono.error(new ${ResourceNotFoundException.className()}(id))).map(${EntityResponse.className()}::fromDomain);
    }
    
    /**
     * If the api needs to push items as Streams to ensure Backpressure is applied, we
     * need to set produces to MediaType.TEXT_EVENT_STREAM_VALUE
     *
     * MediaType.TEXT_EVENT_STREAM_VALUE is the official media type for Server Sent
     * Events (SSE) MediaType.APPLICATION_STREAM_JSON_VALUE is for server to
     * server/http client communications.
     *
	 * https://stackoverflow.com/questions/52098863/whats-the-difference-between-text-event-stream-and-application-streamjson
	 *
	 */
    @GetMapping(value = ${Routes.className()}.${endpoint.routeConstants.stream}, produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    @ResponseStatus(value = HttpStatus.OK)
    public Flux<${EntityResponse.className()}> get${endpoint.entityName}Stream() {
	    // This is only an example implementation. Modify this line as needed.
        return ${endpoint.entityVarName}Service.findAll${endpoint.entityName}s()
                .delayElements(Duration.ofMillis(250))
                .map(${EntityResponse.className()}::fromDomain);
    }


<#if endpoint.isWithOpenApi()>
    @Operation(summary = "Create a new ${endpoint.entityName} entry and persist it")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Add a ${endpoint.entityName}", content = {
            @Content(mediaType = "application/json", schema = @Schema(implementation = ${ResourceIdentity.className()}.class))}),
    @ApiResponse(responseCode = "400", description = "An invalid ID was supplied")})
</#if>
    @PostMapping (value=${Routes.className()}.${endpoint.routeConstants.create}, produces = MediaType.APPLICATION_JSON_VALUE)
    @Validated(OnCreate.class) 
    public Mono<ResponseEntity<ResourceIdentity>> create${endpoint.entityName}(@RequestBody ${EntityRequest.className()} request ) {
        Mono<String> id = ${endpoint.entityVarName}Service.create${endpoint.entityName}(request.toDomain());
        return id.map(value -> ResponseEntity.status(HttpStatus.CREATED).body(new ResourceIdentity(value)));
    }
    

<#if endpoint.isWithOpenApi()>
    @Operation(summary = "Update an existing ${endpoint.entityName}")
        @ApiResponses(value = {@ApiResponse(responseCode = "200", description = "Updated the ${endpoint.entityName}"),
            @ApiResponse(responseCode = "400", description = "Incorrect data was submitted")})
</#if>
    @PutMapping(value=${endpoint.entityName}Routes.${endpoint.routeConstants.update}, produces = MediaType.APPLICATION_JSON_VALUE )
    @Validated(OnUpdate.class) 
    public Mono<${EntityResponse.className()}> update${endpoint.entityName}(@PathVariable @ResourceId String id, @RequestBody ${EntityRequest.className()} request) {
        if (!Objects.equals(id, request.resourceId())) {
            log.error("Update declined: mismatch between query string identifier, {}, and resource identifier, {}", id, request.resourceId());
            return Mono.error(new UnprocessableEntityException("Mismatch between the identifiers in the URI and the payload"));
        }
        return ${endpoint.entityVarName}Service.update${endpoint.entityName}(request.toDomain()).map(${EntityResponse.className()}::fromDomain);
    }


<#if endpoint.isWithOpenApi()>
    @Operation(summary = "Delete an existing ${endpoint.entityName}")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204",
            description = "Removed the ${endpoint.entityName}. Returns number of records removed."),
        @ApiResponse(responseCode = "400", description = "An incorrect identifier was submitted")})
</#if>
    @DeleteMapping(value=${endpoint.entityName}Routes.${endpoint.routeConstants.delete})
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Long> delete${endpoint.entityName}(@PathVariable @ResourceId String id) {
        return ${endpoint.entityVarName}Service.delete${endpoint.entityName}ByResourceId(id);
    }
}