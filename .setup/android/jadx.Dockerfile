FROM alpine:3.23 AS base

RUN apk update \
    && apk add --no-cache openjdk25-jdk

FROM base AS build

RUN apk add --no-cache git

RUN git clone -b v1.5.6 --single-branch --depth 1 https://github.com/skylot/jadx.git /opt/jadx \
    && cd /opt/jadx \
    && ./gradlew dist

FROM base

COPY --from=build /opt/jadx/build/jadx/lib /opt/jadx/lib
COPY --from=build --chmod=+x /opt/jadx/build/jadx/bin/jadx /opt/jadx/bin/jadx

ENTRYPOINT ["/opt/jadx/bin/jadx"]
