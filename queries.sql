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

-- SQL query that returns top 3 processes with the most failed executions and the number of failed executions so the dev team can improve them

WITH error_count AS (
SELECT p.name, COUNT(p.process_id) AS error_num
FROM EXECUTIONS AS e
JOIN PROCESSES AS p
  ON p.process_id = e.process_id
WHERE e.status = 'FAILED' AND p.deleted = 0
GROUP BY p.process_id ),

ranking AS (
  SELECT name, error_num, ROW_NUMBER() OVER ( ORDER BY error_num DESC ) AS rank
  FROM error_count 
  )

SELECT name, error_num
FROM ranking
WHERE rank < 4
ORDER BY rank

-- Failure rate per process from the last two weeks to check what process should be removed from prod due to recent changes

WITH error_count AS (
SELECT p.name, COUNT(p.process_id) AS error_num, e.executed_at
FROM EXECUTIONS AS e
JOIN PROCESSES AS p
  ON p.process_id = e.process_id
WHERE e.status = 'FAILED' AND p.deleted = 0 AND DATEDIFF(CURRENT_DATE,e.executed_at) < 14
GROUP BY p.process_id ),

total_count AS (SELECT p.name, COUNT(p.process_id) AS total_proc, e.executed_at
FROM EXECUTIONS AS e
JOIN PROCESSES AS p
  ON p.process_id = e.process_id
WHERE p.deleted = 0 AND DATEDIFF(CURRENT_DATE,e.executed_at) < 14
GROUP BY p.process_id )

SELECT e.name, ROUND(e.error_num/t.total_proc*100,2) AS fail_percentage
FROM error_count AS e
JOIN total_count AS t
ON e.name = t.name
ORDER BY ROUND(e.error_num/t.total_proc*100,2) DESC

-- Ranking of the batches started by all the users

WITH b_count AS (
SELECT 
COALESCE(u.user_id,'Unknown') AS user_id, 
COALESCE(CONCAT(u.first_name,u.last_name),'Unknown') AS full_name, 
COUNT(DISTINCT(e.batch_id)) AS batch_count
FROM EXECUTIONS AS e
LEFT JOIN USERS AS u 
ON e.user_id = u.user_id
GROUP BY e.batch_id
)

SELECT user_id, full_name, batch_count, DENSE_RANK() OVER (ORDER_BY batch_count) AS rank
FROM b_count
ORDER BY  DENSE_RANK() OVER (ORDER_BY batch_count) DESC


