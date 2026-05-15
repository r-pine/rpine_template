# Proto Models

Shared `.proto` files for all project services.

## Prerequisites

```bash
# Install protoc compiler
# macOS:
brew install protobuf

# Linux:
apt install -y protobuf-compiler

# Install Go plugins
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

## Generate Go code

```bash
cd proto
make generate
```

Generated files will appear in `gen/` directory.
