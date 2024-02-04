#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
COMMON_RESOURCES_DIR="$(realpath "${SCRIPT_DIR}"/../common_resources)"
set -o allexport; source  "${SCRIPT_DIR}"/../.env; set +o allexport

OBJECT_NAME="spotify_logo.png"
SIGNED_URL_DURATION="60s"
# ------------------------------------------------------------

gsutil rm -r gs://"${BUCKET_NAME_1}"
gsutil mb -c standard -p "${PROJECT_ID}" -l "${REGION_1}" -b on gs://"${BUCKET_NAME_1}"
gsutil cp "${COMMON_RESOURCES_DIR}"/"${OBJECT_NAME}" gs://"${BUCKET_NAME_1}"

# Enable APIs:
gcloud services enable iamcredentials.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

# Create SA
gcloud iam service-accounts create "${SA_NAME}" --display-name "${SA_NAME}"

# Add roles to SA on project level
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
--member serviceAccount:"${SA_EMAIL}" \
--role "roles/storage.admin"

# Add Service Account Token Creator role to user on SA level
gcloud iam service-accounts add-iam-policy-binding "${SA_EMAIL}" \
--member "user:${USER_EMAIL}" \
--role "roles/iam.serviceAccountTokenCreator" 

# (Optional) Upgrade pip
pip3 install --upgrade pip
# (Optional) Install pyopenssl
python3 -m pip install pyopenssl

# (Optional) Toggle impersonating SA
gcloud config set auth/impersonate_service_account "${SA_EMAIL}"
gcloud config unset auth/impersonate_service_account

# Create signed url(s) (to be used with toggled SA impersonation)
gsutil signurl -r europe-central2 -d "${SIGNED_URL_DURATION}" -u gs://"${BUCKET_NAME_1}"/"${OBJECT_NAME}"
gsutil signurl -r europe-central2 -d 5s -u gs://"${BUCKET_NAME_1}"/"${OBJECT_NAME}"
gsutil signurl -r europe-central2 -d "${SIGNED_URL_DURATION}" -u gs://"${BUCKET_NAME_1}"/*

# Use in-command impersonation
gsutil -i "${SA_EMAIL}" ls
gsutil -i "${SA_EMAIL}" signurl -r europe-central2 -d "${SIGNED_URL_DURATION}" -u gs://"${BUCKET_NAME_1}"/"${OBJECT_NAME}"