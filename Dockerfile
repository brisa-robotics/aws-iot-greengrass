FROM debian:bullseye

# Set ENV_VAR for Greengrass RC to be untarred inside Docker Image
ARG VERSION=1.10.1
ARG GREENGRASS_RELEASE_URL=https://d1onfpft10uf5o.cloudfront.net/greengrass-core/downloads/${VERSION}/greengrass-linux-x86-64-${VERSION}.tar.gz

# Install Greengrass Core Dependencies
RUN apt update -y \
    && apt install -y jq tar wget \
    && wget -q $GREENGRASS_RELEASE_URL \
    && apt-get remove -y wget \
    && rm -rf /var/apt/lists/*

# Copy Greengrass Licenses AWS IoT Greengrass Docker Image
COPY greengrass-license-v1.pdf /

# Copy start-up script
COPY "greengrass-entrypoint.sh" /

# Setup Greengrass inside Docker Image
RUN export GREENGRASS_RELEASE=$(basename $GREENGRASS_RELEASE_URL) && \
    tar xzf $GREENGRASS_RELEASE -C / && \
    rm $GREENGRASS_RELEASE && \
    useradd -r ggc_user && \
    groupadd -r ggc_group

# Expose 8883 to pub/sub MQTT messages
EXPOSE 8883
