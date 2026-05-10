# syntax=docker/dockerfile:1

FROM debian:bookworm-slim AS builder

ARG FASTANI_VERSION=v1.34
ARG FASTANI_URL=https://github.com/ParBLiSS/FastANI/archive/refs/tags/v1.34.tar.gz
ARG FASTANI_SHA256=dc185cf29b9fa40cdcc2c83bb48150db46835e49b9b64a3dbff8bc4d0f631cb1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates curl cmake make g++ \
      zlib1g-dev libboost-dev libboost-program-options-dev libboost-iostreams-dev \
      libboost-filesystem-dev libboost-math-dev libgsl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN curl -fsSL "$FASTANI_URL" -o fastani.tar.gz \
    && echo "$FASTANI_SHA256  fastani.tar.gz" | sha256sum -c - \
    && tar -xzf fastani.tar.gz

WORKDIR /src/FastANI-1.34/build
RUN cmake -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=Release .. \
    && make -j2 \
    && test -x fastANI \
    && cp fastANI /tmp/fastANI

RUN mkdir -p /tmp/runtime-libs \
    && (ldd /tmp/fastANI | awk '/=> \/|^\// {for(i=1;i<=NF;i++) if ($i ~ /^\//) print $i}' | sort -u | xargs -r -I{} cp -v --parents "{}" /tmp/runtime-libs) || true

FROM debian:bookworm-slim
COPY --from=builder /tmp/fastANI /usr/local/bin/fastANI
COPY --from=builder /tmp/runtime-libs/ /

RUN ln -sf /usr/local/bin/fastANI /usr/local/bin/fastani \
    && printf '%s\n' '#!/bin/sh' \
    'if [ "${1:-}" = "fastani" ] || [ "${1:-}" = "fastANI" ]; then shift; fi' \
    'exec /usr/local/bin/fastANI "$@"' > /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
