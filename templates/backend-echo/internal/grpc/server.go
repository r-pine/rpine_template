package grpc

import (
	"google.golang.org/grpc"
)

func RegisterServices(s *grpc.Server) {
	// Register your gRPC services here.
	// Example:
	// pb.RegisterHealthServiceServer(s, &healthServer{})
}
