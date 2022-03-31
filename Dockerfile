FROM node:16.14.2-bullseye-slim@sha256:21dd0bf7528e5268640a206c0327fdecba6a0bad1444ea17b4de0c87863d57cc AS builder

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

FROM nginx:1.20.2-alpine@sha256:f6609f898bcdad15047629edc4033d17f9f90e2339fb5ccb97da267f16902251

LABEL maintainer="dmitrii@zakharov.cc"
LABEL org.opencontainers.image.source="https://github.com/toolen/passgen-web-client"

RUN apk upgrade \
    && apk add --no-cache curl=7.79.1-r0

COPY --from=builder /app/dist /usr/share/nginx/html

HEALTHCHECK --interval=30s --timeout=30s --retries=3 CMD curl --silent --show-error http://127.0.0.1 || exit 1
