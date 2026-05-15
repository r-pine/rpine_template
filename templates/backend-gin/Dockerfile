FROM golang:1.23-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go install github.com/swaggo/swag/cmd/swag@latest && \
    swag init -g cmd/main/main.go -o docs

RUN CGO_ENABLED=0 GOOS=linux go build -o /app/server ./cmd/main/main.go

FROM alpine:3.19

WORKDIR /app

COPY --from=builder /app/server .
COPY --from=builder /app/docs ./docs

EXPOSE {{BACKEND_PORT}} {{GRPC_PORT}}

CMD ["./server"]
