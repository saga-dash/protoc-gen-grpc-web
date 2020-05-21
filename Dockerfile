FROM node:12.14

RUN curl -L -o /usr/local/bin/protoc-gen-grpc-web https://github.com/grpc/grpc-web/releases/download/1.0.7/protoc-gen-grpc-web-1.0.7-linux-x86_64
RUN chmod +x /usr/local/bin/protoc-gen-grpc-web

RUN apt-get install curl && \
  mkdir -p /protobuf/google/protobuf && \
    for f in any duration descriptor empty struct timestamp wrappers; do \
      curl -L -o /protobuf/google/protobuf/${f}.proto https://raw.githubusercontent.com/google/protobuf/master/src/google/protobuf/${f}.proto; \
    done && \
  mkdir -p /protobuf/google/api && \
    for f in annotations http; do \
      curl -L -o /protobuf/google/api/${f}.proto https://raw.githubusercontent.com/grpc-ecosystem/grpc-gateway/master/third_party/googleapis/google/api/${f}.proto; \
    done

RUN npm i yarn
RUN yarn global add grpc-tools@1.8.1 grpc_tools_node_protoc_ts@3.0.0

ENTRYPOINT ["/usr/local/bin/grpc_tools_node_protoc", "-I/protobuf"]
