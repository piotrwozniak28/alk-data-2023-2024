#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
COMMON_RESOURCES_DIR="$(realpath "${SCRIPT_DIR}"/../common_resources)"
set -o allexport; source  "${SCRIPT_DIR}"/../.env; set +o allexport

OBJECT_NAME="spotify_logo.png"

gsutil rm -r gs://"${BUCKET_NAME_2}"
gsutil mb -c standard -p "${PROJECT_ID}" -l "${REGION_2}" -b on gs://"${BUCKET_NAME_2}"

gsutil iam ch allUsers:objectViewer gs://${BUCKET_NAME_2}

gsutil cp "${COMMON_RESOURCES_DIR}"/"${OBJECT_NAME}" gs://"${BUCKET_NAME_2}"/"${OBJECT_NAME}_1"
gsutil cp "${COMMON_RESOURCES_DIR}"/"${OBJECT_NAME}" gs://"${BUCKET_NAME_2}"/"${OBJECT_NAME}_2"

gsutil setmeta -h "cache-control:public, max-age=3600" gs://"${BUCKET_NAME_2}"/"${OBJECT_NAME}_1"
gsutil setmeta -h "cache-control:no-store" gs://"${BUCKET_NAME_2}"/"${OBJECT_NAME}_2"
