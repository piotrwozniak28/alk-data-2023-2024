#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_ROOT_DIR="$(realpath "${SCRIPT_DIR}/../..")"
COMMON_RESOURCES_DIR="$(realpath "${REPO_ROOT_DIR}/common_resources")"
set -o allexport; source  "${REPO_ROOT_DIR}/.env"; set +o allexport

# ------------------------------------------------------------

OBJECT_NAME="1GB_tmp_file"
TMP_DIR=$(mktemp -d 045_writing_strategy.tmp.XXX -p "${SCRIPT_DIR}")

gsutil rm -r gs://"${BUCKET_NAME_1}"
gsutil mb -c standard -p "${PROJECT_ID}" -l "${REGION_1}" -b on gs://"${BUCKET_NAME_1}"

fallocate -l 1GB ${TMP_DIR}/${OBJECT_NAME}
du -sh * | sort

# ----------------------------
# Resumable (default)
# [GSUtil]
# resumable_threshold = 8388608
# ----------------------------
time gsutil cp ${TMP_DIR}/${OBJECT_NAME} gs://${BUCKET_NAME_1}/{OBJECT_NAME}
# real is wall clock time - time from start to finish of the call.
# user is the amount of CPU time spent in user-mode code (outside the kernel) within the process.
# sys is the amount of CPU time spent in the kernel within the process.
# src:https://stackoverflow.com/a/556411

# Remove tracker files (used by resumable upload)
rm ~/.gsutil/tracker-files/*

# ----------------------------
# Non-resumable upload
# ----------------------------
# https://cloud.google.com/storage/docs/boto-gsutil
gsutil version -l
edit ~/.boto
# [GSUtil]
# resumable_threshold = 999999999999999

# ----------------------------
# Paralell composite upload(parallel_composite_upload_threshold=0, parallel_thread_count=4, parallel_process_count=1)
# ----------------------------
# See repo for recommendations
# https://github.com/GoogleCloudPlatform/gsutil/blob/e886dc4da47463d04c7a623720cbb8e317c71ba0/gslib/commands/config.py
time gsutil -o GSUtil:parallel_composite_upload_threshold=100M cp ${TMP_DIR}/${OBJECT_NAME} gs://${BUCKET_NAME_1}
time gsutil -o 'GSUtil:parallel_thread_count=4' -o 'GSUtil:parallel_process_count=1' cp gs://${BUCKET_NAME_1}/${OBJECT_NAME} ${TMP_DIR}/${OBJECT_NAME}-2
# check_hashes = never

# Use paralell composite upload only with Standard storage class
RETENTION_POLICY_TIME_DURATION=30
gsutil retention set ${RETENTION_POLICY_TIME_DURATION}s gs://${BUCKET_NAME_1}
time gsutil -o GSUtil:parallel_composite_upload_threshold=100M cp ${TMP_DIR}/${OBJECT_NAME} gs://${BUCKET_NAME_1}

# ----------------------------
# Paralell upload(parallel_thread_count=4, parallel_process_count=1)
# ----------------------------
time gsutil -m cp ${TMP_DIR}/${OBJECT_NAME} gs://${BUCKET_NAME_1}

fallocate -l 1GB ${TMP_DIR}/${OBJECT_NAME}
split -n 10000 ${TMP_DIR}/${OBJECT_NAME} --numeric-suffixes=1
mkdir -p ${OBJECT_NAME}_pieces
mv x* ${OBJECT_NAME}_pieces/
cd ${OBJECT_NAME}_pieces
ls | wc -l

time gsutil cp -r ${SCRIPT_DIR}/${OBJECT_NAME}_pieces/* gs://${BUCKET_NAME_1}/${OBJECT_NAME}_pieces/standard/
time gsutil -m cp -r ${SCRIPT_DIR}/${OBJECT_NAME}_pieces/* gs://${BUCKET_NAME_1}/${OBJECT_NAME}_pieces/paralell/

