# syntax = docker/dockerfile:1

# ARG BUILDPLATFORM="linux/amd64"

# https://github.com/orgs/chainguard-images/packages
FROM cgr.dev/chainguard/wolfi-base:latest-20230115 AS prepare

ARG DNSCRYPT_PROXY_VERSION=2.1.2

RUN apk update && \
    apk add --no-cache --update-cache \
      ca-certificates=20220614 \
      curl=7.87.0 \
      bash=5.2

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN mkdir -p /usr/local/src \
    && curl -fsSL "https://github.com/DNSCrypt/dnscrypt-proxy/archive/${DNSCRYPT_PROXY_VERSION}.tar.gz" \
    | tar -zxC /usr/local/src --strip 1

# ----------------------------------------------------------------------------

FROM --platform=${BUILDPLATFORM} cgr.dev/chainguard/go:1.19 AS build

ARG TARGETOS TARGETARCH

COPY --from=prepare /etc/passwd /etc/group /etc/
COPY --from=prepare /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --from=prepare --chown=nonroot:nonroot /usr/local/src /usr/local/src

WORKDIR /usr/local/src

# hadolint ignore=DL3003
RUN --mount=type=cache,target=/home/nonroot/.cache/go-build,uid=65532,gid=65532 \
    --mount=type=cache,target=/go/pkg \
        CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go mod vendor \
        && cd dnscrypt-proxy \
        && CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -v -ldflags="-s -w" -mod vendor

WORKDIR /etc/dnscrypt-proxy

RUN cp -a /usr/local/src/dnscrypt-proxy/example-* ./

COPY dnscrypt-proxy.toml ./

# ----------------------------------------------------------------------------

FROM cgr.dev/chainguard/static:latest-glibc-20230115

COPY --from=build /etc/passwd /etc/group /etc/
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --from=build /usr/local/src/dnscrypt-proxy/dnscrypt-proxy /usr/local/bin/
COPY --from=build --chown=nobody:nogroup /etc/dnscrypt-proxy /etc/dnscrypt-proxy

# TODO: switch to 'nonroot' user
USER nobody

ENTRYPOINT [ "dnscrypt-proxy" ]

CMD [ "-config", "/etc/dnscrypt-proxy/dnscrypt-proxy.toml" ]
