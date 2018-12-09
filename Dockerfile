FROM debian:sid-slim

RUN echo 'deb http://deb.debian.org/debian sid main contrib non-free' > /etc/apt/sources.list && \
    cat /etc/apt/sources.list && \
    apt-get update -y && \
    apt-get install -y \
        docker.io=18.06.1+dfsg1-2 gitlab-runner &&\
    apt-get clean

COPY register-runner.sh /usr/bin/register
