<#include "/common/Copyright.ftl">
package ${Controller.packageName()};

import ${EntityResource.fqcn()};
import ${UnprocessableEntityException.fqcn()};
import ${OnCreateAnnotation.fqcn()};
import ${OnUpdateAnnotation.fqcn()};
import ${ResourceIdTrait.fqcn()};
import ${SearchTextAnnotation.fqcn()};
import ${ResourceIdAnnotation.fqcn()};
import ${Routes.fqcn()};
import ${EntityCommandUseCase.fqcn()};
import ${EntityQueryUseCase.fqcn()};

<#if endpoint.isWithOpenApi()>
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
</#if>
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.data.web.PagedResourcesAssembler;
import org.springframework.data.web.SortDefault;
import org.springframework.hateoas.EntityModel;
import org.springframework.hateoas.PagedModel;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Optional;
import java.net.URI;

@RestController
@RequestMapping
@Slf4j
@Validated
public class ${Controller.className()} {

    private static final int DEFAULT_PAGE_NUMBER = 0;
    private static final int DEFAULT_PAGE_SIZE = 25;

    private final ${EntityCommandUseCase.className()} commandUseCase;
    private final ${EntityQueryUseCase.className()} queryUseCase;

    public ${Controller.className()}(${EntityCommandUseCase.className()} commandUseCase, ${EntityQueryUseCase.className()} queryUseCase) {
        this.commandUseCase = commandUseCase;
        this.queryUseCase = queryUseCase;
    }

    <#if endpoint.isWithOpenApi()>
    @Operation(summary = "Retrieve all ${endpoint.entityName}")
    @ApiResponses(value = {@ApiResponse(responseCode = "200", description = "Found all ${endpoint.entityName}")})
    </#if>
    @GetMapping (value=${Routes.className()}.${endpoint.routeConstants.findAll}, produces = MediaType.APPLICATION_JSON_VALUE )
    public List<${EntityResponse.className()}> getAll${endpoint.entityName}s() {
        return queryUseCase.findAll${endpoint.entityName}(Pageable.unpaged())
                   .map(${EntityResponse.className()}::fromDomain)
                   .getContent();
    }

    <#if endpoint.isWithOpenApi()>
    @Operation(summary = "Retrieve a single pet based on its public identifier")
    @ApiResponses(value = {
    @ApiResponse(responseCode = "200", description = "Found the pet", content = {
    @Content(mediaType = "application/json",
    schema = @Schema(implementation = ${EntityResponse.className()}.class))}),
    @ApiResponse(responseCode = "400", description = "An invalid ID was supplied")})
    </#if>
    @GetMapping(value=${Routes.className()}.${endpoint.routeConstants.findOne}, produces = MediaType.APPLICATION_JSON_VALUE )
    public ResponseEntity<${EntityResponse.className()}> get${endpoint.entityName}ById(@PathVariable @ResourceId String id) {
        return queryUseCase.find${endpoint.entityName}ByResourceId(id)
            .map(${EntityResponse.className()}::fromDomain)
            .map(ResponseEntity::ok)
            .orElseGet(() -> ResponseEntity.notFound().build());
    }

<#if endpoint.isWithOpenApi()>
    @Operation(summary = "Create a new ${endpoint.entityName} and persist it")
    @ApiResponses(value = {
    @ApiResponse(responseCode = "200", description = "Add a ${endpoint.entityName}",
    content = {
    @Content(mediaType = "application/json",
    schema = @Schema(implementation = ${EntityResponse.className()}.class))}),
    @ApiResponse(responseCode = "400", description = "An invalid ID was supplied")})
</#if>
    @PostMapping (value=${Routes.className()}.${endpoint.routeConstants.create}, produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<${EntityResponse.className()}> create${endpoint.entityName}(@RequestBody @Validated(OnCreate.class) ${EntityRequest.className()} request ) {
        ${EntityResource.className()} savedResource = commandUseCase.create${endpoint.entityName} ( request.toDomain() );
        URI uri = ServletUriComponentsBuilder
                .fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(savedResource.getResourceId())
                .toUri();
        return ResponseEntity.created(uri).body(${EntityResponse.className()}.fromDomain(savedResource));
    }

<#if endpoint.isWithOpenApi()>
    @Operation(summary = "Update an existing ${endpoint.entityName}")
    @ApiResponses(value = {@ApiResponse(responseCode = "200", description = "Updated the ${endpoint.entityName}"),
    @ApiResponse(responseCode = "400", description = "Incorrect data was submitted")})
</#if>
    @PutMapping(value=${Routes.className()}.${endpoint.routeConstants.update}, produces = MediaType.APPLICATION_JSON_VALUE )
    public ResponseEntity<${EntityResponse.className()}> update${endpoint.entityName}(@PathVariable @ResourceId String id, @RequestBody @Validated(OnUpdate.class) ${EntityRequest.className()} request) {
        if (!id.equals(request.resourceId())) {
            throw new UnprocessableEntityException("The identifier in the query string and request body do not match");
        }
        return commandUseCase.update${endpoint.entityName}(request.toDomain())
            .map(${EntityResponse.className()}::fromDomain)
            .map(ResponseEntity::ok)
            .orElseGet(() -> ResponseEntity.notFound().build());
    }

<#if endpoint.isWithOpenApi()>
    @Operation(summary = "Delete an existing ${endpoint.entityName}")
    @ApiResponses(value = {@ApiResponse(responseCode = "200", description = "Removed the ${endpoint.entityName}"),
    @ApiResponse(responseCode = "400", description = "An incorrect identifier was submitted")})
</#if>
    @DeleteMapping(value=${Routes.className()}.${endpoint.routeConstants.delete})
    public ResponseEntity<${EntityResponse.className()}> delete${endpoint.entityName}(@PathVariable @ResourceId String id) {
        return commandUseCase.delete${endpoint.entityName}ByResourceId(id)
            .map(${EntityResponse.className()}::fromDomain)
            .map(ResponseEntity::ok)
            .orElseGet(() -> ResponseEntity.notFound().build());
    }

    <#if endpoint.isWithOpenApi()>
    @Operation(summary = "Search for ${endpoint.entityName} using an RSQL query")
    @ApiResponses(value = {@ApiResponse(responseCode = "200", description = "Found matching entries")})
    </#if>
    @GetMapping(value=${Routes.className()}.${endpoint.routeConstants.search}, produces = MediaType.APPLICATION_JSON_VALUE)
    public PagedModel<EntityModel<${EntityResponse.className()}>> searchByQuery (
    @RequestParam(name="q", required = false) Optional<<#noparse>@SearchText</#noparse> String> rsqlQuery,
        @PageableDefault(page = DEFAULT_PAGE_NUMBER, size = DEFAULT_PAGE_SIZE)
        @SortDefault(sort = ${endpoint.pojoName}.Fields.TEXT, direction = Sort.Direction.ASC)
            <#if endpoint.isWithOpenApi()>@Parameter</#if> Pageable pageable,
        PagedResourcesAssembler<${EntityResponse.className()}> resourceAssembler)
    {
        Page<${EntityResponse.className()}> responsePage = queryUseCase.search(rsqlQuery.orElse(""), pageable)
            .map(${EntityResponse.className()}::fromDomain);
        return resourceAssembler.toModel( responsePage );
    }
}