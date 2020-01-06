# protoc-gen-grpc-web

proto -> grpc-web

## Example

your proto files

```
docker run --rm\
 -v $(pwd):$(pwd) -w $(pwd)\
 sagadash/protoc-gen-grpc-web\
 --plugin=protoc-gen-grpc-web=/protoc-gen-grpc-web\
 --js_out=import_style=commonjs:$OUT_DIR\
 --grpc-web_out=import_style=typescript,mode=grpcweb:$OUT_DIR\
 -Iproto proto/**/*.proto
```

## Refs

* https://github.com/znly/docker-protobuf
  * Delete except TS.
* https://github.com/grpc/grpc-web
