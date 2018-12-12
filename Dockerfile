FROM debian:sid-slim

RUN echo 'deb http://deb.debian.org/debian sid main contrib non-free' > /etc/apt/sources.list && \
    cat /etc/apt/sources.list && \
    apt-get update -y && \
    apt-get install -y \
        docker.io=18.06.1+dfsg1-2 gitlab-runner procps vim curl mc && \
    apt-get clean && \
    mkdir -p /root/.docker

COPY entrypoint runner /usr/bin/

ENTRYPOINT ["entrypoint"]
CMD ["bash"]
