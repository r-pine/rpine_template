package config

import (
	"os"
)

type Config struct {
	Debug          bool
	BotToken       string
	WebhookURL     string
	WebhookSecret  string
	DatabaseURL    string
}

func GetConfig() *Config {
	return &Config{
		Debug:         getEnv("DEBUG", "false") == "true",
		BotToken:      getEnv("TELEGRAM_BOT_TOKEN", ""),
		WebhookURL:    getEnv("TELEGRAM_WEBHOOK_URL", ""),
		WebhookSecret: getEnv("TELEGRAM_WEBHOOK_SECRET", ""),
		DatabaseURL:   getEnv("DATABASE_URL", ""),
	}
}

func getEnv(key, defaultValue string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return defaultValue
}
