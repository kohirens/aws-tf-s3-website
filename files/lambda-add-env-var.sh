#!/bin/sh

set -e

lambda_func_name="${1}"
append_vars="${2}"
region="${3}"

current_variables=$( \
    aws lambda get-function-configuration --region "${region}" --function-name "${lambda_func_name}" | \
    jq '.Environment.Variables' \
)
new_variables=$(echo "${current_variables}" | jq ". += ${append_vars}")

aws lambda update-function-configuration \
     --region "${region}" \
     --function-name "${lambda_func_name}" \
     --environment "{\"Variables\":${new_variables}}"
