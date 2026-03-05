# Base image
FROM debian:12-slim

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install management and observability tools
RUN apt-get update && apt-get install -y \
    iptables \
    iproute2 \
    tcpdump \
    net-tools \
    iputils-ping \
    procps \
    sudo \
    gnupg2 \
    apt-transport-https \
    curl \
    wget \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | \
    gpg --dearmor > /etc/apt/trusted.gpg.d/elk.gpg

RUN echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" \
    > /etc/apt/sources.list.d/elastic-8.list

RUN apt-get update && apt-get install -y \
    elasticsearch \
    kibana \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Elastic / Kibana needs a port 9200 for connecting to the web site, maybe it needs to be opened here
# Filebeat sends at 5601
EXPOSE 9200 5601

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

#Cache
#https://docs.suricata.io/en/latest/command-line-options.html#:~:text=If%20you%20run%20Suricata%20as,without%20disturbing%20the%20engine%20running.&text=With%20the%20%2D%2Drunmode%20option,you%20would%20like%20to%20use.
#https://www.elastic.co/docs/reference/beats/filebeat/filebeat-installation-configuration
#https://www.elastic.co/docs/deploy-manage/deploy/self-managed/install-kibana-with-debian-package
#https://www.elastic.co/docs/deploy-manage/deploy/self-managed/install-elasticsearch-with-debian-package#deb-check-running
#https://www.google.com/search?q=elasticsearch%2C+kibana+and+filebeat+ports&oq=elasticsearch%2C+kibana+and+filebeat+ports&gs_lcrp=EgZjaHJvbWUyBggAEEUYOdIBCDU2NzVqMGoxqAIAsAIA&sourceid=chrome&ie=UTF-8
