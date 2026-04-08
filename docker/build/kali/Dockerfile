# Base image for the Attacker Kali Linux setup
FROM kalilinux/kali-rolling

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install networking tools
# nmap - port scanning and service/OS detection used in reconnaissance attacks
# openssh-client - SSH client used for access in brute force scenarios
# tini - minimal init process (PID 1) that correctly manages signals and removes zombie child processes; required because attack scripts spawn background processes that must be cleaned up
# hping3 - TCP/IP packet tool used to generate SYN flood DoS attacks
# hydra - network login cracker used for SSH brute force attacks
# seclists - wordlist collection (passwords, usernames) used by hydra and other tools
# nginx - web server for OSPF route hijacking scenario
# swaks - used for mail reconnaissance, user enumeration and relay abuse

RUN apt-get update && apt-get install -y \
    iproute2 \
    iputils-ping \
    traceroute \
    net-tools \
    iptables \
    curl \
    tcpdump \
    nmap \
    openssh-client \
    tini \
    hping3 \
    python3 \
    python3-pip \
    procps \
    hydra \
    seclists \
    tcpdump \
    nginx \
    swaks \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install package for another type of attack (install the package no matter what, even if it messes other packages)
RUN pip3 install slowloris --break-system-packages

# Create clean wordlist directory
RUN mkdir -p /wordlists

# Copy the 3 most useful lists
RUN cp /usr/share/seclists/Passwords/Common-Credentials/10k-most-common.txt /wordlists/
RUN cp /usr/share/seclists/Passwords/Common-Credentials/xato-net-10-million-passwords-100000.txt /wordlists/
RUN cp /usr/share/seclists/Usernames/cirt-default-usernames.txt /wordlists/users.txt

# minimal init process that forwards signals and cleans up zombie processes inside containers
ENTRYPOINT ["/usr/bin/tini", "--"]

# Keep the container alive
CMD ["sleep", "infinity"]
