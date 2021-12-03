FROM node:16.13.1-bullseye-slim@sha256:89f069754327ce042f83175ece2c6f8ffe45b8f82b723372dcd59bb9fa64b08e AS builder
COPY package.json package-lock.json /app/
WORKDIR /app
RUN npm i
COPY gulpfile.js /app/
COPY src /app/src
RUN npm run build

FROM nginx:1.20.2-alpine@sha256:f6609f898bcdad15047629edc4033d17f9f90e2339fb5ccb97da267f16902251
RUN apk add --no-cache curl=7.79.1-r0
COPY --from=builder /app/dist /usr/share/nginx/html
HEALTHCHECK --interval=30s --timeout=30s --retries=3 CMD curl --silent --show-error http://127.0.0.1 || exit 1
