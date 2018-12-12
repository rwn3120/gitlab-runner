#!/bin/bash -eu
function inf() { echo -e "\\e[97m${*}\\e[39m"; }

SCRIPT=$(readlink -f "${0}")
SCRIPT_NAME=$(basename "${SCRIPT}")

function generateName() {
    echo "docker-$(hostname -s)-$(date +"%y%m%d-%H%M")"
}

IMAGE="radowan/gitlab-runner"

ARGS=("${@}")

for i in "${!ARGS[@]}"; do
    if [ "${ARGS[${i}]}" == "-h" ] || [ "${ARGS[${i}]}" == "-?" ] || [ "${ARGS[${i}]}" == "--help" ]; then
        docker run "${IMAGE}" runner -h | sed "s/Usage:.*/Usage: ${SCRIPT_NAME} [OPTIONS]/"
        exit 1
    fi
    if [ "${ARGS[${i}]}" == "-N" ]; then
        CONTAINER_NAME="${ARGS[$((i+1))]}"
    fi
done
NAME="${NAME:-${CONTAINER_NAME:-$(generateName)}}"

if [ "${INTERACTIVE:-"false"}" == "true" ]; then
    RUNNING_MODE="-it"
else
    RUNNING_MODE="-dt"
fi

inf "Starting container ${NAME}"
docker pull "${IMAGE}"
docker run \
    ${RUNNING_MODE} \
    -v "/var/run/docker.sock:/var/run/docker.sock" \
    -v "${HOME}/.docker:/root/.docker" \
    -e "NAME=${NAME}" \
    --name "${NAME}" \
    --hostname "${NAME}" \
    --restart "on-failure:${RESTART_LIMIT:-2}" \
    "${IMAGE}" \
        runner "${@}"

timeout "${TIMEOUT:-"5s"}" docker logs -f "${NAME}"
docker ps -q --filter "name=${NAME}"
