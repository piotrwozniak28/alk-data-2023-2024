#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_ROOT_DIR="$(realpath "${SCRIPT_DIR}/../../..")"
COMMON_RESOURCES_DIR="$(realpath "${REPO_ROOT_DIR}/common_resources")"
set -o allexport; source  "${REPO_ROOT_DIR}/.env"; set +o allexport
# ------------------------------------------------------------

BENCHMARK_RESULTS_DIR="$(realpath ${SCRIPT_DIR}/../benchmark_results)"
DATETIME="$(date +%Y-%m-%d_%H%M%S)"
BENCHMARK_NAME_SHORT="tpcds"
BENCHMARK_NAME_FULL="tpcds_${TPCDS_SCALE_GB}_gb_${DATETIME}"

mkdir -p ${BENCHMARK_RESULTS_DIR}

for QUERY_FILE in ${SCRIPT_DIR}/../queries/benchmark_temp/*.sql;
do
    QUERY_NUM=`basename ${QUERY_FILE} | grep --only-matching --extended-regexp '[0-9]+'`
    BQ_JOB_ID="${BENCHMARK_NAME_FULL}_query_${QUERY_NUM}"
    echo ""
    echo "Running job_id '${BQ_JOB_ID}'"

    cat "${QUERY_FILE}" \
      | bq \
        --project_id=${PROJECT_ID} \
        --location=${REGION_1} \
        --dataset_id=${BQD_TPCDS_EXTERNAL_NOAUTODETECT} \
        query \
        --use_cache=false \
        --use_legacy_sql=false \
        --batch=false \
        --job_id=$BQ_JOB_ID \
        --format=none \
        --label="benchmark_name_short:${BENCHMARK_NAME_SHORT}" \
        --label="benchmark_name_full:${BENCHMARK_NAME_FULL}" \
        --label="benchmark_date:${DATETIME}" \
        --label="query_num:${QUERY_NUM}" \
        --label="benchmark_scale_gb:${TPCDS_SCALE_GB}"

    BQ_JOB=$(bq --project_id=${PROJECT_ID} --location=${REGION_1} --format=json show -j ${BQ_JOB_ID})

    BQ_JOB_PARAMS=$(jq -r '[.statistics | .startTime, .endTime, .query.totalBytesBilled] | join(",")' <<< ${BQ_JOB})

    echo "${QUERY_NUM},${BQ_JOB_PARAMS}" >> ${BENCHMARK_RESULTS_DIR}/${BENCHMARK_NAME_FULL}.csv
done
echo "Benchmark results saved to ${BENCHMARK_RESULTS_DIR}/${BENCHMARK_NAME_FULL}.csv"
