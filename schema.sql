-- Schema Design for 8 tables

    CREATE TABLE USERS (
        user_id SMALLINT AUTO_INCREMENT PRIMARY KEY,
        first_name VARCHAR(20) NOT NULL,
        last_name VARCHAR(20) NOT NULL,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        deleted BOOLEAN NOT NULL DEFAULT FALSE
    );

    CREATE TABLE PROCESSES (
        process_id INTEGER AUTO_INCREMENT  PRIMARY KEY,
        name VARCHAR(100) NOT NULL UNIQUE,
        deleted BOOLEAN NOT NULL DEFAULT FALSE,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE BATCHES (
        batch_id INTEGER AUTO_INCREMENT PRIMARY KEY,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE EXECUTIONS (
        execution_id INTEGER AUTO_INCREMENT PRIMARY KEY,
        process_id INTEGER NOT NULL,
        user_id SMALLINT NOT NULL,
        batch_id INTEGER NOT NULL,
        executed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        status ENUM('SUCCESS','FAILED','RUNNING') NOT NULL,

        FOREIGN KEY (process_id) REFERENCES PROCESSES(process_id),
        FOREIGN KEY (user_id) REFERENCES USERS(user_id),
        FOREIGN KEY (batch_id) REFERENCES BATCHES(batch_id)
    );

    CREATE TABLE INPUTS (
        input_id INTEGER AUTO_INCREMENT PRIMARY KEY NOT NULL,
        batch_id INTEGER NOT NULL,
        input MEDIUMBLOB NOT NULL,

        FOREIGN KEY (batch_id) REFERENCES BATCHES(batch_id)
    );

    CREATE TABLE OUTPUTS (
        output_id INTEGER AUTO_INCREMENT PRIMARY KEY NOT NULL,
        execution_id INTEGER NOT NULL,
        output MEDIUMBLOB NOT NULL,

        FOREIGN KEY (execution_id) REFERENCES EXECUTIONS(execution_id)
    );

    CREATE TABLE ERRORS (
        error_id INTEGER AUTO_INCREMENT PRIMARY KEY NOT NULL,
        execution_id INTEGER NOT NULL,
        error_msg VARCHAR(400) NOT NULL,

        FOREIGN KEY (execution_id) REFERENCES EXECUTIONS(execution_id)
    );

CREATE INDEX idx_executions_user
ON EXECUTIONS(user_id);

CREATE INDEX idx_batchid
ON EXECUTIONS(batch_id);

CREATE INDEX idx_executions_process
ON EXECUTIONS(process_id);

CREATE INDEX idx_executions_date
ON EXECUTIONS(executed_at);

CREATE INDEX idx_input_bid
ON INPUTS(batch_id);

CREATE INDEX idx_execution_id
ON OUTPUTS(execution_id);

CREATE INDEX idx_error_exec
ON ERRORS(execution_id);

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

-- Extract errors from batch stored procedure
    
DELIMITER //
CREATE PROCEDURE GetBatchErrors(IN param_batch_id INT)
BEGIN
    SELECT
        e.execution_id,
        e.executed_at,
        e.status,
        er.error_msg
    FROM EXECUTIONS e
    JOIN ERRORS er
        ON e.execution_id = er.execution_id
    WHERE e.batch_id = param_batch_id
    ORDER BY e.executed_at DESC;
END //
DELIMITER;

--Insert another process in the PROCESSES table
    
DELIMITER //
CREATE PROCEDURE AddProcess(IN param_process_name VARCHAR(100))
BEGIN
    INSERT INTO PROCESSES(name)
    VALUES(param_process_name);
END //
DELIMITER;

--Add user in USERS table stored procedure
    
DELIMITER //
CREATE PROCEDURE AddUser(IN param_fn VARCHAR(20), IN param_ln VARCHAR(20))
BEGIN
    INSERT INTO USERS(first_name, last_name)
    VALUES (param_fn, param_ln);
END //
DELIMITER;

--Edit DB name in USERS table stored procedure
    
DELIMITER //
CREATE PROCEDURE ChangeName(IN param_fn VARCHAR(20),IN param_ln VARCHAR(20),IN par_id SMALLINT)
BEGIN
    UPDATE USERS
    SET first_name = param_fn , last_name = param_ln
    WHERE user_id = par_id;
END //
DELIMITER;

--Stored Procedure that changes the name introduced wrong of a process
DELIMITER //
CREATE PROCEDURE CorrectProcessName(IN wrong_name VARCHAR(100),IN correct_name VARCHAR(100))
BEGIN
    UPDATE PROCESSES
    SET name = correct_name
    WHERE id = (
        SELECT process_id
        FROM PROCESSES
        WHERE name = wrong_name
    );
END //
DELIMITER;

--SQL query to eliminate a user
DELIMITER //
CREATE PROCEDURE DeleteUser( IN param_fn VARCHAR(20), IN param_ln VARCHAR(20))
BEGIN
    DELETE FROM users
    WHERE user_id = (
        SELECT user_id
        FROM USERS
        WHERE first_name = param_fn AND last_name = param_ln
    );
END //
DELIMITER;
;
