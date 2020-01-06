FROM alpine:3.7 as protoc_builder
RUN apk add --no-cache build-base curl automake autoconf libtool git zlib-dev

ENV GRPC_VERSION=1.26.0 \
    PROTOBUF_VERSION=3.11.2 \
    OUTDIR=/out
RUN mkdir -p /protobuf && \
    curl -L https://github.com/google/protobuf/archive/v${PROTOBUF_VERSION}.tar.gz | tar xvz --strip-components=1 -C /protobuf
RUN git clone --depth 1 --recursive -b v${GRPC_VERSION} https://github.com/grpc/grpc.git /grpc && \
    rm -rf grpc/third_party/protobuf && \
    ln -s /protobuf /grpc/third_party/protobuf
RUN cd /protobuf && \
    autoreconf -f -i -Wall,no-obsolete && \
    ./configure --prefix=/usr --enable-static=no && \
    make -j2 && make install
RUN cd grpc && \
    make -j2 plugins
RUN cd /protobuf && \
    make install DESTDIR=${OUTDIR}
RUN cd /grpc && \
    make install-plugins prefix=${OUTDIR}/usr
RUN find ${OUTDIR} -name "*.a" -delete -or -name "*.la" -delete

RUN curl -L -o ${OUTDIR}/protoc-gen-grpc-web https://github.com/grpc/grpc-web/releases/download/1.0.7/protoc-gen-grpc-web-1.0.7-linux-x86_64
RUN chmod +x ${OUTDIR}/protoc-gen-grpc-web

FROM znly/upx as packer
COPY --from=protoc_builder /out/ /out/
RUN upx --lzma \
        /out/usr/bin/protoc


FROM node:alpine
RUN apk add --no-cache libstdc++
COPY --from=packer /out/ /

RUN apk add --no-cache curl && \
    mkdir -p /protobuf/google/protobuf && \
        for f in any duration descriptor empty struct timestamp wrappers; do \
            curl -L -o /protobuf/google/protobuf/${f}.proto https://raw.githubusercontent.com/google/protobuf/master/src/google/protobuf/${f}.proto; \
        done && \
    mkdir -p /protobuf/google/api && \
        for f in annotations http; do \
            curl -L -o /protobuf/google/api/${f}.proto https://raw.githubusercontent.com/grpc-ecosystem/grpc-gateway/master/third_party/googleapis/google/api/${f}.proto; \
        done && \
    apk del curl

RUN npm install -g ts-protoc-gen

RUN cp /protoc-gen-grpc-web /usr/local/bin/protoc-gen-grpc-web
RUN cp /usr/bin/grpc_node_plugin /usr/local/bin/protoc-gen-grpc
RUN cp /protoc-gen-grpc-web /usr/local/bin/protoc-gen-grpc-web

ENTRYPOINT ["/usr/bin/protoc", "-I/protobuf"]
