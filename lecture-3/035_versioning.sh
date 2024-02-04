#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
COMMON_RESOURCES_DIR="$(realpath "${SCRIPT_DIR}"/../common_resources)"
set -o allexport; source  "${SCRIPT_DIR}"/../.env; set +o allexport

OBJECT_NAME="spotify_logo.png"
TMP_DIR=$(mktemp -d 035_versioning.tmp.XXX -p "${SCRIPT_DIR}")
# ------------------------------------------------------------

gsutil rm -r gs://"${BUCKET_NAME_1}"
gsutil mb -c standard -p "${PROJECT_ID}" -l "${REGION_1}" -b on gs://"${BUCKET_NAME_1}"

gsutil versioning set on gs://${BUCKET_NAME_1}

# Copy the file
gsutil cp "${COMMON_RESOURCES_DIR}"/"${OBJECT_NAME}" gs://"${BUCKET_NAME_1}"

# Write down object's details
gsutil ls -L gs://${BUCKET_NAME_1} > ${TMP_DIR}/1_bkt_lsl.tmp.txt

# Copy the same file again
gsutil cp "${COMMON_RESOURCES_DIR}"/"${OBJECT_NAME}" gs://"${BUCKET_NAME_1}"

# Write down object's details for comparison
gsutil ls -L gs://${BUCKET_NAME_1} > ${TMP_DIR}/2_bkt_lsl.tmp.txt

# Compare 2 versions
diff -y 1_bkt_lsl.tmp.txt 2_bkt_lsl.tmp.txt

# Noncurrent object now has a 'Noncurrent time' metadata key
gsutil ls -L gs://${BUCKET_NAME_1}/${OBJECT_NAME}#<noncurrent object generation number>

gsutil setmeta -h "x-goog-meta-cloud:gcp" gs://${BUCKET_NAME_1}/${OBJECT_NAME}
gsutil ls -L gs://${BUCKET_NAME_1} > ${TMP_DIR}/3_bkt_lsl.tmp.txt

diff -y --suppress-common-lines 2_bkt_lsl 3_bkt_lsl.tmp.txt

# Charges for an "empty bucket"
# Creates a noncurrent object if generation number not provided
gsutil rm gs://${BUCKET_NAME_1}/*

# Check https://console.cloud.google.com/storage/browser?project=alk-data-210&prefix=
# Toggle "Show deleted data"

gsutil ls -La gs://${BUCKET_NAME_1}/*

# Setting metadata on noncurrent objects
gsutil setmeta -h "x-goog-meta-cloud:aws" gs://${BUCKET_NAME_1}/${OBJECT_NAME}#<noncurrent object generation number>

# Restoring a noncurrent object version means making a copy of it!
gsutil cp gs://${BUCKET_NAME_1}/${OBJECT_NAME}#<noncurrent object generation number> gs://${BUCKET_NAME_1}/${OBJECT_NAME}
