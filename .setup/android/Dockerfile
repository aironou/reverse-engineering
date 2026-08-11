ARG ANDROID_API_LEVEL=36
ARG ANDROID_TOOLS_VERSION=15859902
ARG ANDROID_ABI=x86_64
ARG ANDROID_AVD_NAME=aironou
ARG ANDROID_HOME=/opt/android

FROM eclipse-temurin:17-jdk-jammy AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update

RUN printf '%s\n' '#!/bin/sh' '' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

FROM base AS build

ARG ANDROID_HOME
ARG ANDROID_TOOLS_VERSION

ARG ANDROID_TOOLS_HOME=${ANDROID_HOME}/tools/${ANDROID_TOOLS_VERSION}
ARG ANDROID_TOOLS_BIN_FOLDER=${ANDROID_TOOLS_HOME}/bin
ARG ANDROID_TOOLS_TMP_FOLDER=/tmp/android-tools
ARG ANDROID_TOOLS_DOWNLOAD_FILE=${ANDROID_TOOLS_TMP_FOLDER}/android-tools.zip

ADD "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_TOOLS_VERSION}_latest.zip" ${ANDROID_TOOLS_DOWNLOAD_FILE}

RUN apt install -yq \
    unzip

RUN mkdir -p ${ANDROID_TOOLS_HOME} \
    && unzip -q ${ANDROID_TOOLS_DOWNLOAD_FILE} -d ${ANDROID_TOOLS_TMP_FOLDER} \
    && mv ${ANDROID_TOOLS_TMP_FOLDER}/cmdline-tools/* ${ANDROID_TOOLS_HOME}

FROM build AS platform-tools-build

ARG ANDROID_HOME
ARG ANDROID_TOOLS_VERSION

ARG ANDROID_TOOLS_HOME=${ANDROID_HOME}/tools/${ANDROID_TOOLS_VERSION}
ARG ANDROID_TOOLS_BIN_FOLDER=${ANDROID_TOOLS_HOME}/bin

RUN ${ANDROID_TOOLS_BIN_FOLDER}/android --sdk "${ANDROID_HOME}" sdk install \
    "platform-tools"

FROM build AS emulator-build

ARG ANDROID_HOME
ARG ANDROID_TOOLS_VERSION
ARG ANDROID_AVD_NAME
ARG ANDROID_API_LEVEL
ARG ANDROID_ABI

ARG ANDROID_TOOLS_HOME=${ANDROID_HOME}/tools/${ANDROID_TOOLS_VERSION}
ARG ANDROID_TOOLS_BIN_FOLDER=${ANDROID_TOOLS_HOME}/bin
ARG ANDROID_AVD_HOME=${ANDROID_HOME}/avd
ARG ANDROID_AVD_CREATED_HOME=${ANDROID_AVD_HOME}/${ANDROID_AVD_NAME}.avd

RUN ${ANDROID_TOOLS_BIN_FOLDER}/android --sdk "${ANDROID_HOME}" sdk install \
    "emulator" \
    "system-images;android-${ANDROID_API_LEVEL};google_apis_playstore;${ANDROID_ABI}"

RUN mkdir -p ${ANDROID_AVD_CREATED_HOME} \
    && ${ANDROID_TOOLS_BIN_FOLDER}/avdmanager -s create avd \
    --force \
    --path ${ANDROID_AVD_CREATED_HOME} \
    --package "system-images;android-${ANDROID_API_LEVEL};google_apis_playstore;${ANDROID_ABI}" \
    --name ${ANDROID_AVD_NAME}

FROM base AS emulator-dependencies

RUN apt install -yq --no-install-recommends \
    libpulse0 \
    libnss3 \
    libdrm2 \
    libxi6 \
    libxkbfile1 \
    libbsd0 \
    libxrandr2 \
    libxcursor1 \
    libxinerama1 \
    libfontconfig1 \
    libgl1 \
    mesa-vulkan-drivers \
    libxcb-cursor0 \
    libxkbcommon-x11-0 \
    libxcb-icccm4 \
    libxcb-keysyms1 \
    libxcb-shape0 \
    libxcb-xinerama0 \
    libxcomposite1 \
    libxtst6 \
    libsm6

FROM emulator-dependencies AS emulator

ARG ANDROID_HOME
ARG ANDROID_AVD_NAME

ARG ANDROID_EMULATOR_HOME=${ANDROID_HOME}/emulator
ARG ANDROID_AVD_HOME=${ANDROID_HOME}/avd
ARG ANDROID_SYSTEM_IMAGES_HOME=${ANDROID_HOME}/system-images

ENV ANDROID_AVD_HOME=${ANDROID_AVD_HOME}
ENV ANDROID_HOME=${ANDROID_HOME}

COPY --from=emulator-build ${ANDROID_EMULATOR_HOME} ${ANDROID_EMULATOR_HOME}
COPY --from=emulator-build ${ANDROID_AVD_HOME} ${ANDROID_AVD_HOME}
COPY --from=emulator-build ${ANDROID_SYSTEM_IMAGES_HOME} ${ANDROID_SYSTEM_IMAGES_HOME}

RUN printf '%s\n' \
        "find ${ANDROID_AVD_HOME} -name '*.lock' -exec rm -rfv -- {} +" \
        "exec ${ANDROID_EMULATOR_HOME}/emulator -avd ${ANDROID_AVD_NAME} \"\$@\"" \
    >> entrypoint.sh \
    && mkdir -p ${ANDROID_HOME}/platform-tools

ENTRYPOINT ["/entrypoint.sh"]

FROM base AS adb

ARG ANDROID_HOME

ARG ANDROID_ADB_HOME=${ANDROID_HOME}/platform-tools

COPY --from=platform-tools-build ${ANDROID_ADB_HOME} ${ANDROID_ADB_HOME}

RUN echo -n "${ANDROID_ADB_HOME}/adb \"\$@\"" >> entrypoint.sh \
    && chmod +x ${ANDROID_ADB_HOME}/adb

ENTRYPOINT ["/entrypoint.sh"]
