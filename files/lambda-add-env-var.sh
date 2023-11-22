#!/bin/sh

set -e

LAMBDA="${1}"
append_vars="${2}"
region="${3}"

aws lambda get-function-configuration --region "${region}" --function-name "test-kohirens-com"
CURRENT_VARIABLES=$(aws lambda get-function-configuration --function-name "${LAMBDA}" | jq '.Environment.Variables')
#NEW_VARIABLES=$(echo ${CURRENT_VARIABLES} | jq '. += {"kick":"'$(getrandom 8)'"}')
NEW_VARIABLES=$(echo "${CURRENT_VARIABLES}" | jq ". += ${append_vars}")

aws lambda update-function-configuration \
     --region "${region}" \
     --function-name "${LAMBDA}" \
     --environment "{\"Variables\":${NEW_VARIABLES}}"
