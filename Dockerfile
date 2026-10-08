# syntax=docker/dockerfile:1

# ---- Build stage: mirrors the upstream CI Linux environment ----
# g++-14 / libstdc++-14-dev provide the libstdc++ that Clang links against
# (full C++23 library support: std::print, ranges, ...).
FROM ubuntu:24.04 AS build

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        clang \
        cmake \
        g++-14 \
        git \
        libstdc++-14-dev \
        ninja-build \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# Submodules (protobufs, s2sdk) must be checked out before building the context;
# sqlite and steamworks are vendored directly in the repository tree.
COPY . .

RUN cmake --preset release \
        -DCMAKE_CXX_FLAGS=--gcc-install-dir=/usr/lib/gcc/x86_64-linux-gnu/14 \
        -DCMAKE_BUILD_RPATH='$ORIGIN' \
    && cmake --build --preset release

# ---- Runtime stage ----
FROM ubuntu:24.04

# Copy the exact C++ runtime the binary was linked against: the base image's
# libstdc++ is older than the GCC 14 one the build uses.
COPY --from=build /usr/lib/x86_64-linux-gnu/libstdc++.so.6* /app/lib/
COPY --from=build /usr/lib/x86_64-linux-gnu/libgcc_s.so.1 /app/lib/

COPY --from=build /src/build/release/bin/cs2-egg-checker-server /app/
COPY --from=build /src/build/release/bin/libsteam_api.so /app/
COPY docker-entrypoint.sh /app/

RUN chmod +x /app/docker-entrypoint.sh && mkdir -p /data

ENV LD_LIBRARY_PATH=/app:/app/lib \
    DBPATH=/data/egg.db

WORKDIR /app
VOLUME /data

ENTRYPOINT ["/app/docker-entrypoint.sh"]
