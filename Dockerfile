FROM node:18.12.1-bullseye-slim@sha256:0c3ea57b6c560f83120801e222691d9bd187c605605185810752a19225b5e4d9 AS builder

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

FROM nginx:1.22.1-alpine@sha256:43cd1aa2a26fbe7e6a4f9ba6cc289ea885731fbafe078b62983325a60c8c2c56

LABEL maintainer="dmitrii@zakharov.cc"
LABEL org.opencontainers.image.source="https://github.com/toolen/passgen-web-client"

RUN apk upgrade \
    && apk add --no-cache curl=7.83.1-r5

COPY --from=builder /app/dist /usr/share/nginx/html

HEALTHCHECK --interval=30s --timeout=30s --retries=3 CMD curl --silent --show-error http://127.0.0.1 || exit 1
