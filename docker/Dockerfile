# Build from the repository root:
#   docker build -f docker/Dockerfile -t asterctl .
# or simply: docker compose up -d --build

FROM rust:1-bookworm AS builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends pkg-config libudev-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY Cargo.toml Cargo.lock ./
COPY crates ./crates
# the default font is embedded at compile time
COPY fonts ./fonts
RUN cargo build --release -p asterctl -p aster-sysinfo

FROM debian:bookworm-slim

# smartmontools: drive temperatures, libudev1: serial port enumeration,
# tzdata: TZ support for the date/time panel sensors
RUN apt-get update \
    && apt-get install -y --no-install-recommends smartmontools libudev1 tzdata \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /src/target/release/asterctl /src/target/release/aster-sysinfo /app/
COPY cfg /app/cfg
COPY fonts /app/fonts
COPY docker/sensor-mapping/docker.tmpl /app/cfg/sensor-mapping/docker.tmpl
COPY docker/sensor-mapping/docker-filter.cfg /app/cfg/sensor-mapping/docker-filter.cfg
COPY --chmod=755 docker/entrypoint.sh /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
