FROM alpine:latest

LABEL maintainer="Kyverno<hi@kyverno.io>"

RUN apk add --no-cache \
    curl \
    git \
    openssh-client \
    rsync \
    build-base \
    libc6-compat \
    npm

ARG HUGO_VERSION 
WORKDIR /src

RUN npm install postcss-cli
RUN npm install autoprefixer
RUN npm install

RUN mkdir -p /usr/local/src && \
    cd /usr/local/src && \
    curl -L https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz | tar -xz && \
    mv hugo /usr/local/bin/hugo && \
    addgroup -Sg 1000 hugo && \
    adduser -Sg hugo -u 1000 -h /src hugo


USER hugo:hugo


EXPOSE 1313