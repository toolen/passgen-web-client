FROM node:14.16.0-buster AS builder
COPY package.json package-lock.json /app/
WORKDIR /app
RUN npm i
COPY gulpfile.js /app/
COPY src /app/src
RUN npm run build

FROM nginx:1.19.8
COPY --from=builder /app/dist /usr/share/nginx/html
