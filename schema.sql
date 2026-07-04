    CREATE TABLE USERS (
        user_id SMALLINT AUTO_INCREMENT PRIMARY KEY,
        first_name VARCHAR(20),
        last_name VARCHAR(20)
    );

    CREATE TABLE PROCESSES (
        process_id INTEGER AUTO_INCREMENT  PRIMARY KEY,
        name VARCHAR(100) UNIQUE,
        deleted BOOLEAN
    );

    CREATE TABLE BATCHES (
        batch_id INTEGER AUTO_INCREMENT  PRIMARY KEY,
        created_at DATETIME
    );

    CREATE TABLE EXECUTIONS (
        execution_id INTEGER AUTO_INCREMENT  PRIMARY KEY,
        process_id INTEGER,
        user_id SMALLINT,
        batch_id INTEGER,
        executed_at DATETIME,
        status ENUM('SUCCESS','FAILED','RUNNING'),

        FOREIGN KEY (process_id) REFERENCES PROCESSES(process_id),
        FOREIGN KEY (user_id) REFERENCES USERS(user_id),
        FOREIGN KEY (batch_id) REFERENCES BATCHES(batch_id)
    );

    CREATE TABLE INPUTS (
        input_id INTEGER AUTO_INCREMENT PRIMARY KEY,
        batch_id INTEGER,
        input MEDIUMBLOB,

        FOREIGN KEY (batch_id) REFERENCES BATCHES(batch_id)
    );

    CREATE TABLE OUTPUTS (
        output_id INTEGER AUTO_INCREMENT PRIMARY KEY,
        execution_id INTEGER,
        output MEDIUMBLOB,

        FOREIGN KEY (execution_id) REFERENCES EXECUTIONS(execution_id)
    );

    CREATE TABLE ERRORS (
        error_id INTEGER AUTO_INCREMENT PRIMARY KEY,
        execution_id INTEGER,
        error_msg VARCHAR(400),

        FOREIGN KEY (execution_id) REFERENCES EXECUTIONS(execution_id)
    );

CREATE INDEX idx_executions_user
ON EXECUTIONS(user_id);

CREATE INDEX idx_executions_process
ON EXECUTIONS(process_id);

CREATE INDEX idx_executions_date
ON EXECUTIONS(executed_at);

CREATE VIEW execution_summary AS
SELECT
    e.execution_id,
    p.name AS process_name,
    u.first_name,
    u.last_name,
    e.executed_at,
    e.status
FROM EXECUTIONS e
JOIN PROCESSES p ON e.process_id = p.process_id
JOIN USERS u ON e.user_id = u.user_id;

CREATE VIEW failed_executions AS
SELECT
    execution_id,
    process_id,
    user_id,
    executed_at
FROM EXECUTIONS
WHERE status = 'FAILED';

CREATE VIEW execution_errors AS
SELECT
    e.execution_id,
    e.executed_at,
    er.error_msg
FROM EXECUTIONS e
JOIN ERRORS er
    ON e.execution_id = er.execution_id;

ALTER TABLE EXECUTIONS
ADD CONSTRAINT chk_status
CHECK (status IN ('SUCCESS','FAILED','RUNNING'));
