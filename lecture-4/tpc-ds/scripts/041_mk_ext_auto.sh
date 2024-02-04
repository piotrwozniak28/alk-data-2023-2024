#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_ROOT_DIR="$(realpath "${SCRIPT_DIR}/../../..")"
COMMON_RESOURCES_DIR="$(realpath "${REPO_ROOT_DIR}/common_resources")"
set -o allexport; source  "${REPO_ROOT_DIR}/.env"; set +o allexport
# ------------------------------------------------------------
TABLE_DEFINITIONS_DIR="$(realpath ${SCRIPT_DIR}/../table_definitions)"

mkdir -p ${TABLE_DEFINITIONS_DIR}

bq rm -r -f -d ${PROJECT_ID}:${BQD_TPCDS_EXTERNAL_AUTODETECT}
bq --project_id=${PROJECT_ID} --location=${REGION_1} mk ${BQD_TPCDS_EXTERNAL_AUTODETECT}

TPCDS_TABLE_NAMES=(
call_center
)

for table_name in ${TPCDS_TABLE_NAMES[@]}
do
    echo "Creating table definition for ${table_name}..."
    bq --project_id=${PROJECT_ID} mkdef --autodetect --source_format=CSV "gs://${BUCKET_NAME_TPCDS}/${TPCDS_SCALE_GB}gb/${table_name}/*" > ${TABLE_DEFINITIONS_DIR}/tdef_tpcds_ext_auto_${table_name}.json

    echo "Creating external table ext_${table_name}..."
    bq mk --project_id=${PROJECT_ID} --location=${REGION_1} --external_table_definition=${TABLE_DEFINITIONS_DIR}/tdef_tpcds_ext_auto_${table_name}.json ${BQD_TPCDS_EXTERNAL_AUTODETECT}.${table_name}
done
