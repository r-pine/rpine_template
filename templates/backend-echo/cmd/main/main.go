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
	"fmt"
	"net"
	"os"
	"os/signal"
	"syscall"

	"github.com/joho/godotenv"
	"github.com/labstack/echo/v4"
	echoSwagger "github.com/swaggo/echo-swagger"
	"golang.org/x/sync/errgroup"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	"{{GO_MODULE}}/internal/config"
	"{{GO_MODULE}}/internal/db"
	grpcserver "{{GO_MODULE}}/internal/grpc"
	"{{GO_MODULE}}/internal/routes"
	"{{GO_MODULE}}/pkg/logging"

	_ "{{GO_MODULE}}/docs"
)

func main() {
	if err := godotenv.Load(".envs/.env"); err != nil {
		fmt.Println("warning: .env file not found, using system env")
	}

	cfg := config.GetConfig()
	logging.Init(cfg.Debug)
	log := logging.GetLogger()
	log.Infoln("config loaded")

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()
	g, ctx := errgroup.WithContext(ctx)

	database, err := db.NewPostgresDB(cfg)
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

	e := echo.New()
	e.HideBanner = true

	if cfg.Debug {
		e.GET("/swagger/*", echoSwagger.WrapHandler)
	}

	routes.RegisterRoutes(e, database, cfg)

	// HTTP server
	g.Go(func() error {
		addr := fmt.Sprintf(":%s", cfg.HTTPPort)
		log.Infof("HTTP server starting on %s", addr)
		return e.Start(addr)
	})

	// gRPC server
	g.Go(func() error {
		lis, err := net.Listen("tcp", fmt.Sprintf(":%s", cfg.GRPCPort))
		if err != nil {
			return err
		}
		grpcServer := grpc.NewServer()
		grpcserver.RegisterServices(grpcServer)
		reflection.Register(grpcServer)
		log.Infof("gRPC server starting on port %s", cfg.GRPCPort)
		return grpcServer.Serve(lis)
	})

	// Graceful shutdown
	g.Go(func() error {
		<-ctx.Done()
		log.Infoln("shutting down...")
		return e.Shutdown(context.Background())
	})

	if err := g.Wait(); err != nil {
		log.Infof("exit: %v", err)
	}
}
