FROM debian:bullseye

# Set ENV_VAR for Greengrass RC to be untarred inside Docker Image
ARG VERSION=1.10.1
ARG GREENGRASS_RELEASE_URL=https://d1onfpft10uf5o.cloudfront.net/greengrass-core/downloads/${VERSION}/greengrass-linux-x86-64-${VERSION}.tar.gz

# Install Greengrass Core Dependencies
RUN apt update -y \
    && apt install -y iproute2 jq tar wget sudo \
    && wget -q $GREENGRASS_RELEASE_URL \
# Setup Greengrass inside Docker Image
    && sudo useradd --system --create-home ggc_user \
    && wget -O gg-device-setup-latest.sh https://d1onfpft10uf5o.cloudfront.net/greengrass-device-setup/downloads/gg-device-setup-latest.sh \
    && chmod +x ./gg-device-setup-latest.sh \
    && sudo -E ./gg-device-setup-latest.sh bootstrap-greengrass --region us-east-1 \
    && export GREENGRASS_RELEASE=$(basename $GREENGRASS_RELEASE_URL) \
    && tar xzf $GREENGRASS_RELEASE -C / \
    && rm $GREENGRASS_RELEASE \
    # && useradd -r ggc_user \
    && groupadd -r ggc_group \
    && rm -rf /var/apt/lists/*

# Copy Greengrass Licenses AWS IoT Greengrass Docker Image
COPY greengrass-license-v1.pdf /

# Copy start-up script
COPY "greengrass-entrypoint.sh" /

# Expose 8883 to pub/sub MQTT messages
EXPOSE 8883
