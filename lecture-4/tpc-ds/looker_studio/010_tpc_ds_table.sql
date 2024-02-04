SELECT 
    query_num                       AS query_num,
    end_time - start_time           AS job_runtime_ms,
    bytes_billed/POWER(2,30)        AS gb_billed,          # 1 GB is 2^30 bytes
    bytes_billed/POWER(2,40) * 8.13 AS estimated_cost_usd, # 1 TB is 2^40 bytes; 1 TB price from https://cloud.google.com/bigquery/pricing
 FROM `alk-data-210.bqd_tpcds_results.tpcds_1_gb_2024-02-03_091919`
;