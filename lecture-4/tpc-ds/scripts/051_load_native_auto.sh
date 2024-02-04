#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_ROOT_DIR="$(realpath "${SCRIPT_DIR}/../../..")"
COMMON_RESOURCES_DIR="$(realpath "${REPO_ROOT_DIR}/common_resources")"
set -o allexport; source  "${REPO_ROOT_DIR}/.env"; set +o allexport
# ------------------------------------------------------------

bq rm -r -f -d ${PROJECT_ID}:${BQD_TPCDS_NATIVE_AUTODETECT}
bq --project_id=${PROJECT_ID} --location=${REGION_1} mk ${BQD_TPCDS_NATIVE_AUTODETECT}

# Create call_center table with schema autodetect
bq --project_id=${PROJECT_ID} \
load \
--autodetect \
--source_format=CSV \
--null_marker '' \
--field_delimiter '|' \
${BQD_TPCDS_NATIVE_AUTODETECT}.call_center \
gs://${BUCKET_NAME_TPCDS}/${TPCDS_SCALE_GB}gb/call_center/*

# Get tpcds folder names from GCS
gsutil ls "gs://${BUCKET_NAME_TPCDS}/${TPCDS_SCALE_GB}gb"

TPCDS_TABLE_NAMES=(
call_center
)

# Create listed tpcds tables with schema autodetect
for table_name in ${TPCDS_TABLE_NAMES[@]}
do
    echo "Processing ${table_name}..."

    bq --project_id=${PROJECT_ID} \
    load \
    --autodetect \
    --source_format=CSV \
    --null_marker '' \
    --field_delimiter '|' \
    ${BQD_TPCDS_NATIVE_AUTODETECT}.${table_name} \
    gs://${BUCKET_NAME_TPCDS}/${TPCDS_SCALE_GB}gb/${table_name}/*
done
