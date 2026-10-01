/*
 * Define the schema of your table.
 *
 * Since the code generator doesn't know what your table
 * needs to contain, only sample SQL is provided.
 *
 * create sequence if not exists [sequence-name] start 1 increment 1;
 *
 * create table if not exists [schema-name].[table-name]
 * (
 *   id serial primary key,
 *   resource_id varchar(60) not null unique,
 *   first_name varchar(32) not  null,
 *   last_name varchar(32) not null,
 *   last_modified timestamptz default current_timestamp,
 *   created_on timestamptz default current_timestamp
 * )
 */
