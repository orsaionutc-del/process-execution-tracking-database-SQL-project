-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database

--SQL query to see all the batches that a user ran

SELECT u.first_name , u.last_name , e.batch_id
FROM EXECUTIONS as e
JOIN
USERS as u
on u.user_id = e.user_id ;

--SQL query to see all the errors a batch has

SELECT *
FROM ERRORS
WHERE execution_id = (
    SELECT execution_id
    FROM EXECUTIONS
    WHERE batch_id = ? ;
)

--SQL query that inserts another user in the user table

INSERT INTO USERS(first_name, last_name)
VALUES ('Ionut','Orsa')

--SQL query that insers another process in the processes table

INSERT INTO PROCESSES(name)
VALUES('VAT Clearin') ;

--SQL query that changes the name intorduced wrong of a user

UPDATE USERS
SET first_name = 'Ionut'
SET last_name = 'Orsa'
WHERE id = '1'

--SQL query that changes the name introduced wrong of a process

UPDATE PROCESSES
SET name = 'VAT Clearing'
WHERE id = (
    SELECT id
    FROM USERS
    WHERE name = 'VAT Clearin'
)

--SQL query to eliminate a user

DELETE FROM users
WHERE user_id = (
    SELECT user_id
    FROM USERS
    WHERE first_name = 'Ionut' AND last_name = 'Orsa'
)

--SQL query that returns input and output for an execution

WITH exec_info AS (
    SELECT
        execution_id,
        batch_id
    FROM EXECUTIONS
    WHERE execution_id = 1
)
SELECT
    i.input,
    o.output
FROM exec_info e
JOIN INPUTS i
    ON e.batch_id = i.batch_id
JOIN OUTPUTS o
    ON e.execution_id = o.execution_id;
