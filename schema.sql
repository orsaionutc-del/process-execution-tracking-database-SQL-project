-- Schema Design for 7 tables

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
        batch_id INTEGER NOT NULL UNIQUE,
        input MEDIUMBLOB NOT NULL,

        FOREIGN KEY (batch_id) REFERENCES BATCHES(batch_id)
    );

    CREATE TABLE OUTPUTS (
        output_id INTEGER AUTO_INCREMENT PRIMARY KEY NOT NULL,
        execution_id INTEGER NOT NULL UNIQUE,
        output MEDIUMBLOB NOT NULL,

        FOREIGN KEY (execution_id) REFERENCES EXECUTIONS(execution_id)
    );

    CREATE TABLE ERRORS (
        error_id INTEGER AUTO_INCREMENT PRIMARY KEY NOT NULL,
        execution_id INTEGER NOT NULL,
        error_msg VARCHAR(400) NOT NULL,

        FOREIGN KEY (execution_id) REFERENCES EXECUTIONS(execution_id)
    );

-- Indexes

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

-- execution summary
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

-- all the failed executions
CREATE VIEW failed_executions AS
SELECT
    execution_id,
    process_id,
    user_id,
    executed_at
FROM EXECUTIONS
WHERE status = 'FAILED';

-- all the executions and all the errors
CREATE VIEW execution_errors AS
SELECT
    e.execution_id,
    e.executed_at,
    er.error_msg
FROM EXECUTIONS e
JOIN ERRORS er
    ON e.execution_id = er.execution_id;

-- statistics regarding total processes and their success
CREATE VIEW process_statistics AS
WITH exec_processes AS (
    SELECT
    process_id,
    COUNT(status) as total_executions,
    SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END) AS successful_executions,
    SUM(CASE WHEN status = 'FAILED' THEN 1 ELSE 0 END) AS failed_executions,
    SUM(CASE WHEN status = 'RUNNING' THEN 1 ELSE 0 END) AS running_executions
FROM EXECUTIONS
GROUP BY process_id
    )
    SELECT 
    p.name, 
    e.process_id, 
    COALESCE(e.total_executions,0) AS total_executions, 
    COALESCE(e.successful_executions, 0) AS successful_executions, 
    COALESCE(e.failed_executions, 0) AS failed_executions,
    COALESCE(e.running_executions, 0) AS running_executions,
    COALESCE(e.successful_executions, 0)/ NULLIF(COALESCE(e.total_executions,0),0) AS success_ratio
    FROM exec_processes AS e
    RIGHT JOIN PROCESSES AS p 
    ON e.process_id = p.process_id
    ;

-- Number of executions/user
CREATE VIEW user_execution_statistics AS
    SELECT
    u.user_id,
    CONCAT(u.first_name,' ',u.last_name) AS full_name,
    COALESCE(COUNT(e.execution_id),0) AS total_executions,
    COALESCE(SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END),0) AS successful_executions,
    COALESCE(SUM(CASE WHEN status = 'FAILED' THEN 1 ELSE 0 END),0) AS failed_executions,
    COALESCE(SUM(CASE WHEN status = 'RUNNING' THEN 1 ELSE 0 END),0) AS running_executions
    FROM EXECUTIONS AS e
    RIGHT JOIN USERS AS u 
    ON e.user_id = u.user_id
    GROUP BY u.user_id, u.first_name, u.last_name;

-- execution order + number of executions
CREATE VIEW process_execution_ranking AS
    SELECT
    e.execution_id,
    e.process_id,
    p.name,
    e.executed_at,
    e.status,
    COUNT(e.execution_id) OVER (PARTITION BY e.process_id) AS number_of_executions,
    ROW_NUMBER() OVER (PARTITION BY e.process_id ORDER BY executed_at DESC) execution_order
    FROM EXECUTIONS AS e
    JOIN PROCESSES AS p
    ON e.process_id = p.process_id;

-- Extract errors from batch stored procedure
DELIMITER //
CREATE PROCEDURE GetBatchErrors(IN param_batch_id INT)
BEGIN
    IF param_batch_id NOT IN (
    SELECT batch_id 
    FROM EXECUTIONS
    ) 
    THEN 
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'This batch does not exist';
    END IF;
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
DELIMITER ;

--Insert another process in the PROCESSES table 
DELIMITER //
CREATE PROCEDURE AddProcess(IN param_process_name VARCHAR(100))
BEGIN
    IF param_process_name IS NULL
    THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Please do not insert a NULL value';
    END IF;
    IF param_process_name = ''
    THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'This is an empty value';
    END IF;
    IF param_process_name IN (SELECT name FROM PROCESSES)
    THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'You already have this process in the database';
    END IF;
    INSERT INTO PROCESSES(name)
    VALUES(param_process_name);
END //
DELIMITER ;

--Add user in USERS table stored procedure   
DELIMITER //
CREATE PROCEDURE AddUser(IN param_fn VARCHAR(20), IN param_ln VARCHAR(20))
BEGIN
    IF EXISTS (
    SELECT 1 
    FROM USERS 
    WHERE first_name = param_fn AND last_name = param_ln
)
    THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'You already have this username in the database';
    END IF;
    INSERT INTO USERS(first_name, last_name)
    VALUES (param_fn, param_ln);
END //
DELIMITER ;

--Edit DB name in USERS table stored procedure   
DELIMITER //
CREATE PROCEDURE ChangeName(IN param_fn VARCHAR(20),IN param_ln VARCHAR(20),IN par_id SMALLINT)
BEGIN
    IF EXISTS (
    SELECT 1 FROM USERS 
    WHERE first_name = param_fn AND last_name = param_ln
)
    THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'You already have this username in the database';
    END IF;
    UPDATE USERS
    SET first_name = param_fn , last_name = param_ln
    WHERE user_id = par_id;
END //
DELIMITER ;

--Stored Procedure that changes the name introduced wrong of a process
DELIMITER //
CREATE PROCEDURE CorrectProcessName(IN wrong_name VARCHAR(100),IN correct_name VARCHAR(100))
BEGIN
    IF correct_name IN (SELECT name FROM PROCESSES)
    THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'This name already exists in DB';
    END IF;
    IF correct_name = wrong_name
    THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Be careful, maybe you made a typo. You introduced the same  name.';
    END IF;
    IF wrong_name NOT IN (SELECT name FROM PROCESSES)
    THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'No changes were made. We could not find the row that you want to update.';
    END IF;
    UPDATE PROCESSES
    SET name = correct_name
    WHERE process_id = (
        SELECT process_id
        FROM PROCESSES
        WHERE name = wrong_name
    );
END //
DELIMITER ;

--Procedure to eliminate a user
DELIMITER //
CREATE PROCEDURE DeleteUser( IN param_fn VARCHAR(20), IN param_ln VARCHAR(20))
BEGIN
    UPDATE USERS
    SET deleted = TRUE
    WHERE user_id = (
        SELECT user_id
        FROM USERS
        WHERE first_name = param_fn AND last_name = param_ln
    );
END //
DELIMITER ;
;

-- Script executions start
DELIMITER //
CREATE PROCEDURE StartExecution(IN param_process_id INT, IN param_user_id SMALLINT, IN param_input MEDIUMBLOB, OUT out_execution_id INT)
BEGIN
    DECLARE new_batch_id INT;
    INSERT INTO BATCHES() VALUES();
    SET new_batch_id = LAST_INSERT_ID();
    INSERT INTO INPUTS(batch_id, input)
    VALUES (new_batch_id, param_input);
    INSERT INTO EXECUTIONS(process_id, user_id, batch_id, status)
    VALUES (param_process_id, param_user_id, new_batch_id, 'RUNNING');
    SET out_execution_id = LAST_INSERT_ID();
END //
DELIMITER ;

--Exexution success
DELIMITER //
CREATE PROCEDURE CompleteExecutionSuccess(IN param_execution_id INT, IN param_output MEDIUMBLOB)
    BEGIN
    IF NOT EXISTS (
    SELECT 1 FROM EXECUTIONS 
    WHERE execution_id = param_execution_id AND status = 'RUNNING'
)
    THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'This execution does not exist or is not currently running.';
    END IF;
    UPDATE EXECUTIONS
    SET status = 'SUCCESS'
    WHERE execution_id = param_execution_id;
    INSERT INTO OUTPUTS(execution_id, output)
    VALUES (param_execution_id, param_output);
END //
DELIMITER ;

--Failed execution
DELIMITER //
CREATE PROCEDURE CompleteExecutionFailure (IN param_execution_id INT, IN param_error_msg VARCHAR(400))
BEGIN
    IF NOT EXISTS (
    SELECT 1 FROM EXECUTIONS 
    WHERE execution_id = param_execution_id AND status = 'RUNNING'
)
    THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'This execution does not exist or is not currently running.';
    END IF;
    UPDATE EXECUTIONS
    SET status = 'FAILED'
    WHERE execution_id = param_execution_id;
    INSERT INTO ERRORS(execution_id, error_msg)
    VALUES (param_execution_id, param_error_msg);
END //
DELIMITER ;
