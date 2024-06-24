# Specify base image
FROM ubuntu:jammy

# Set shell and environment variables
SHELL ["/usr/bin/bash", "-c"]
ENV LANG=en_US.UTF-8
ENV HOSTNAME="Jammy"
ENV USER=ubuntu PASSWORD="!2345678a" GID=1001 UID=1001
ENV NX_PUBLICKEY=""

# Update package lists and installing essential packages
RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        cabextract \
        cron \
        dbus-x11 \
        git \
        gnupg \
        gosu \
        gpg-agent \
        ssh \
        htop \
        locales \
        nano \
        net-tools \
        iputils-ping \
        p7zip \
        pavucontrol \
        pulseaudio \
        pulseaudio-utils \
        software-properties-common \
        sudo \
        tzdata \
        unzip \
        vim \
        wget \
        curl \
        psmisc \
        x11-xserver-utils \
        xfce4 \
        xfce4-goodies \
        xfce4-pulseaudio-plugin \
        terminator \
        tmux \
        xubuntu-icon-theme \
        xvfb \
        zenity \
    && apt remove snapd -y \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean && apt-get autoremove -y && apt-get autoclean \
    && locale-gen en_US.UTF-8

## It's maybe used to allow multiple pulse instances?
RUN sed -i -E 's/^; autospawn =.*/autospawn = yes/' /etc/pulse/client.conf \
    && [ -f /etc/pulse/client.conf.d/00-disable-autospawn.conf ] \
    && sed -i -E 's/^(autospawn=.*)/# \1/' /etc/pulse/client.conf.d/00-disable-autospawn.conf || echo ""

# Download and install additional applications
WORKDIR /tmp/

## Install and configure nomachine server
RUN curl -fSL "https://www.nomachine.com/free/linux/64/deb" -o nomachine.deb && dpkg -i nomachine.deb && rm -f nomachine.deb \
    && sed -i -e "s|#EnableClipboard both|EnableClipboard both|g" \
    -e "s|#EnableUPnP none|EnableUPnP NXUDP|g" \
    -e "s|#NXUDPPort 4000|NXUDPPort 4000|g" \
    -e "s|#DisplayGeometry .*|DisplayGeometry 1600x900|g" \
    -e "s|#EnableLockScreen 0|EnableLockScreen 1|g" \
    -e "s|#VirtualDesktopAccess administrator,trusted,owner,system|VirtualDesktopAccess administrator,trusted,owner|g" \
    -e "s|#VirtualDesktopAccessNoAcceptance administrator,trusted,owner|VirtualDesktopAccessNoAcceptance administrator,trusted,owner|g" \
    -e "s|#PhysicalDesktopAccess .*|PhysicalDesktopAccess administrator,trusted,owner|g" \
    -e "s|#PhysicalDesktopAccessNoAcceptance .*|PhysicalDesktopAccessNoAcceptance administrator,trusted,owner|g" \
    -e "s|#EnableClientAutoreconnect .*|EnableClientAutoreconnect NX,SSH|g" \
    -e "s|#AcceptedAuthenticationMethods .*|AcceptedAuthenticationMethods NX-private-key|g" \
    /usr/NX/etc/server.cfg

## Install Firefox for Linux from Mozilla PPA
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo "Package: *" > /etc/apt/preferences.d/mozilla-firefox && \
    echo "Pin: release o=LP-PPA-mozillateam" >> /etc/apt/preferences.d/mozilla-firefox && \
    echo "Pin-Priority: 1001" >> /etc/apt/preferences.d/mozilla-firefox && \
    echo "Unattended-Upgrade::Allowed-Origins:: \"LP-PPA-mozillateam:jammy\";" > /etc/apt/apt.conf.d/51unattended-upgrades-firefox && \
    apt update && DEBIAN_FRONTEND="noninteractive" apt install firefox -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && apt-get clean && apt-get autoremove -y && apt-get autoclean

## Install Chromium-based browser(s)
### Vivaldi
RUN latest_stable_vivaldi_browser_version=$(curl -sL repo.vivaldi.com/stable/deb/pool/main/ | grep -Eo "[A-Za-z0-9\._-]*(\.deb)" | grep stable | grep amd64 | sort -u | tail -1) \
    && apt-get update && \
    wget -O vivaldi-stable_amd64.deb https://repo.vivaldi.com/stable/deb/pool/main/${latest_stable_vivaldi_browser_version} && \
    apt install -y ./vivaldi-stable_amd64.deb && \
    rm -f vivaldi-stable_amd64.deb && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && apt-get autoremove -y && apt-get autoclean

### Additional utilities
RUN curl https://getcroc.schollz.com | bash && \
    wget -qO - portal.spatiumportae.com | bash

# Copy additional files
COPY --chmod=755 nxserver.sh /

# Set entrypoint
ENTRYPOINT ["/nxserver.sh"]
