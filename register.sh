#!/bin/bash -eu
function dbg() { echo -e "\e[94m${@}\e[39m"; }
function inf() { echo -e "\e[97m${@}\e[39m"; }
function out() { echo -e "\e[32m${@}\e[39m"; }
function wrn() { echo -e "\e[93m${@}\e[39m" 1>&2; }
function err() { echo -e "\e[31m${@}\e[39m" 1>&2; }
function fail() { err "${@}"; exit 254; }

SCRIPT=$(readlink -f "${0}")
SCRIPT_NAME=$(basename "${SCRIPT}")

show_help() {
inf "Usage: ${SCRIPT_NAME} [OPTIONS] 

Register new gitlab runner.

Options:
    -T <token>  gitlab token (mandatory)
    -u <url>    gitlab url (mandatory)
    -r <name>   runner name
    -i <image>  default image
    -t <tags>   runner tags
    -h,-?       display this help and exit

Environments:
    TOKEN, URL, RUNNER, CONFIG_DIRECTORY, IMAGE, TAGS"
        exit 1
}

OPTIND=1
while getopts "r:d:t:U:i:T:c:h" OPT; do
    case "${OPT}" in
        "r")    RUNNER="${OPTARG}";;
        "t")    TOKEN="${OPTARG}";;
        "U")    URL="${OPTARG}";;
        "i")    IMAGE="${OPTARG}";;
        "T")    TAGS="${OPTARG}";;
        "c")    CONTAINER_NAME="${OPTARG}";;
        "h"|"?")show_help;;
        "*")    echo "Unknown option: -${OPTARG}. Run with -h to display help";;
    esac
done
shift "$((OPTIND-1))"   

if [[ ! ${TOKEN+x} ]]; then fail "Missing argument: token"; fi
if [[ ! ${URL+x} ]]; then fail "Missing argument: url"; fi
TAGS="${TAGS:-"docker"}"

REGEX="^[a-z0-9]([a-z0-9-]*[a-z]+)*$"
if [[ ! "${RUNNER}" =~ ${REGEX} ]]; then
        fail "Runner name ${RUNNER} does not match ${REGEX}"
fi

inf "Registering ${RUNNER}"

gitlab-ci-multi-runner register \
    --non-interactive \
    --executor "docker" \
    --docker-image "${IMAGE:-"debian:sid-slim"}" \
    --url "${URL}" \
    --registration-token "${TOKEN}" \
    --description "${RUNNER:gitlab-runner}" \
    --tag-list "${TAGS}" \
    --run-untagged \
    --locked="${LOCKED:-"false"}"
