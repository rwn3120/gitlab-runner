#!/bin/bash -eu
function dbg() { echo -e "\e[94m${@}\e[39m"; }
function inf() { echo -e "\e[97m${@}\e[39m"; }
function out() { echo -e "\e[32m${@}\e[39m"; }
function wrn() { echo -e "\e[93m${@}\e[39m" 1>&2; }
function err() { echo -e "\e[31m${@}\e[39m" 1>&2; }
function fail() { err "${@}"; exit 254; }

SCRIPT=$(readlink -f "${0}")
SCRIPT_NAME=$(basename "${SCRIPT}")

DEFAULT_TAGS="docker"
DEFAULT_IMAGE="debian:sid-slim"

show_help() {
inf "Usage: ${SCRIPT_NAME} [OPTIONS] 

Register new gitlab runner.

Options:
    -R <runner> runner name (mandatory)
    -U <url>    gitlab url (mandatory)
    -T <token>  gitlab token (mandatory)
    -i <image>  default image (default ${DEFAULT_IMAGE})
    -t <tags>   runner tags (default ${DEFAULT_TAGS})
    -h,-?       display this help and exit

Environments:
    TOKEN, URL, RUNNER, IMAGE, TAGS

Examples:
    ${SCRIPT_NAME} -R my-runner -U our.gitlab.com -T token-value
    RUNNER=my-runner URL=our.gitlab.com TOKEN=token-value ${SCRIPT_NAME}
"
        exit 1
}

OPTIND=1
while getopts "R:T:U:i:t:c:h" OPT; do
    case "${OPT}" in
        "R")    RUNNER="${OPTARG}";;
        "T")    TOKEN="${OPTARG}";;
        "U")    URL="${OPTARG}";;
        "i")    IMAGE="${OPTARG}";;
        "t")    TAGS="${OPTARG}";;
        "h"|"?")show_help;;
        "*")    echo "Unknown option: -${OPTARG}. Run with -h to display help";;
    esac
done
shift "$((OPTIND-1))"   

if [[ ! ${RUNNER+x} ]]; then fail "Missing argument: runner"; fi
if [[ ! ${TOKEN+x} ]]; then fail "Missing argument: token"; fi
if [[ ! ${URL+x} ]]; then fail "Missing argument: url"; fi
TAGS="${TAGS:-"${DEFAULT_TAGS}"}"
IMAGE="${IMAGE:-"${DEFAULT_IMAGE}"}"

REGEX="^[a-z0-9]([a-z0-9-]*[a-z]+)*$"
if [[ ! "${RUNNER}" =~ ${REGEX} ]]; then
    fail "Runner name ${RUNNER} does not match ${REGEX}"
fi

inf "Registering ${RUNNER}"
gitlab-runner register \
    --non-interactive \
    --executor "docker" \
    --docker-image "${IMAGE:-"debian:sid-slim"}" \
    --url "${URL}" \
    --registration-token "${TOKEN}" \
    --description "${RUNNER}" \
    --tag-list "${TAGS}" \
    --run-untagged \
    --locked="${LOCKED:-"false"}"
