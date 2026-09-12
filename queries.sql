-- SQL query that returns top 3 processes with the most failed executions and the number of failed executions. This helps the team to target what needs to be improved

WITH error_count AS (
  SELECT p.name, 
    COUNT(p.process_id) AS error_num
  FROM EXECUTIONS AS e
  JOIN PROCESSES AS p
    ON p.process_id = e.process_id
  WHERE e.status = 'FAILED' AND p.deleted = 0
  GROUP BY p.process_id, p.name
  ),

ranking AS (
  SELECT name, 
    error_num, 
    ROW_NUMBER() OVER ( ORDER BY error_num DESC ) AS rank
  FROM error_count 
  )

SELECT name, 
  error_num
FROM ranking
WHERE rank < 4
ORDER BY rank;

-- Failure rate per process from the last two weeks to check what process should be improved due to recent changes

WITH error_count AS (
  SELECT p.name,
    COUNT(p.process_id) AS error_num
  FROM EXECUTIONS AS e
  JOIN PROCESSES AS p
    ON p.process_id = e.process_id
  WHERE e.status = 'FAILED' AND p.deleted = 0 AND DATEDIFF(CURRENT_DATE,e.executed_at) < 14
  GROUP BY p.process_id, p.name
  ),

total_count AS (
  SELECT p.name, 
    COUNT(p.process_id) AS total_proc
  FROM EXECUTIONS AS e
  JOIN PROCESSES AS p
    ON p.process_id = e.process_id
  WHERE p.deleted = 0 AND DATEDIFF(CURRENT_DATE,e.executed_at) < 14
  GROUP BY p.process_id ,p.name
  )

SELECT e.name, 
  ROUND(e.error_num/t.total_proc*100,2) AS fail_percentage
FROM error_count AS e
JOIN total_count AS t
  ON e.name = t.name
ORDER BY ROUND(e.error_num/t.total_proc*100,2) DESC;

-- How many scripts each user started (ranking) descending order

WITH b_count AS (
  SELECT 
    COALESCE(u.user_id,'Unknown') AS user_id, 
    COALESCE(CONCAT(u.first_name,u.last_name),'Unknown') AS full_name, 
  COUNT(DISTINCT(e.batch_id)) AS batch_count
  FROM EXECUTIONS AS e
  LEFT JOIN USERS AS u 
    ON e.user_id = u.user_id
  GROUP BY u.user_id, u.first_name, u.last_name
)

SELECT user_id, 
  full_name, 
  batch_count, 
  DENSE_RANK() OVER (ORDER BY batch_count DESC) AS rank
FROM b_count
ORDER BY  DENSE_RANK() OVER (ORDER_BY batch_count DESC);

-- What is the most common error for each process that was not already deleted from DB ?

WITH diff_error_for_processes AS (
  SELECT 
    p.name, 
    er.error_msg, 
    COUNT(er.error_id) AS number_of_apparitions
  FROM PROCESSES AS p
  JOIN EXECUTIONS AS e
    ON p.process_id = e.process_id
  JOIN ERRORS AS er
    ON e.execution_id = er.execution_id
  WHERE p.deleted = FALSE
  GROUP BY p.name, er.error_msg
),

ranking AS (
SELECT
  name,
  error_msg,
  number_of_apparitions,
  DENSE_RANK() OVER (PARTITION BY name ORDER BY number_of_apparitions DESC) AS rank
FROM diff_error_for_processes
)

SELECT 
  name, 
  error_msg, 
  number_of_apparitions
FROM ranking
WHERE rank <= 1;

-- percentage distribution of each error type per process

WITH diff_error_for_processes AS (
  SELECT p.name, 
    er.error_msg, 
    COUNT(er.error_id) as number_of_apparitions
  FROM PROCESSES AS p
  JOIN EXECUTIONS AS e
    ON p.process_id = e.process_id
  JOIN ERRORS AS er
    ON e.execution_id = er.execution_id
  WHERE p.deleted = FALSE
  GROUP BY p.name, er.error_msg
),

  total_errors_per_process AS (
  SELECT p.name, 
    COUNT(p.name) AS total_errors
  FROM PROCESSES AS p
  JOIN EXECUTIONS AS e
    ON p.process_id = e.process_id
  JOIN ERRORS AS er
    ON e.execution_id = er.execution_id
  WHERE p.deleted = FALSE
  GROUP BY p.name
  )

SELECT d.name, 
  d.error_msg, 
  CONCAT(ROUND(d.number_of_apparitions/t.total_errors * 100 , 2), '%') AS percentage_of_total_errors
FROM diff_error_for_processes AS d
JOIN total_errors_per_process AS t
  ON d.name = t.name

-- Existent processes with no executions

SELECT p.process_id, 
  p.name, 
  p.deleted, 
  p.created_at
FROM PROCESSES AS p
LEFT JOIN EXECUTIONS AS e
ON p.process_id = e.process_id
WHERE e.process_id IS NULL

-- batches where the failure rate exceeded 30% for three consecutive batches of the same process

WITH total_ex AS (
  SELECT user_id,
    process_id,
    batch_id,
    MIN(executed_at) AS executed_at,
    COUNT(execution_id) AS total_execution_count
  FROM EXECUTIONS
  GROUP BY user_id, batch_id, process_id
  ),

total_fails AS (
  SELECT user_id,
    batch_id,
    COUNT(execution_id) AS total_failed_execution_count
  FROM EXECUTIONS
  WHERE status = 'FAILED'
  GROUP BY user_id, batch_id
  ),

percent AS (
  SELECT e.user_id, 
    e.batch_id,
    e.process_id,
    e.executed_at, 
    ROUND(COALESCE(f.total_failed_execution_count,0) / e.total_execution_count * 100,2) AS fail_percentage,
    LAG(ROUND(COALESCE(f.total_failed_execution_count,0) / e.total_execution_count * 100,2)) OVER (PARTITION BY e.process_id ORDER BY e.executed_at) AS last_process_status
  FROM total_fails AS f
  RIGHT JOIN total_ex AS e
    ON f.batch_id = e.batch_id
  ),

percentage AS (
  SELECT *,
    LAG(last_process_status) OVER (PARTITION BY process_id ORDER BY executed_at)
  
  AS sec_last_proc_status
  FROM percent
  ),
  
problems AS (
  SELECT process_id,
    CASE
    WHEN fail_percentage > 30 AND last_process_status > 30 AND sec_last_process_status > 30 THEN TRUE
    ELSE FALSE END AS consecutive_fails,
    executed_at
  FROM percentage
)

SELECT pr.process_id,
  pr.name,
  pr.deleted,
  p.executed_at
FROM problems AS p
JOIN PROCESSES AS pr
  ON p.process_id = pr.process_id
WHERE consecutive_fails = TRUE;

-- daily batches execution volume per weekday and movement compared to previous weekday

WITH daily_vol AS (
  SELECT 
    process_id, 
    WEEKDAY(executed_at) AS day_of_the_week,
    COUNT(process_id) AS number_of_executions
  FROM EXECUTIONS
  GROUP BY process_id, WEEKDAY(executed_at)
),

days AS (  
  SELECT 
    p.process_id,
    p.name,
    d.number_of_executions,
    d.day_of_the_week,
    d.day_of_the_week + 1 AS day_num
  FROM daily_vol AS d
  JOIN PROCESSES AS p
    ON d.process_id = p.process_id
),

daily_movement AS (
  SELECT 
    process_id,
    name,
    number_of_executions,
    day_of_the_week,
    day_num,
    COALESCE(
      LAG(number_of_executions) OVER (PARTITION BY process_id ORDER BY day_num),
      (
        SELECT d2.number_of_executions
        FROM days AS d2
        WHERE d2.day_num = 7
          AND d2.process_id = d1.process_id
      )
    ) AS previous_day_executions
  FROM days AS d1
)

SELECT 
  process_id,
  name,
  number_of_executions,
  CASE
    WHEN day_of_the_week = 0 THEN 'Monday'
    WHEN day_of_the_week = 1 THEN 'Tuesday'
    WHEN day_of_the_week = 2 THEN 'Wednesday'
    WHEN day_of_the_week = 3 THEN 'Thursday'
    WHEN day_of_the_week = 4 THEN 'Friday'
    WHEN day_of_the_week = 5 THEN 'Saturday'
    ELSE 'Sunday'
  END AS day_of_the_week,
  CONCAT(ROUND((number_of_executions - previous_day_executions) / previous_day_executions * 100,2),'%') AS previous_day_movement
FROM daily_movement
ORDER BY process_id, day_num;

-- Per process average execution time / SUCCESFUL batch compared with the actual execution time of one batch + alert column for e difference bigger than for batches with 15% more execution time than the average

WITH succes_filter AS (
  SELECT
    process_id,
    batch_id,
    executed_at,
    CASE
    WHEN status = 'SUCCES' THEN '0'
    ELSE '1' END filter
  FROM EXECUTIONS
  ),
  
avg_batch AS (
  SELECT
    process_id,
    batch_id,
    AVG(TIME_TO_SECONDS(DATEDIFF(MAX(executed_at)-MIN(executed_at)))) AS batch_exec_time
  FROM succes_filter
  WHERE SUM(filter) = 0
  GROUP BY batch_id, process_id
  ),

avg_process AS (
  SELECT 
    process_id,
    AVG(batch_exec_time) AS avg_process_time
  FROM avg_batch
  GROUP BY process_id
  )

SELECT
  p.process_id, 
  pr.name,
  b.batch_id,
  CONCAT(ROUND((1 - (b.batch_exec_time/p.avg_process_time))*100,2),'%') AS compared_to average,
  CASE
  WHEN ROUND((1 - (b.batch_exec_time/p.avg_process_time))*100,2) < 85 THEN 'ALERT'
  ELSE 'OK' END AS alert_column
FROM avg_batch AS b
JOIN avg_process AS p
ON b.process_id = p.process_id
JOIN PROCESSES AS pr
ON p.process_id = pr.process_id

  






