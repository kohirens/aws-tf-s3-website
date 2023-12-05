#!/bin/sh

# For help see: https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external#external-program-protocol

set -e

## read the input (not sure how this works)
#json_data=$(cat)
#
#if [ -z "${json_data}" ]; then
#  echo "no JSON input, JSON of the form {\"url\":<url>} is required" >&2
#  exit 1
#fi

url="${1}"

if [ -z "${1}" ]; then
  echo "URL input is required" >&2
  exit 1
fi


# make a temporary file to store the response body
tmp_file="$(mktemp)"

# get the status code and response body of the URL
status_code=$(curl -o "${tmp_file}" -sw '%{response_code}\n' "${url}")
response_body="$(cat "${tmp_file}")"

# output JSON
jq -n \
    --arg status_code "${status_code}" \
    --arg response_body "${response_body}" \
    '{"status_code":$status_code,"response_body":$response_body}'
