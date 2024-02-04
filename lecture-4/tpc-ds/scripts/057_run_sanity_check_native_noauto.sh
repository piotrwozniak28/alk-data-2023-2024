#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_ROOT_DIR="$(realpath "${SCRIPT_DIR}/../../..")"
COMMON_RESOURCES_DIR="$(realpath "${REPO_ROOT_DIR}/common_resources")"
set -o allexport; source  "${REPO_ROOT_DIR}/.env"; set +o allexport
# ------------------------------------------------------------

for QUERY_FILE in ${SCRIPT_DIR}/../queries/sanity_check/*.sql;
do
    echo "Running ${QUERY_FILE}'"

    cat "${QUERY_FILE}" \
      | bq \
        --project_id=${PROJECT_ID} \
        --location=${REGION_1} \
        --dataset_id=${BQD_TPCDS_NATIVE_NOAUTODETECT} \
        query \
        --use_cache=false \
        --use_legacy_sql=false \
        --batch=false \
        --format=pretty
done
