# Asset builder stage (venv, PlantUML, Draw.io, d2)
FROM doxtr/reactor-builder-assets:0.0.10 AS builder

# Dedicated fonts image — fonts are imported from here instead of the builder.
# Pin this tag to match your published fonts image.
FROM doxtr/reactor-builder-fonts:0.0.1 AS fonts

# ==========================================
# STAGE 2: Final Runtime Environment
# ==========================================
FROM ubuntu:26.04
LABEL maintainer="Jens Frey <jens.frey@coffeecrew.org>" Version="2026-09-06"

# Setup Environment Variables
ENV DEBIAN_FRONTEND=noninteractive \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:/usr/local/bin:${PATH}" \
    TEXMFCACHE=/var/lib/texmf \
    LUAOTFLOAD_CACHE=/var/lib/texmf/luatex-cache \
    LC_ALL=C \
    NVM_DIR=/root/.nvm

COPY .bashrc /root/.bashrc
COPY default.template /etc/nginx/templates/default.template

# Install System and Runtime Dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget python3-minimal aria2 \
    graphviz imagemagick make git git-lfs \
    openjdk-25-jdk-headless plantuml python3-docutils \
    latexmk xindy lmodern texlive-full \
    texlive-fonts-extra texlive-fonts-recommended texlive-font-utils \
    ghostscript dvipng qpdf tikzit qtikz \
    nginx xvfb fontconfig ca-certificates \
    # Draw.io dependencies
    libgl1-mesa-dri libosmesa6 x11-xserver-utils \
    libgtk-3-0t64 libnss3 libxss1 libasound2t64 libgbm1 libx11-xcb1 \
    libxcomposite1 libxrandr2 libxdamage1 libxi6 libxtst6 \
    libglib2.0-0t64 libxext6 libxfixes3 libdrm2 libxshmfence1 \
    libpangocairo-1.0-0 fonts-liberation libgl1 libsecret-1-0 \
    libappindicator3-1 libnotify4 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy compiled assets from Builder Stage
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /staging/plantuml.jar /usr/local/plantuml/plantuml.jar
COPY --from=builder /staging/drawio.deb /tmp/drawio.deb
COPY --from=builder /usr/local/bin/d2 /usr/local/bin/d2

# Copy fonts from the dedicated fonts image
COPY --from=fonts /staging/fonts /usr/share/fonts/truetype/custom

# Install Draw.io
RUN apt-get update && apt-get install -y --no-install-recommends /tmp/drawio.deb && \
    apt-get clean && rm -f /tmp/drawio.deb && rm -rf /var/lib/apt/lists/*

# Install NVM, Node.js (LTS)
# We use a single RUN to ensure the environment setup is encapsulated
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.6/install.sh | bash \
     && mkdir -p $NVM_DIR \
     && mkdir -p /usr/local/bin/{node,npm} \
     && . $NVM_DIR/nvm.sh \
     && nvm install --lts \
     && nvm use --lts \
     && ln -s $(which node) /usr/local/bin/node \
     && ln -s $(which npm) /usr/local/bin/npm

RUN apt-get update && apt-get install -y curl gnupg \
    && curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list \
    && apt-get update && apt-get install -y google-cloud-cli \
    && rm -rf /var/lib/apt/lists/*

# Final Configurations (PlantUML symlink & Font Cache)
RUN export TERM=dumb && \
    ln -sf /usr/local/plantuml/plantuml.jar /usr/share/plantuml/plantuml.jar && \
    fc-cache -f && luaotfload-tool --update --force && \
    mkdir -p /var/lib/texmf/luatex-cache && \
    chmod -R 777 /var/lib/texmf/luatex-cache

WORKDIR /workspaces
