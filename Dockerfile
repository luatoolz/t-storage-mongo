# syntax=docker/dockerfile:1

FROM alpine AS builder
ARG LUA_VERSION=jit

RUN apk update && apk upgrade
RUN apk add --no-cache \
  ca-certificates curl \
  build-base gcc git make cmake \
  mongo-c-driver-static \
  libbson-static \
  openssl openssl-dev \
  luarocks

RUN apk add --no-cache	lua${LUA_VERSION}-dev lua${LUA_VERSION}

RUN test "$LUA_VERSION" = "jit" \
  && apk add lua5.1 lua5.1-dev luarocks5.1 \
  && ln -s /usr/bin/luarocks-5.1 /usr/bin/luarocks-jit \
  || apk add --no-cache luarocks${LUA_VERSION}

RUN test -f /usr/bin/luarocks || ln -s /usr/bin/luarocks-${LUA_VERSION} /usr/bin/luarocks
RUN luarocks config --scope system lua_dir /usr

FROM builder AS soft

RUN luarocks install --dev lua-mongo
RUN luarocks install --dev t-storage-mongo

RUN apk del build-base gcc git make cmake openssl-dev && rm -rf /var/cache

FROM scratch
COPY --from=soft / /
