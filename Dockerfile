FROM node:18.19.0-bullseye-slim@sha256:b816d45defe8dc6a07321f05b7e58a841f97e612f6f6ea0a3be44ea7d77474a1 AS builder

LABEL maintainer="dmitrii@zakharov.cc"
LABEL org.opencontainers.image.source="https://github.com/toolen/passgen-web-client"

ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir /app

COPY package.json package-lock.json vite.config.js /app/

COPY src /app/src

WORKDIR /app

RUN set -ex \
    && npm i \
    && npm run build

FROM nginxinc/nginx-unprivileged:1.25.3-alpine3.18-slim@sha256:c9909a627049d4f0f603681f23332fb85aaba78e8c36d546cd7aaf170211d06c

LABEL maintainer="dmitrii@zakharov.cc"
LABEL org.opencontainers.image.source="https://github.com/toolen/passgen-web-client"

USER root

RUN apk upgrade \
    && apk add --no-cache curl=8.5.0-r0

USER nginx

COPY --from=builder /app/dist /usr/share/nginx/html

HEALTHCHECK --interval=30s --timeout=30s --retries=3 CMD curl --silent --show-error http://127.0.0.1 || exit 1
