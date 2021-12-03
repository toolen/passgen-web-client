FROM node:16.13.1-bullseye-slim@sha256:89f069754327ce042f83175ece2c6f8ffe45b8f82b723372dcd59bb9fa64b08e AS builder
COPY package.json package-lock.json /app/
WORKDIR /app
RUN npm i
COPY gulpfile.js /app/
COPY src /app/src
RUN npm run build

FROM joseluisq/static-web-server:1.18.2-alpine@sha256:238341e4a9e9fecd5bfafc3e48aff2ea6cf080aeff3932eeb3f132a45e645959
RUN apk update && \
    apk upgrade && \
    apk add --no-cache --update \
      curl=7.79.1-r0
COPY --from=builder /app/dist /public
HEALTHCHECK --interval=30s --timeout=30s --retries=3 CMD curl -sS http://127.0.0.1 || exit 1