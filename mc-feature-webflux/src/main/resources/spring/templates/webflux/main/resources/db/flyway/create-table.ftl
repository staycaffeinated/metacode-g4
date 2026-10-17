create table if not exists ${endpoint.tableName}
(
    id          serial primary key,
    resource_id varchar(60)  not null unique,
    text        varchar(255) not null
);
