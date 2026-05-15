// @title {{PROJECT_NAME}} API
// @version 1.0
// @description API for {{PROJECT_NAME}}

// @host {{PROJECT_DOMAIN}}
// @BasePath /api/v1/
// @schemes https

// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Type "Bearer" before the token

package main

import (
	"context"
	"net"
	"net/http"

	"github.com/gin-gonic/gin"
	"golang.org/x/sync/errgroup"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	"{{GO_MODULE}}/internal/config"
	"{{GO_MODULE}}/internal/db"
	"{{GO_MODULE}}/internal/grpc/server"
	"{{GO_MODULE}}/internal/http_handlers"
	"{{GO_MODULE}}/internal/repositories"
	"{{GO_MODULE}}/internal/services"
	"{{GO_MODULE}}/pkg/logging"

	_ "{{GO_MODULE}}/docs"
)

func main() {
	cfg := config.GetConfig()
	logging.Init(cfg.App.Debug)
	log := logging.GetLogger()
	log.Infoln("config loaded")

	ctx := context.Background()
	g, ctx := errgroup.WithContext(ctx)

	database, err := db.NewPostgresDB(cfg, &log)
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}
	log.Infoln("database connected")

	redisClient, err := db.NewRedisClient(cfg)
	if err != nil {
		log.Warnf("failed to connect to redis: %v", err)
	} else {
		log.Infoln("redis connected")
	}
	_ = redisClient

	repo := repositories.NewRepository(log, cfg, database)
	svc := services.NewServices(cfg, &log, repo)
	handler := http_handlers.NewHttpHandler(*cfg, &log, repo, svc)

	if !cfg.App.Debug {
		gin.SetMode(gin.ReleaseMode)
	}
	router := gin.Default()
	handler.RegisterRoutes(router)

	// HTTP server
	g.Go(func() error {
		log.Infof("HTTP server starting on port %s", cfg.App.HTTPPort)
		return http.ListenAndServe(":"+cfg.App.HTTPPort, router)
	})

	// gRPC server
	g.Go(func() error {
		lis, err := net.Listen("tcp", ":"+cfg.App.GRPCPort)
		if err != nil {
			return err
		}
		grpcServer := grpc.NewServer()
		server.RegisterServices(grpcServer)
		reflection.Register(grpcServer)
		log.Infof("gRPC server starting on port %s", cfg.App.GRPCPort)
		return grpcServer.Serve(lis)
	})

	if err := g.Wait(); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
