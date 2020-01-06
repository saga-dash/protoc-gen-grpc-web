FROM node:12.14

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
RUN yarn global add grpc-tools grpc_tools_node_protoc_ts

ENTRYPOINT ["/usr/bin/grpc_tools_node_protoc", "-I/protobuf"]
