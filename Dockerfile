#
# Phase: Build
#

ARG MARVIN_VERSION
ARG REGISTRY_NAME

FROM golang:1.17.9-alpine3.15 AS builder

# Necessary dependencies
RUN echo "https://mirror.csclub.uwaterloo.ca/alpine/v3.15/main" >/etc/apk/repositories
RUN echo "https://mirror.csclub.uwaterloo.ca/alpine/v3.15/community" >>/etc/apk/repositories
RUN apk update

# apk add
RUN apk add --no-cache git
RUN apk add --upgrade --no-cache bash curl musl openssh openssh-client gcc build-base

### Application ###
RUN mkdir /app /code

# Copy the code
COPY . /code
WORKDIR /code


### Toolbox ###
RUN mkdir /toolbox


# Set permissions and create user to run analyzers
RUN chmod -R o-rwx /code /toolbox
RUN chown -R 1000:3000 /toolbox /code
RUN adduser -D -u 1000 runner && mkdir -p /home/runner && chown -R 1000:3000 /home/runner

USER root

# Necessary dependencies
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.16/main" >/etc/apk/repositories
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.16/community" >>/etc/apk/repositories
RUN apk update && \
    apk upgrade && \
    apk add --no-cache git

RUN apk add --no-cache bash curl go build-base musl-dev openssh grep

# Copy the builds
COPY --from=builder /app /app

#
# Phase: Analyzer

# Install hadolint
RUN wget -O /toolbox/hadolint https://github.com/hadolint/hadolint/releases/download/v1.17.2/hadolint-Linux-x86_64
RUN chmod u+x /toolbox/hadolint && chown -R 1000:3000 /toolbox/hadolint

USER runner
