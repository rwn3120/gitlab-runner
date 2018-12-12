#!/bin/bash -eu
function inf() { echo -e "\\e[97m${*}\\e[39m"; }
function wrn() { echo -e "\\e[93m${*}\\e[39m" 1>&2; }
function err() { echo -e "\\e[31m${*}\\e[39m" 1>&2; }
function fail() { err "${@}"; exit 254; }

SCRIPT=$(readlink -f "${0}")
SCRIPT_NAME=$(basename "${SCRIPT}")

show_help() {
inf "Usage: ${SCRIPT_NAME} [OPTIONS] 

Register new gitlab runner.

Options:
    -N <name>   runner name (mandatory)
    -h,-?       display this help and exit
"
        exit 1
}

OPTIND=1
while getopts "N:h" OPT; do
    case "${OPT}" in
        "N")    NAME="${OPTARG}";;
        "h"|"?")show_help;;
        "*")    echo "Unknown option: -${OPTARG}. Run with -h to display help";;
    esac
done
shift "$((OPTIND-1))"   

if [[ ! ${NAME+x} ]]; then fail "Missing -N <name>"; fi

docker stop "${NAME}" 2>/dev/null || wrn "Container ${NAME} is not running"
docker rm "${NAME}" 2>/dev/null || wrn "Container ${NAME} does not exist"
