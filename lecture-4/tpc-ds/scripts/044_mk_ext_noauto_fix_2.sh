#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_ROOT_DIR="$(realpath "${SCRIPT_DIR}/../../..")"
COMMON_RESOURCES_DIR="$(realpath "${REPO_ROOT_DIR}/common_resources")"
set -o allexport; source  "${REPO_ROOT_DIR}/.env"; set +o allexport
# ------------------------------------------------------------
TABLE_DEFINITIONS_DIR="$(realpath ${SCRIPT_DIR}/../table_definitions)"

mkdir -p ${TABLE_DEFINITIONS_DIR}

bq rm -r -f -d ${PROJECT_ID}:${BQD_TPCDS_EXTERNAL_NOAUTODETECT}
bq --project_id=${PROJECT_ID} --location=${REGION_1} mk ${BQD_TPCDS_EXTERNAL_NOAUTODETECT}

table_name="call_center"
bq mkdef --project_id=${PROJECT_ID} --noautodetect --source_format=CSV \
"gs://${BUCKET_NAME_TPCDS}/${TPCDS_SCALE_GB}gb/${table_name}/*" \
cc_call_center_sk:integer,\
cc_call_center_id:string,\
cc_rec_start_date:string,\
cc_rec_end_date:string,\
cc_closed_date_sk:integer,\
cc_open_date_sk:integer,\
cc_name:string,\
cc_class:string,\
cc_employees:integer,\
cc_sq_ft:integer,\
cc_hours:string,\
cc_manager:string,\
cc_mkt_id:integer,\
cc_mkt_class:string,\
cc_mkt_desc:string,\
cc_market_manager:string,\
cc_division:integer,\
cc_division_name:string,\
cc_company:integer,\
cc_company_name:string,\
cc_street_number:string,\
cc_street_name:string,\
cc_street_type:string,\
cc_suite_number:string,\
cc_city:string,\
cc_county:string,\
cc_state:string,\
cc_zip:string,\
cc_country:string,\
cc_gmt_offset:float,\
cc_tax_percentage:float \
| jq '.schema.fields += [{"name": "test", "type": "BOOL"}]' \
> ${TABLE_DEFINITIONS_DIR}/tdef_tpcds_ext_noauto_${table_name}_fix_2.json

sed -i 's/"fieldDelimiter": ","/"fieldDelimiter": "|"/' ${TABLE_DEFINITIONS_DIR}/tdef_tpcds_ext_noauto_${table_name}_fix_2.json
bq --project_id=${PROJECT_ID} --location=${REGION_1} mk --external_table_definition=${TABLE_DEFINITIONS_DIR}/tdef_tpcds_ext_noauto_${table_name}_fix_2.json ${BQD_TPCDS_EXTERNAL_NOAUTODETECT}.${table_name}_fix_2
