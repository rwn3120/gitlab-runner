# Gitlab runner in docker

Containerized GitLab runner. Supported executors:

- docker (default)
- shell

## Quickstart
### Start GitLab runner
1. Download `start-gitlab-runner.sh` script:
```
curl https://raw.githubusercontent.com/rwn3120/gitlab-runner/master/start-gitlab-runner.sh > start-gitlab-runner.sh
```
2. Run `start-gitlab-runner.sh` script:
    * docker executor:
```
./start-gitlab-runner.sh -N "docker-executor" -T "token" -U "https://gitlab.com" -e docker
```
    * shell executor:
```
./start-gitlab-runner.sh -N "shell-executor" -T "token" -U "https://gitlab.com" -e docker
```
### Stop GitLab runner
1. Download `stop-gitlab-runner.sh` script:
```
curl https://raw.githubusercontent.com/rwn3120/gitlab-runner/master/stop-gitlab-runner.sh > stop-gitlab-runner.sh
```
2. Run `stop-gitlab-runner.sh` script:
    * docker executor:
```
./stop-gitlab-runner.sh -N "docker-executor"
```
    * shell executor:
```
./stop-gitlab-runner.sh -N "shell-executor"
```
## Usage
### start-gitlab-runner.sh
```
Usage: start-gitlab-runner.sh [OPTIONS]

Register new gitlab runner.

Options:
    -N <name>       runner name (mandatory)
    -U <url>        gitlab url (mandatory)
    -T <token>      gitlab token (mandatory)
    -e <executor>   executor (docker or shell, default docker)
    -i <image>      default image (default debian:sid-slim)
    -t <tags>       runner tags (default same as executor)
    -h,-?           display this help and exit

Environments:
    NAME, URL, TOKEN, EXECUTOR, IMAGE, TAGS

Examples:
    runner -N runner-with-docker -U our.gitlab.com -T token-value
    NAME=runner-with-docker URL=our.gitlab.com TOKEN=token-value runner
```
### stop-gitlab-runner.sh
```
Usage: stop-gitlab-runner.sh [OPTIONS] 

Stop gitlab runner.

Options:
    -N <name>   runner name (mandatory)
    -h,-?       display this help and exit
```

# Run GitLab runner manually
1. Download latest image
```
docker pull radowan/gitlab-runner
```
2. Start container
```
docker run \
    -dt \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ${HOME}/.docker:/root/.docker \
    --name docker-executor \
    --hostname docker-executor \
    --restart on-failure:2 \
    radowan/gitlab-runner runner -N "docker-executor" -T "token" -U "https://gitlab.com"
```
3. Stop container
```
docker stop docker-executor
```
## Usage
```
Usage: runner [OPTIONS] 

Register new gitlab runner.

Options:
    -N <name>       runner name (mandatory)
    -U <url>        gitlab url (mandatory)
    -T <token>      gitlab token (mandatory)
    -e <executor>   executor (docker or shell, default docker)
    -i <image>      default image (default debian:sid-slim)
    -t <tags>       runner tags (default same as executor)
    -h,-?           display this help and exit

Environments:
    NAME, URL, TOKEN, EXECUTOR, IMAGE, TAGS

Examples:
    runner -N runner-with-docker -U our.gitlab.com -T token-value
    NAME=runner-with-docker URL=our.gitlab.com TOKEN=token-value runner
```