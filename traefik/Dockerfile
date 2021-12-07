ARG WINBASE=scratch
FROM --platform=$BUILDPLATFORM curlimages/curl:7.80.0 AS build
ARG TRAEFIK_VERSION
WORKDIR /src
RUN curl -Lo traefik.zip https://github.com/traefik/traefik/releases/download/${TRAEFIK_VERSION}/traefik_${TRAEFIK_VERSION}_windows_amd64.zip ; \
    unzip traefik.zip

FROM ${WINBASE} AS windows
ARG TRAEFIK_VERSION
EXPOSE 80
LABEL org.opencontainers.image.vendor="Markus Lippert" \
      org.opencontainers.image.url="https://traefik.io" \
      org.opencontainers.image.title="Traefik" \
      org.opencontainers.image.description="A modern reverse-proxy" \
      org.opencontainers.image.version="${TRAEFIK_VERSION}" \
      org.opencontainers.image.documentation="https://docs.traefik.io"
ENTRYPOINT [ "traefik.exe" ]
COPY --from=build /src/traefik.exe traefik.exe