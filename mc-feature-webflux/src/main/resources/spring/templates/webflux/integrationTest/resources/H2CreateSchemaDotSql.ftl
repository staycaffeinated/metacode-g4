/* H2 schema for ${endpoint.entityName} integration tests */
DROP TABLE IF EXISTS ${endpoint.tableName};
CREATE TABLE ${endpoint.tableName}
(
    ID          INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    RESOURCE_ID VARCHAR(50)        NOT NULL,
    TEXT        VARCHAR(255)       NOT NULL
);
