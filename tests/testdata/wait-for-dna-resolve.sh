#!/bin/sh

set -e

if [ -z "${1}" ]; then
    echo "first argument must be a domain name"
    exit 1
fi

if [ -z "${2}" ]; then
    echo "second argument must be a number for the wait timer"
    exit 1
fi

domain_name="${1}"
timer="$((${2}))"
debug="${3}"
counter="0"
wait_time="1"
resolution="0"

echo "performing nslookup of ${domain_name}"
echo "waiting ${timer} seconds for DNS resolution, and refreshing every ${wait_time} seconds"

while
    result=$(nslookup -type=CNAME "${domain_name}" | grep "answers can be found")

    if [ -n "${debug}" ]; then
        echo "${result}"
    fi

    if [ -n "${result}" ]; then
        resolution=1
        break
        exit 0
    fi

    printf "%s" "."

    sleep "${wait_time}"

    counter="$((${counter}+${wait_time}))"

    [ ${counter} -lt ${timer} ] # end loop test
do :; done

echo

if [ "${resolution}" = "0" ]; then
    echo "the domain ${domain_name} did not resolve"
    exit 1
fi

exit 0
