-- Reference values from page 42:
-- https://www.tpc.org/tpc_documents_current_versions/pdf/tpc-ds_v3.2.0.pdf

SELECT bq.table_id, row_count, docs_row_count  
  FROM `__TABLES__` bq
  JOIN (
SELECT 'call_center'            AS table_id, 6        AS docs_row_count UNION ALL
SELECT 'catalog_page'           AS table_id, 11718    AS docs_row_count UNION ALL
SELECT 'catalog_returns'        AS table_id, 144067   AS docs_row_count UNION ALL
SELECT 'catalog_sales'          AS table_id, 1441548  AS docs_row_count UNION ALL
SELECT 'customer'               AS table_id, 100000   AS docs_row_count UNION ALL
SELECT 'customer_address'       AS table_id, 50000    AS docs_row_count UNION ALL
SELECT 'customer_demographics'  AS table_id, 1920800  AS docs_row_count UNION ALL
SELECT 'date_dim'               AS table_id, 73049    AS docs_row_count UNION ALL
SELECT 'household_demographics' AS table_id, 7200     AS docs_row_count UNION ALL
SELECT 'income_band'            AS table_id, 20       AS docs_row_count UNION ALL
SELECT 'inventory'              AS table_id, 11745000 AS docs_row_count UNION ALL
SELECT 'item'                   AS table_id, 18000    AS docs_row_count UNION ALL
SELECT 'promotion'              AS table_id, 300      AS docs_row_count UNION ALL
SELECT 'reason'                 AS table_id, 35       AS docs_row_count UNION ALL
SELECT 'ship_mode'              AS table_id, 20       AS docs_row_count UNION ALL
SELECT 'store'                  AS table_id, 12       AS docs_row_count UNION ALL
SELECT 'store_returns'          AS table_id, 287514   AS docs_row_count UNION ALL
SELECT 'store_sales'            AS table_id, 2880404  AS docs_row_count UNION ALL
SELECT 'time_dim'               AS table_id, 86400    AS docs_row_count UNION ALL
SELECT 'warehouse'              AS table_id, 5        AS docs_row_count UNION ALL
SELECT 'web_page'               AS table_id, 60       AS docs_row_count UNION ALL
SELECT 'web_returns'            AS table_id, 71763    AS docs_row_count UNION ALL
SELECT 'web_sales'              AS table_id, 719384   AS docs_row_count UNION ALL
SELECT 'web_site'               AS table_id, 30       AS docs_row_count
) docs 
    ON bq.table_id = docs.table_id;