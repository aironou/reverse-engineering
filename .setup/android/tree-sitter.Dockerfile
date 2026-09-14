FROM alpine AS base

RUN apk update \
    && apk add --no-cache gcc musl-dev

FROM base AS build

RUN apk add --no-cache \
    git \
    cargo \
    clang22-libclang

WORKDIR /opt

RUN git clone -b v0.27.0 --single-branch --depth 1 https://github.com/tree-sitter/tree-sitter \
    && cd tree-sitter \
    && cargo build --release

FROM base AS build-grammars

RUN apk add --no-cache git

WORKDIR /opt

RUN git clone -b v0.23.5 --single-branch https://github.com/tree-sitter/tree-sitter-java.git \
    && git clone -b 0.3.8 --single-branch https://github.com/fwcd/tree-sitter-kotlin.git \
    && git clone -b v0.25.0 --single-branch https://github.com/tree-sitter/tree-sitter-javascript.git \
    && git clone -b v0.24.2 --single-branch https://github.com/tree-sitter/tree-sitter-c.git \
    && git clone -b v0.23.4 --single-branch https://github.com/tree-sitter/tree-sitter-cpp.git \
    && git clone -b v0.24.8 --single-branch https://github.com/tree-sitter/tree-sitter-json.git \
    && git clone --single-branch https://github.com/dorgnarg/tree-sitter-xml.git

FROM base

COPY --from=build --chmod=+x /opt/tree-sitter/target/release/tree-sitter /opt/tree-sitter/tree-sitter
COPY --from=build-grammars /opt /opt/tree-sitter/grammars

COPY config/tree-sitter/config.json /root/.config/tree-sitter/config.json

ENTRYPOINT ["/opt/tree-sitter/tree-sitter"]

