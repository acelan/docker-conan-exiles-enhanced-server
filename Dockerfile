FROM --platform=linux/amd64 debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    crudini \
    curl \
    gettext-base \
    libcurl4 \
    libicu72 \
    libssl3 \
    procps \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh && \
    chmod +x /tmp/dotnet-install.sh && \
    /tmp/dotnet-install.sh --channel 8.0 --runtime dotnet --install-dir /usr/share/dotnet && \
    ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet && \
    rm /tmp/dotnet-install.sh

ARG DEPOT_DOWNLOADER_VERSION=3.4.0
RUN curl -sL "https://github.com/SteamRE/DepotDownloader/releases/download/DepotDownloader_${DEPOT_DOWNLOADER_VERSION}/DepotDownloader-linux-x64.zip" -o /tmp/depotdownloader.zip && \
    mkdir -p /depotdownloader && \
    unzip /tmp/depotdownloader.zip -d /depotdownloader && \
    chmod +x /depotdownloader/DepotDownloader && \
    rm /tmp/depotdownloader.zip

RUN useradd -m -s /bin/bash steam

ENV HOME=/home/steam \
    PUID=1000 \
    PGID=1000 \
    UPDATE_ON_START=true \
    PORT=7777 \
    QUERY_PORT=27015 \
    RCON_PORT=25575 \
    MAX_PLAYERS=40 \
    SERVER_NAME="Conan Exiles Enhanced Server" \
    SERVER_PASSWORD="" \
    RCON_PASSWORD="" \
    ADMIN_PASSWORD="" \
    MODS="" \
    CONANEXILES_CMD_SWITCHES=""

COPY ./scripts /home/steam/server/

RUN mkdir -p /home/steam/server-files && \
    chmod +x /home/steam/server/*.sh && \
    chown -R steam:steam /home/steam

WORKDIR /home/steam/server

HEALTHCHECK --start-period=5m CMD pgrep -f "ConanSandboxServer-Linux-Shipping" > /dev/null || exit 1

ENTRYPOINT ["/home/steam/server/init.sh"]
