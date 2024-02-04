#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_ROOT_DIR="$(realpath "${SCRIPT_DIR}/../..")"
COMMON_RESOURCES_DIR="$(realpath "${REPO_ROOT_DIR}/common_resources")"
set -o allexport; source  "${REPO_ROOT_DIR}/.env"; set +o allexport
# ------------------------------------------------------------

SRC_DIR_NAME="${TPCDS_SCALE_GB}gb"

gsutil rm -r gs://${BUCKET_NAME_TPCDS}
gsutil mb -c standard -p ${PROJECT_ID} -l ${REGION_1} -b on gs://${BUCKET_NAME_TPCDS}

# Run from dir with tpc-ds data parent-folder (e.g. from '~/tpc-ds/data' which contains folder '1gb') 
# Make sure that the 'tpcds_sort' function has been invoked (i.e. the data is organized into folders)
time gsutil -m cp -r ${SRC_DIR_NAME} gs://${BUCKET_NAME_TPCDS}
