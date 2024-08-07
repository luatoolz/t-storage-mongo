# syntax=docker/dockerfile:1

FROM alpine AS builder
ARG LUA_VERSION=5.1

RUN apk update && apk upgrade
RUN apk add --no-cache \
  ca-certificates curl \
  build-base gcc git make cmake \
	luajit lua-dev lua${LUA_VERSION} \
	luarocks

RUN ln -s /usr/bin/luarocks-${LUA_VERSION} /usr/bin/luarocks
RUN luarocks config --scope system lua_dir /usr

FROM builder AS soft

RUN apk add --no-cache \
  libbson-static \
  mongo-c-driver-static \
  openssl \
  openssl-dev

RUN luarocks install --dev https://raw.githubusercontent.com/luatoolz/lua-mongo/master/lua-mongo-scm-0.rockspec
RUN luarocks install --dev t-storage-mongo

RUN apk del build-base gcc git make cmake openssl-dev zlib-dev libmaxminddb-dev && rm -rf /var/cache

FROM scratch
COPY --from=soft / /
