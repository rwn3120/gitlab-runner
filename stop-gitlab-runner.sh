#!/bin/bash -eu
function inf() { echo -e "\\e[97m${*}\\e[39m"; }
function wrn() { echo -e "\\e[93m${*}\\e[39m" 1>&2; }
function err() { echo -e "\\e[31m${*}\\e[39m" 1>&2; }
function fail() { err "${@}"; exit 254; }

SCRIPT=$(readlink -f "${0}")
SCRIPT_NAME=$(basename "${SCRIPT}")

show_help() {
inf "Usage: ${SCRIPT_NAME} [OPTIONS] 

Stop gitlab runner.

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

echo "ps -a | grep -E \"\\s+gitlab-runner$\" | awk '{print \$1}' | xargs kill"  | docker exec -i "${NAME}" bash - || wrn "Could not unregister runner with name ${NAME}"
docker stop -t 10 "${NAME}" 2>/dev/null || inf "Container ${NAME} stopped"
docker rm -f "${NAME}" 2>/dev/null || inf "Container ${NAME} removed"
