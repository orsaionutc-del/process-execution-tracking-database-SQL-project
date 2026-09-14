-- Identifies the top 3 active processes with the highest number of failed executions
-- Business use: Helps the team prioritize processes that require improvement

WITH error_count AS (
  SELECT p.name, 
    COUNT(e.execution_id) AS error_num
  FROM EXECUTIONS AS e
  JOIN PROCESSES AS p
    ON p.process_id = e.process_id
  WHERE e.status = 'FAILED' AND p.deleted = 0
  GROUP BY p.process_id, p.name
  ),

ranking AS (
  SELECT name, 
    error_num, 
    ROW_NUMBER() OVER ( ORDER BY error_num DESC ) AS ranks
  FROM error_count 
  )

SELECT name, 
  error_num
FROM ranking
WHERE ranks < 4
ORDER BY ranks;

-- Calculates the failure rate for each active process over the last 14 days.
-- Business use: Helps monitor recent process reliability and identify processes with high failure rates.

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
  CONCAT(ROUND(e.error_num/t.total_proc*100,2),' %') AS fail_percentage
FROM error_count AS e
JOIN total_count AS t
  ON e.name = t.name
ORDER BY ROUND(e.error_num/t.total_proc*100,2) DESC;

-- Ranks users based on the number of distinct batches they started.
-- Business use: Provides visibility into user activity and process usage.

WITH b_count AS (
  SELECT 
    COALESCE(u.user_id,'Unknown') AS user_id, 
    COALESCE(CONCAT(u.first_name,' ',u.last_name),'Unknown') AS full_name, 
  COUNT(DISTINCT(e.batch_id)) AS batch_count
  FROM EXECUTIONS AS e
  LEFT JOIN USERS AS u 
    ON e.user_id = u.user_id
  GROUP BY u.user_id, u.first_name, u.last_name
)

SELECT user_id, 
  full_name, 
  batch_count, 
  DENSE_RANK() OVER (ORDER BY batch_count DESC) AS ranking
FROM b_count
ORDER BY  DENSE_RANK() OVER (ORDER BY batch_count DESC);

-- Identifies the most frequent error for each active process. 
-- Business use: Helps identify the main issue affecting each process and prioritize troubleshooting.

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
  DENSE_RANK() OVER (PARTITION BY name ORDER BY number_of_apparitions DESC) AS ranking
FROM diff_error_for_processes
)

SELECT 
  name, 
  error_msg, 
  number_of_apparitions
FROM ranking
WHERE ranking <= 1;

-- Calculates the percentage distribution of each error type within each process. 
-- Business use: Helps understand which errors contribute most to process failures.

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
  ON d.name = t.name;

-- Identifies existing processes that have never been executed. 
-- Business use: Helps identify unused processes and potential candidates for review or removal.

SELECT p.process_id, 
  p.name, 
  p.deleted, 
  p.created_at
FROM PROCESSES AS p
LEFT JOIN EXECUTIONS AS e
ON p.process_id = e.process_id
WHERE e.process_id IS NULL;

-- Identifies processes with a failure rate above 30% for three consecutive batches. 
-- Business use: Helps detect persistent reliability problems that require attention.

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
    LAG(last_process_status) OVER (PARTITION BY process_id ORDER BY executed_at) AS sec_last_proc_status
  FROM percent
  ),
  
problems AS (
  SELECT process_id,
    batch_id,
    CASE
    WHEN fail_percentage > 30 AND last_process_status > 30 AND sec_last_proc_status > 30 THEN TRUE
    ELSE FALSE END AS consecutive_fails,
    executed_at
  FROM percentage
)

SELECT pr.process_id,
  p.batch_id,
  pr.name,
  pr.deleted,
  p.executed_at
FROM problems AS p
JOIN PROCESSES AS pr
  ON p.process_id = pr.process_id
WHERE consecutive_fails = TRUE;

-- Calculates the number of executions per weekday and compares the volume with the previous day. 
-- Business use: Helps monitor execution patterns and identify significant changes in process activity.

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

-- Compares each batch's execution time with the average execution time of its process. 
-- Business use: Helps identify unusually slow batches and potential performance degradation.

WITH avg_batch AS (
  SELECT
    process_id,
    batch_id,
    TIMESTAMPDIFF(
      SECOND,
      MIN(executed_at),
      MAX(executed_at)
    ) AS batch_exec_time
  FROM EXECUTIONS
  GROUP BY process_id, batch_id
  HAVING COUNT(*) > 1
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
  b.batch_exec_time,
  p.avg_process_time,
  CONCAT(
    ROUND(((b.batch_exec_time / p.avg_process_time) - 1) * 100,2),'%') AS compared_to_average,
  CASE
    WHEN ((b.batch_exec_time / p.avg_process_time) - 1) * 100 > 30
      THEN 'ALERT'
    ELSE 'OK'
  END AS alert_column
FROM avg_batch AS b
JOIN avg_process AS p
  ON b.process_id = p.process_id
JOIN PROCESSES AS pr
  ON p.process_id = pr.process_id;

-- Provides key performance indicators for each active process, including executions, failures, failure rate and status. 
-- Business use: Provides a high-level overview of process health for monitoring and BI dashboards.

WITH process_kpi AS (
    SELECT
        p.process_id,
        p.name,
        COUNT(DISTINCT e.batch_id) AS total_batches,
        COUNT(CASE WHEN e.status = 'FAILED' THEN 1 END) AS failed_executions,
        COUNT(e.execution_id) AS total_executions,
        MAX(e.executed_at) AS last_execution
    FROM PROCESSES AS p
    LEFT JOIN EXECUTIONS AS e
        ON p.process_id = e.process_id
    WHERE p.deleted = FALSE
    GROUP BY p.process_id, p.name
)
  
SELECT
    process_id,
    name,
    total_batches,
    total_executions,
    failed_executions,
    COALESCE(ROUND(failed_executions / NULLIF(total_executions, 0) * 100,2),0) AS failure_rate,
    COALESCE(last_execution,0),
    CASE
    WHEN failed_executions / NULLIF(total_executions, 0) > 0.30 THEN 'CRITICAL'
    WHEN failed_executions / NULLIF(total_executions, 0) > 0.10 THEN 'WARNING'
    WHEN total_batches = 0 THEN 'NEVER USED'
    ELSE 'HEALTHY'
    END AS process_status
FROM process_kpi
ORDER BY failure_rate DESC;






