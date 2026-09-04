ARG ANDROID_API_LEVEL=36
ARG ANDROID_TOOLS_VERSION=15859902
ARG ANDROID_ABI=x86_64
ARG ANDROID_BUILD_TOOLS_VERSION=36.0.0
ARG ANDROID_AVD_NAME=aironou
ARG ANDROID_HOME=/opt/android
ARG ANDROID_TOOLS_HOME=${ANDROID_HOME}/cmdline-tools/${ANDROID_TOOLS_VERSION}
ARG ANDROID_TOOLS_BIN_FOLDER=${ANDROID_TOOLS_HOME}/bin
ARG ANDROID_TOOLS_LIB_FOLDER=${ANDROID_TOOLS_HOME}/lib
ARG ANDROID_BUILD_TOOLS_HOME=${ANDROID_HOME}/build-tools/${ANDROID_BUILD_TOOLS_VERSION}

FROM eclipse-temurin:17-jdk-jammy AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update

RUN printf '%s\n' '#!/bin/sh' '' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

FROM base AS build

ARG ANDROID_TOOLS_HOME
ARG ANDROID_TOOLS_VERSION
ARG ANDROID_TOOLS_BIN_FOLDER

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
ARG ANDROID_TOOLS_BIN_FOLDER

RUN ${ANDROID_TOOLS_BIN_FOLDER}/android --sdk "${ANDROID_HOME}" sdk install \
    "platform-tools"

FROM build AS emulator-build

ARG ANDROID_HOME
ARG ANDROID_AVD_NAME
ARG ANDROID_API_LEVEL
ARG ANDROID_ABI
ARG ANDROID_TOOLS_BIN_FOLDER

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

FROM base AS adb

ARG ANDROID_HOME

ARG ANDROID_ADB_HOME=${ANDROID_HOME}/platform-tools

COPY --from=platform-tools-build ${ANDROID_ADB_HOME} ${ANDROID_ADB_HOME}

RUN echo -n "${ANDROID_ADB_HOME}/adb \"\$@\"" >> entrypoint.sh \
    && chmod +x ${ANDROID_ADB_HOME}/adb

FROM build AS build-tools

ARG ANDROID_HOME
ARG ANDROID_BUILD_TOOLS_VERSION
ARG ANDROID_TOOLS_BIN_FOLDER

RUN ${ANDROID_TOOLS_BIN_FOLDER}/android --sdk "${ANDROID_HOME}" sdk install \
    "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"

FROM base AS apkanalyzer

ARG ANDROID_TOOLS_BIN_FOLDER
ARG ANDROID_TOOLS_LIB_FOLDER
ARG ANDROID_BUILD_TOOLS_HOME

COPY --from=build-tools ${ANDROID_TOOLS_BIN_FOLDER}/apkanalyzer ${ANDROID_TOOLS_BIN_FOLDER}/apkanalyzer
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/apkanalyzer-classpath.jar ${ANDROID_TOOLS_LIB_FOLDER}/apkanalyzer-classpath.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/apkparser/cli/analyzer-cli.jar ${ANDROID_TOOLS_LIB_FOLDER}/apkparser/cli/analyzer-cli.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/apkparser/tools.binary-resources.jar ${ANDROID_TOOLS_LIB_FOLDER}/apkparser/tools.binary-resources.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/com/google/guava/guava/33.4.0-jre/guava-33.4.0-jre.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/com/google/guava/guava/33.4.0-jre/guava-33.4.0-jre.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/com/google/guava/failureaccess/1.0.2/failureaccess-1.0.2.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/com/google/guava/failureaccess/1.0.2/failureaccess-1.0.2.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/com/google/guava/listenablefuture/9999.0-empty-to-avoid-conflict-with-guava/listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/com/google/guava/listenablefuture/9999.0-empty-to-avoid-conflict-with-guava/listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/com/google/code/findbugs/jsr305/3.0.2/jsr305-3.0.2.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/com/google/code/findbugs/jsr305/3.0.2/jsr305-3.0.2.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/org/checkerframework/checker-qual/3.43.0/checker-qual-3.43.0.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/org/checkerframework/checker-qual/3.43.0/checker-qual-3.43.0.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/com/google/errorprone/error_prone_annotations/2.36.0/error_prone_annotations-2.36.0.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/com/google/errorprone/error_prone_annotations/2.36.0/error_prone_annotations-2.36.0.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/com/google/j2objc/j2objc-annotations/3.0.0/j2objc-annotations-3.0.0.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/com/google/j2objc/j2objc-annotations/3.0.0/j2objc-annotations-3.0.0.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/apkparser/analyzer/analyzer.jar ${ANDROID_TOOLS_LIB_FOLDER}/apkparser/analyzer/analyzer.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/archive-patcher/explainer.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/archive-patcher/explainer.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/archive-patcher/generator.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/archive-patcher/generator.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/archive-patcher/shared.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/archive-patcher/shared.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/common/tools.common.jar ${ANDROID_TOOLS_LIB_FOLDER}/common/tools.common.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/annotations/annotations.jar ${ANDROID_TOOLS_LIB_FOLDER}/annotations/annotations.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/net/java/dev/jna/jna-platform/5.6.0/jna-platform-5.6.0.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/net/java/dev/jna/jna-platform/5.6.0/jna-platform-5.6.0.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/net/java/dev/jna/jna/5.14.0/jna-5.14.0.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/net/java/dev/jna/jna/5.14.0/jna-5.14.0.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/org/jetbrains/kotlin/kotlin-stdlib-jdk8/2.2.10/kotlin-stdlib-jdk8-2.2.10.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/org/jetbrains/kotlin/kotlin-stdlib-jdk8/2.2.10/kotlin-stdlib-jdk8-2.2.10.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/org/jetbrains/kotlin/kotlin-stdlib/2.2.10/kotlin-stdlib-2.2.10.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/org/jetbrains/kotlin/kotlin-stdlib/2.2.10/kotlin-stdlib-2.2.10.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/org/jetbrains/annotations/23.0.0/annotations-23.0.0.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/org/jetbrains/annotations/23.0.0/annotations-23.0.0.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/org/jetbrains/kotlin/kotlin-stdlib-jdk7/2.2.10/kotlin-stdlib-jdk7-2.2.10.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/org/jetbrains/kotlin/kotlin-stdlib-jdk7/2.2.10/kotlin-stdlib-jdk7-2.2.10.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/sdk-common/tools.sdk-common.jar ${ANDROID_TOOLS_LIB_FOLDER}/sdk-common/tools.sdk-common.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/analytics-library/shared/tools.analytics-shared.jar ${ANDROID_TOOLS_LIB_FOLDER}/analytics-library/shared/tools.analytics-shared.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/analytics-library/protos/src/main/proto/proto.jar ${ANDROID_TOOLS_LIB_FOLDER}/analytics-library/protos/src/main/proto/proto.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/com/google/protobuf/protobuf-java/3.25.5/protobuf-java-3.25.5.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/com/google/protobuf/protobuf-java/3.25.5/protobuf-java-3.25.5.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/com/google/code/gson/gson/2.11.0/gson-2.11.0.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/com/google/code/gson/gson/2.11.0/gson-2.11.0.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/org/jetbrains/kotlinx/kotlinx-coroutines-core/1.9.0/kotlinx-coroutines-core-1.9.0.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/org/jetbrains/kotlinx/kotlinx-coroutines-core/1.9.0/kotlinx-coroutines-core-1.9.0.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/org/jetbrains/kotlinx/kotlinx-coroutines-core-jvm/1.10.2/kotlinx-coroutines-core-jvm-1.10.2.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/org/jetbrains/kotlinx/kotlinx-coroutines-core-jvm/1.10.2/kotlinx-coroutines-core-jvm-1.10.2.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/build-system/aapt2-proto/aapt2-proto.jar ${ANDROID_TOOLS_LIB_FOLDER}/build-system/aapt2-proto/aapt2-proto.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/ddmlib/tools.ddmlib.jar ${ANDROID_TOOLS_LIB_FOLDER}/ddmlib/tools.ddmlib.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/net/sf/kxml/kxml2/2.3.0/kxml2-2.3.0.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/net/sf/kxml/kxml2/2.3.0/kxml2-2.3.0.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/layoutlib-api/tools.layoutlib-api.jar ${ANDROID_TOOLS_LIB_FOLDER}/layoutlib-api/tools.layoutlib-api.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/sdklib/tools.sdklib.jar ${ANDROID_TOOLS_LIB_FOLDER}/sdklib/tools.sdklib.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/repository/tools.repository.jar ${ANDROID_TOOLS_LIB_FOLDER}/repository/tools.repository.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/com/google/jimfs/jimfs/1.1/jimfs-1.1.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/com/google/jimfs/jimfs/1.1/jimfs-1.1.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/org/apache/commons/commons-compress/1.27.1/commons-compress-1.27.1.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/org/apache/commons/commons-compress/1.27.1/commons-compress-1.27.1.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/commons-codec/commons-codec/1.17.1/commons-codec-1.17.1.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/commons-codec/commons-codec/1.17.1/commons-codec-1.17.1.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/commons-io/commons-io/2.16.1/commons-io-2.16.1.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/commons-io/commons-io/2.16.1/commons-io-2.16.1.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/org/apache/commons/commons-lang3/3.16.0/commons-lang3-3.16.0.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/org/apache/commons/commons-lang3/3.16.0/commons-lang3-3.16.0.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/org/glassfish/jaxb/jaxb-runtime/2.3.2/jaxb-runtime-2.3.2.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/org/glassfish/jaxb/jaxb-runtime/2.3.2/jaxb-runtime-2.3.2.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/jakarta/xml/bind/jakarta.xml.bind-api/2.3.2/jakarta.xml.bind-api-2.3.2.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/jakarta/xml/bind/jakarta.xml.bind-api/2.3.2/jakarta.xml.bind-api-2.3.2.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/jakarta/activation/jakarta.activation-api/1.2.1/jakarta.activation-api-1.2.1.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/jakarta/activation/jakarta.activation-api/1.2.1/jakarta.activation-api-1.2.1.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/org/glassfish/jaxb/txw2/2.3.2/txw2-2.3.2.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/org/glassfish/jaxb/txw2/2.3.2/txw2-2.3.2.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/com/sun/istack/istack-commons-runtime/3.0.8/istack-commons-runtime-3.0.8.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/com/sun/istack/istack-commons-runtime/3.0.8/istack-commons-runtime-3.0.8.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/org/jvnet/staxex/stax-ex/1.8.1/stax-ex-1.8.1.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/org/jvnet/staxex/stax-ex/1.8.1/stax-ex-1.8.1.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/com/sun/xml/fastinfoset/FastInfoset/1.2.16/FastInfoset-1.2.16.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/com/sun/xml/fastinfoset/FastInfoset/1.2.16/FastInfoset-1.2.16.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/device_validator/tools.dvlib.jar ${ANDROID_TOOLS_LIB_FOLDER}/device_validator/tools.dvlib.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/org/apache/httpcomponents/httpcore/4.4.16/httpcore-4.4.16.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/org/apache/httpcomponents/httpcore/4.4.16/httpcore-4.4.16.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/org/apache/httpcomponents/httpmime/4.5.6/httpmime-4.5.6.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/org/apache/httpcomponents/httpmime/4.5.6/httpmime-4.5.6.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/org/apache/httpcomponents/httpclient/4.5.14/httpclient-4.5.14.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/org/apache/httpcomponents/httpclient/4.5.14/httpclient-4.5.14.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/commons-logging/commons-logging/1.2/commons-logging-1.2.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/commons-logging/commons-logging/1.2/commons-logging-1.2.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/javax/inject/javax.inject/1/javax.inject-1.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/javax/inject/javax.inject/1/javax.inject-1.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/org/bouncycastle/bcpkix-jdk18on/1.79/bcpkix-jdk18on-1.79.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/org/bouncycastle/bcpkix-jdk18on/1.79/bcpkix-jdk18on-1.79.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/org/bouncycastle/bcprov-jdk18on/1.79/bcprov-jdk18on-1.79.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/org/bouncycastle/bcprov-jdk18on/1.79/bcprov-jdk18on-1.79.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/org/bouncycastle/bcutil-jdk18on/1.79/bcutil-jdk18on-1.79.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/org/bouncycastle/bcutil-jdk18on/1.79/bcutil-jdk18on-1.79.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/org/jetbrains/kotlin/kotlin-reflect/2.2.10/kotlin-reflect-2.2.10.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/org/jetbrains/kotlin/kotlin-reflect/2.2.10/kotlin-reflect-2.2.10.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/zipflinger/zipflinger.jar ${ANDROID_TOOLS_LIB_FOLDER}/zipflinger/zipflinger.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/com/android/tools/smali/smali-baksmali/3.0.9/smali-baksmali-3.0.9.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/com/android/tools/smali/smali-baksmali/3.0.9/smali-baksmali-3.0.9.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/com/android/tools/smali/smali-util/3.0.9/smali-util-3.0.9.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/com/android/tools/smali/smali-util/3.0.9/smali-util-3.0.9.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/com/android/tools/smali/smali-dexlib2/3.0.9/smali-dexlib2-3.0.9.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/com/android/tools/smali/smali-dexlib2/3.0.9/smali-dexlib2-3.0.9.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/com/beust/jcommander/1.78/jcommander-1.78.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/com/beust/jcommander/1.78/jcommander-1.78.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/profgen/profgen/libprofgen.jar ${ANDROID_TOOLS_LIB_FOLDER}/profgen/profgen/libprofgen.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/org/ow2/asm/asm/9.9/asm-9.9.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/org/ow2/asm/asm/9.9/asm-9.9.jar
COPY --from=build-tools ${ANDROID_TOOLS_LIB_FOLDER}/external/net/sf/jopt-simple/jopt-simple/4.9/jopt-simple-4.9.jar ${ANDROID_TOOLS_LIB_FOLDER}/external/net/sf/jopt-simple/jopt-simple/4.9/jopt-simple-4.9.jar
COPY --from=build-tools ${ANDROID_BUILD_TOOLS_HOME}/aapt ${ANDROID_BUILD_TOOLS_HOME}/aapt
COPY --from=build-tools ${ANDROID_BUILD_TOOLS_HOME}/lib64/libc++.so ${ANDROID_BUILD_TOOLS_HOME}/lib64/libc++.so
COPY --from=build-tools ${ANDROID_BUILD_TOOLS_HOME}/source.properties ${ANDROID_BUILD_TOOLS_HOME}/source.properties
COPY --from=build-tools ${ANDROID_BUILD_TOOLS_HOME}/package.xml ${ANDROID_BUILD_TOOLS_HOME}/package.xml

RUN echo -n "${ANDROID_TOOLS_BIN_FOLDER}/apkanalyzer \"\$@\"" >> entrypoint.sh \
    && chmod +x ${ANDROID_TOOLS_BIN_FOLDER}/apkanalyzer

FROM base AS aapt2

ARG ANDROID_BUILD_TOOLS_HOME

COPY --from=build-tools ${ANDROID_BUILD_TOOLS_HOME}/aapt2 ${ANDROID_BUILD_TOOLS_HOME}/aapt2

RUN echo -n "${ANDROID_BUILD_TOOLS_HOME}/aapt2 \"\$@\"" >> entrypoint.sh \
    && chmod +x ${ANDROID_BUILD_TOOLS_HOME}/aapt2

FROM base AS apksigner

ARG ANDROID_BUILD_TOOLS_HOME

COPY --from=build-tools ${ANDROID_BUILD_TOOLS_HOME}/apksigner ${ANDROID_BUILD_TOOLS_HOME}/apksigner
COPY --from=build-tools ${ANDROID_BUILD_TOOLS_HOME}/lib/apksigner.jar ${ANDROID_BUILD_TOOLS_HOME}/lib/apksigner.jar

RUN echo -n "${ANDROID_BUILD_TOOLS_HOME}/apksigner \"\$@\"" >> entrypoint.sh \
    && chmod +x ${ANDROID_BUILD_TOOLS_HOME}/apksigner
