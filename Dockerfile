FROM debian:sid-slim

RUN echo 'deb http://deb.debian.org/debian sid main contrib non-free' > /etc/apt/sources.list && \
    cat /etc/apt/sources.list && \
    apt-get update -y && \
    apt-get install -y \
        docker.io=18.06.1+dfsg1-2 procps vim curl mc && \
    apt-get clean && \
    curl -o /usr/local/bin/gitlab-runner "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64" && \
    chmod +x /usr/local/bin/gitlab-runner && \
    mkdir -p /root/gitlab-runner /root/.docker && \
    gitlab-runner install --user=root --working-directory=/root/gitlab-runner 

COPY entrypoint runner /usr/bin/

ENTRYPOINT ["entrypoint"]
CMD ["bash"]
