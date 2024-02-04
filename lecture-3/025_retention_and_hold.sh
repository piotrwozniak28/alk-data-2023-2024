#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
COMMON_RESOURCES_DIR="$(realpath "${SCRIPT_DIR}"/../common_resources)"
set -o allexport; source  "${SCRIPT_DIR}"/../.env; set +o allexport

OBJECT_NAME="spotify_logo.png"
RETENTION_POLICY_TIME_DURATION="30s"
# HOLD_TYPE=temp
HOLD_TYPE=event
# ------------------------------------------------------------

gsutil rm -r gs://"${BUCKET_NAME_1}"
gsutil mb -c standard -p "${PROJECT_ID}" -l "${REGION_1}" -b on gs://"${BUCKET_NAME_1}"
gsutil cp "${COMMON_RESOURCES_DIR}"/"${OBJECT_NAME}" gs://"${BUCKET_NAME_1}"

gsutil retention set ${RETENTION_POLICY_TIME_DURATION} gs://${BUCKET_NAME_1}

# Object now has a 'Retention Expiration' metadata key
gsutil ls -L gs://${BUCKET_NAME_1}

gsutil rm gs://${BUCKET_NAME_1}/*

# (Wait >10s)
# Object holdsf

gsutil retention ${HOLD_TYPE} set gs://${BUCKET_NAME_1}/${OBJECT_NAME}
gsutil ls -L gs://${BUCKET_NAME_1}
gsutil rm gs://${BUCKET_NAME_1}/*

gsutil retention ${HOLD_TYPE} release gs://${BUCKET_NAME_1}/${OBJECT_NAME}
gsutil ls -L gs://${BUCKET_NAME_1}
gsutil rm gs://${BUCKET_NAME_1}/*

# PERMANENTLY locks an unlocked retention policy
gsutil retention lock gs://${BUCKET_NAME_1}

# gcloud alpha resource-manager liens list
# gcloud alpha resource-manager liens delete