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

FROM nginxinc/nginx-unprivileged:1.26-alpine3.20@sha256:a6c15b8056a0b9c4551d1f32ccde5020f3742beb09cb3e36d76a3f1bbe0bc6eb

LABEL maintainer="dmitrii@zakharov.cc"
LABEL org.opencontainers.image.source="https://github.com/toolen/passgen-web-client"

USER root

RUN apk upgrade \
    && apk add --no-cache curl=8.11.1-r0

USER nginx

COPY --from=builder /app/dist /usr/share/nginx/html

HEALTHCHECK --interval=30s --timeout=30s --retries=3 CMD curl --silent --show-error http://127.0.0.1 || exit 1
