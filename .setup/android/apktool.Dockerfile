FROM alpine:3.23 AS base

RUN apk update \
    && apk add --no-cache openjdk17-jdk

FROM base AS build

RUN apk add --no-cache git

RUN git clone -b v3.0.3 --single-branch --depth 1 https://github.com/iBotPeaches/Apktool.git /opt/apktool \
    && cd /opt/apktool \
    && ./gradlew --no-daemon release :brut.apktool:apktool-cli:proguard

FROM base

COPY --from=build /opt/apktool/brut.apktool/apktool-cli/build/libs/apktool_3.0.3.jar /opt/apktool.jar

ENTRYPOINT ["java", "-jar", "/opt/apktool.jar"]
