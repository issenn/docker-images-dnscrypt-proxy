# syntax=docker/dockerfile:1

ARG BUILDPLATFORM="linux/amd64"

FROM --platform=${BUILDPLATFORM} alpine:3.17 AS prepare

SHELL ["/bin/ash", "-eufo", "pipefail", "-c"]

RUN apk --no-cache add \
    curl=~7.87.0 \
    # sed=~4.9 \
    git=~2.38 \
    # go=~1.19.5 \
    # bash=~5.2.15 \
    ca-certificates=~20220614 && \
    sync

ARG PACKAGE_NAME
ARG PACKAGE_VERSION
ARG PACKAGE_VERSION_PREFIX
ARG PACKAGE_URL
ARG PACKAGE_SOURCE_URL
ARG PACKAGE_HEAD_URL
ARG PACKAGE_HEAD=false

# hadolint ignore=SC2015
RUN { [ -n "${PACKAGE_VERSION_PREFIX}" ] && PACKAGE_VERSION="${PACKAGE_VERSION_PREFIX}${PACKAGE_VERSION}" || true; } && mkdir -p "/usr/local/src/${PACKAGE_NAME}" && \
    [ -n "${PACKAGE_NAME}" ] && \
    { { [ -n "${PACKAGE_HEAD_URL}" ] && \
        git clone "${PACKAGE_HEAD_URL}" "/usr/local/src/${PACKAGE_NAME}" && \
        { { { [ -n "${PACKAGE_VERSION}" ] && [ "${PACKAGE_HEAD}" != true ] && [ "${PACKAGE_HEAD}" != "on" ] && [ "${PACKAGE_HEAD}" != "1" ] && \
              git -C "/usr/local/src/${PACKAGE_NAME}" checkout tags/${PACKAGE_VERSION}; } && \
            { [ -n "${PACKAGE_VERSION}" ] && [ "${PACKAGE_HEAD}" != true ] && [ "${PACKAGE_HEAD}" != "on" ] && [ "${PACKAGE_HEAD}" != "1" ]; }; } || \
          { { ! { [ -n "${PACKAGE_VERSION}" ] && [ "${PACKAGE_HEAD}" != true ] && [ "${PACKAGE_HEAD}" != "on" ] && [ "${PACKAGE_HEAD}" != "1" ] && \
              git -C "/usr/local/src/${PACKAGE_NAME}" checkout tags/${PACKAGE_VERSION}; }; } && \
            { ! { [ -n "${PACKAGE_VERSION}" ] && [ "${PACKAGE_HEAD}" != true ] && [ "${PACKAGE_HEAD}" != "on" ] && [ "${PACKAGE_HEAD}" != "1" ]; }; }; }; }; } || \
      { [ -n "${PACKAGE_SOURCE_URL}" ] && curl -fsSL "${PACKAGE_SOURCE_URL}" | \
        tar -zxC "/usr/local/src/${PACKAGE_NAME}" --strip 1; } || \
      { [ -n "${PACKAGE_URL}" ] && [ -n "${PACKAGE_VERSION}" ] && \
        curl -fsSL "${PACKAGE_URL}/archive/${PACKAGE_VERSION}.tar.gz" | \
        tar -zxC "/usr/local/src/${PACKAGE_NAME}" --strip 1; }; } || false

# ----------------------------------------------------------------------------

FROM --platform=${BUILDPLATFORM} golang:1.19.5-alpine3.17 AS build

RUN apk --no-cache add \
    # curl=~7.87.0 \
    # sed=~4.9 \
    git=~2.38 \
    # go=~1.19.5 \
    # bash=~5.2.15 \
    ca-certificates=~20220614 && \
    sync

SHELL ["/bin/ash", "-eufo", "pipefail", "-c"]

ARG PACKAGE_NAME
ARG PACKAGE_VERSION
ARG PACKAGE_URL
ARG PACKAGE_SOURCE_URL
ARG PACKAGE_HEAD_URL
ARG PACKAGE_HEAD=false

ARG TARGETOS TARGETARCH TARGETVARIANT
ARG CGO_ENABLED=0
ARG BUILD_FLAGS="-v"
ARG GO111MODULE
ARG GOPROXY

ENV GOOS=${TARGETOS} \
    GOARCH=${TARGETARCH}

COPY --from=prepare /etc/passwd /etc/group /etc/
COPY --from=prepare /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --from=prepare --chown=nonroot:nonroot /usr/local/src /usr/local/src

WORKDIR /usr/local/src/${PACKAGE_NAME}

# hadolint ignore=DL3003
RUN --mount=type=cache,target=/home/nonroot/.cache/go-build,uid=65532,gid=65532 \
    --mount=type=cache,target=/go/pkg \
        TARGETVARIANT=$(printf "%s" "${TARGETVARIANT}" | sed 's/v//g') && \
        CGO_ENABLED=${CGO_ENABLED} GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOARM=${TARGETVARIANT} go mod vendor && \
        cd ${PACKAGE_NAME} && \
        CGO_ENABLED=${CGO_ENABLED} GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOARM=${TARGETVARIANT} \
        go build ${BUILD_FLAGS} -ldflags="-s -w" -mod vendor && \
        sync

WORKDIR /etc/${PACKAGE_NAME}

RUN cp -a /usr/local/src/${PACKAGE_NAME}/${PACKAGE_NAME}/localhost.pem \
          /usr/local/src/${PACKAGE_NAME}/${PACKAGE_NAME}/example-allowed-ips.txt \
          /usr/local/src/${PACKAGE_NAME}/${PACKAGE_NAME}/example-allowed-names.txt \
          /usr/local/src/${PACKAGE_NAME}/${PACKAGE_NAME}/example-blocked-ips.txt \
          /usr/local/src/${PACKAGE_NAME}/${PACKAGE_NAME}/example-blocked-names.txt \
          /usr/local/src/${PACKAGE_NAME}/${PACKAGE_NAME}/example-captive-portals.txt \
          /usr/local/src/${PACKAGE_NAME}/${PACKAGE_NAME}/example-cloaking-rules.txt \
          /usr/local/src/${PACKAGE_NAME}/${PACKAGE_NAME}/example-dnscrypt-proxy.toml \
          /usr/local/src/${PACKAGE_NAME}/${PACKAGE_NAME}/example-forwarding-rules.txt \
          ./

COPY dnscrypt-proxy.toml ./

# ----------------------------------------------------------------------------

FROM --platform=${BUILDPLATFORM} scratch

ARG PACKAGE_NAME

COPY --from=build /etc/passwd /etc/group /etc/
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --from=build /usr/local/src/${PACKAGE_NAME}/${PACKAGE_NAME}/${PACKAGE_NAME} /usr/local/bin/
COPY --from=build --chown=nobody:nogroup /etc/${PACKAGE_NAME} /etc/${PACKAGE_NAME}

# TODO: switch to 'nonroot' user
USER nobody

ENTRYPOINT [ "dnscrypt-proxy" ]

CMD [ "-config", "/etc/dnscrypt-proxy/dnscrypt-proxy.toml" ]
