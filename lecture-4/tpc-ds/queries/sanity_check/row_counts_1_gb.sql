-- Reference values from page 42:
-- https://www.tpc.org/tpc_documents_current_versions/pdf/tpc-ds_v3.2.0.pdf

ASSERT (

WITH cte1 AS (

SELECT 'call_center'            AS table_name, COUNT(*) - 6        AS diff FROM call_center            UNION ALL
SELECT 'catalog_page'           AS table_name, COUNT(*) - 11718    AS diff FROM catalog_page           UNION ALL
SELECT 'catalog_returns'        AS table_name, COUNT(*) - 144067   AS diff FROM catalog_returns        UNION ALL
SELECT 'catalog_sales'          AS table_name, COUNT(*) - 1441548  AS diff FROM catalog_sales          UNION ALL
SELECT 'customer'               AS table_name, COUNT(*) - 100000   AS diff FROM customer               UNION ALL
SELECT 'customer_address'       AS table_name, COUNT(*) - 50000    AS diff FROM customer_address       UNION ALL
SELECT 'customer_demographics'  AS table_name, COUNT(*) - 1920800  AS diff FROM customer_demographics  UNION ALL
SELECT 'date_dim'               AS table_name, COUNT(*) - 73049    AS diff FROM date_dim               UNION ALL
SELECT 'household_demographics' AS table_name, COUNT(*) - 7200     AS diff FROM household_demographics UNION ALL
SELECT 'income_band'            AS table_name, COUNT(*) - 20       AS diff FROM income_band            UNION ALL
SELECT 'inventory'              AS table_name, COUNT(*) - 11745000 AS diff FROM inventory              UNION ALL
SELECT 'item'                   AS table_name, COUNT(*) - 18000    AS diff FROM item                   UNION ALL
SELECT 'promotion'              AS table_name, COUNT(*) - 300      AS diff FROM promotion              UNION ALL
SELECT 'reason'                 AS table_name, COUNT(*) - 35       AS diff FROM reason                 UNION ALL
SELECT 'ship_mode'              AS table_name, COUNT(*) - 20       AS diff FROM ship_mode              UNION ALL
SELECT 'store'                  AS table_name, COUNT(*) - 12       AS diff FROM store                  UNION ALL
SELECT 'store_returns'          AS table_name, COUNT(*) - 287514   AS diff FROM store_returns          UNION ALL
SELECT 'store_sales'            AS table_name, COUNT(*) - 2880404  AS diff FROM store_sales            UNION ALL
SELECT 'time_dim'               AS table_name, COUNT(*) - 86400    AS diff FROM time_dim               UNION ALL
SELECT 'warehouse'              AS table_name, COUNT(*) - 5        AS diff FROM warehouse              UNION ALL
SELECT 'web_page'               AS table_name, COUNT(*) - 60       AS diff FROM web_page               UNION ALL
SELECT 'web_returns'            AS table_name, COUNT(*) - 71763    AS diff FROM web_returns            UNION ALL
SELECT 'web_sales'              AS table_name, COUNT(*) - 719384   AS diff FROM web_sales              UNION ALL
SELECT 'web_site'               AS table_name, COUNT(*) - 30       AS diff FROM web_site

)

SELECT SUM(diff) FROM cte1) = 0 AS 'Row counts for TPC-DS tables must be the same as in the documentation';