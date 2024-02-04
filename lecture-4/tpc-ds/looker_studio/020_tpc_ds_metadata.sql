WITH cte AS (
    SELECT 
        total_bytes_billed/POWER(2,30)                                                                     AS gb_billed,
        total_bytes_billed/POWER(2,40) * 8.13                                                              AS estimated_cost_usd,
        TIMESTAMP_DIFF(end_time, start_time, MILLISECOND)                                                  AS job_runtime_ms,
        (SELECT value FROM UNNEST(labels) WHERE key = "benchmark_name")                                    AS benchmark_name,
        (SELECT PARSE_DATETIME('%Y-%m-%d_%H%M%S', value) FROM UNNEST(labels) WHERE key = "benchmark_date") AS benchmark_date,
        (SELECT value FROM UNNEST(labels) WHERE key = "query_num")                                         AS query_num,
        (SELECT value FROM UNNEST(labels) WHERE key = "benchmark_scale_gb")                                AS benchmark_scale_gb,
        (SELECT value FROM UNNEST(labels) WHERE key = "benchmark_name_full")                               AS benchmark_name_full,
        (SELECT value FROM UNNEST(labels) WHERE key = "benchmark_name_short")                              AS benchmark_name_short
        ,*
    FROM 
        `proj-tmp-015.region-europe-central2.INFORMATION_SCHEMA.JOBS_BY_PROJECT`
)
SELECT
    benchmark_name_full,
    benchmark_date,
    query_num,
    job_runtime_ms,
    gb_billed,
    estimated_cost_usd,
FROM 
    cte 
WHERE 
    benchmark_name_short = 'tpcds' 
AND 
    benchmark_scale_gb = '1'
;
