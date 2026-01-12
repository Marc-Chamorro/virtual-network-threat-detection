# https://docs.docker.com/build/building/base-images/
FROM kalilinux/kali-rolling

# https://stackoverflow.com/questions/70236670/debian-frontend-noninteractive-not-working-inside-shell-script-with-apt-get
ENV DEBIAN_FRONTEND=noninteractive

# https://circleci.com/docs/guides/execution-managed/custom-images/
RUN apt update && apt -y install \
    iproute2 \
    iputils-ping \
    traceroute \
    net-tools \
    curl \
    tcpdump \
    nmap \
    # Clean cache
    && apt clean \
    # Remove temporal data
    && rm -rf /var/lib/apt/lists/*

# https://docs.docker.com/get-started/docker-concepts/building-images/writing-a-dockerfile/
# https://refine.dev/blog/docker-entrypoint/#how-to-use-a-script-as-entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

# https://stackoverflow.com/questions/54590798/docker-running-script-in-entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# https://kodekloud.com/blog/keep-docker-container-running/
CMD ["sleep", "infinity"]
