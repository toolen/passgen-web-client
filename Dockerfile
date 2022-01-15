FROM node:16.13.2-bullseye-slim@sha256:247f823613bb67e079fc9be272c6535c45bba13d5620fc38e131fc83d1fad61f AS builder
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
