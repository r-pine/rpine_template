package main

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/joho/godotenv"

	"{{GO_MODULE}}-bot/internal/config"
	"{{GO_MODULE}}-bot/internal/delivery/telegram"
	"{{GO_MODULE}}-bot/pkg/database"
	"{{GO_MODULE}}-bot/pkg/logging"
)

func main() {
	if err := godotenv.Load(".envs/.env.bot"); err != nil {
		fmt.Println("warning: .env.bot file not found, using system env")
	}

	cfg := config.GetConfig()
	logging.Init(cfg.Debug)
	log := logging.GetLogger()
	log.Infoln("bot config loaded")

	db, err := database.NewPostgresDB(cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}
	log.Infoln("database connected")
	_ = db

	bot, err := telegram.NewBot(cfg, &log)
	if err != nil {
		log.Fatalf("failed to create bot: %v", err)
	}

	go bot.Start()
	log.Infoln("bot started")

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Infoln("bot stopped")
}
