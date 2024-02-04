#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
COMMON_RESOURCES_DIR="$(realpath "${SCRIPT_DIR}"/../common_resources)"
set -o allexport; source  "${SCRIPT_DIR}"/../.env; set +o allexport

OBJECT_NAME="gcp-trust-whitepaper.pdf"

gsutil -m rm -r gs://"${BUCKET_NAME_1}"
gsutil mb -c standard -p "${PROJECT_ID}" -l "${REGION_1}" -b on gs://"${BUCKET_NAME_1}"

gsutil cp "${COMMON_RESOURCES_DIR}"/"${OBJECT_NAME}" gs://"${BUCKET_NAME_1}/data/w2/"
gsutil stat gs://"${BUCKET_NAME_1}"/data/w2/"${OBJECT_NAME}"

gsutil setmeta -h "Generation:123456789" gs://"${BUCKET_NAME_1}"/data/w2/"${OBJECT_NAME}"
gsutil stat gs://"${BUCKET_NAME_1}"/data/w2/"${OBJECT_NAME}" > "${SCRIPT_DIR}"/1_pdf_stat.tmp.txt

gsutil setmeta -h "content-type: " gs://"${BUCKET_NAME_1}"/data/w2/"${OBJECT_NAME}"
gsutil stat gs://"${BUCKET_NAME_1}"/data/w2/"${OBJECT_NAME}" > "${SCRIPT_DIR}"/2_pdf_stat.tmp.txt

diff -y "${SCRIPT_DIR}"/1_pdf_stat.tmp.txt "${SCRIPT_DIR}"/2_pdf_stat.tmp.txt
diff -y --suppress-common-lines "${SCRIPT_DIR}"/1_pdf_stat.tmp.txt "${SCRIPT_DIR}"/2_pdf_stat.tmp.txt

gsutil setmeta -h "x-goog-meta-cloud:google cloud platform" gs://"${BUCKET_NAME_1}"/data/w2/"${OBJECT_NAME}"
gsutil stat gs://"${BUCKET_NAME_1}"/data/w2/"${OBJECT_NAME}" > "${SCRIPT_DIR}"/3_pdf_stat.tmp.txt
diff -y "${SCRIPT_DIR}"/1_pdf_stat.tmp.txt "${SCRIPT_DIR}"/3_pdf_stat.tmp.txt

