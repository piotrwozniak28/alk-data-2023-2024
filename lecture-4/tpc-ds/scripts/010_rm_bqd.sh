#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_ROOT_DIR="$(realpath "${SCRIPT_DIR}/../../..")"
COMMON_RESOURCES_DIR="$(realpath "${REPO_ROOT_DIR}/common_resources")"
set -o allexport; source  "${REPO_ROOT_DIR}/.env"; set +o allexport
# ------------------------------------------------------------

bq rm -r -f -d ${PROJECT_ID}:${BQD_TPCDS_EXTERNAL_AUTODETECT}
bq rm -r -f -d ${PROJECT_ID}:${BQD_TPCDS_EXTERNAL_NOAUTODETECT}
bq rm -r -f -d ${PROJECT_ID}:${BQD_TPCDS_NATIVE_AUTODETECT}
bq rm -r -f -d ${PROJECT_ID}:${BQD_TPCDS_NATIVE_NOAUTODETECT}
bq rm -r -f -d ${PROJECT_ID}:${BQD_TPCDS_RESULTS}