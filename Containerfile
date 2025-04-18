FROM arm64v8/debian:bullseye-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl xz-utils sudo git gnupg2 \
    && rm -rf /var/lib/apt/lists/*

# Define volume for Nix store
VOLUME ["/nix"]

# Install Nix
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux \
  --extra-conf "sandbox = false" \
  --init none \
  --no-confirm

ENV PATH="${PATH}:/nix/var/nix/profiles/default/bin"

# Create build directory
WORKDIR /build

# Copy your Nix files
COPY . .

# Setup nix.conf to enable experimental features
RUN mkdir -p /root/.config/nix && \
    echo "experimental-features = nix-command flakes" > /root/.config/nix/nix.conf
