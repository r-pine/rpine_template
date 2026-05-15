package config

import (
	"os"
)

type Config struct {
	Debug    bool
	HTTPPort string
	GRPCPort string
	Domain   string
	Postgres PostgresConfig
	Redis    RedisConfig
	JWT      JWTConfig
}

type PostgresConfig struct {
	User     string
	Password string
	Host     string
	Port     string
	DB       string
}

type RedisConfig struct {
	Host     string
	Port     string
	Password string
}

type JWTConfig struct {
	Secret          string
	AccessTokenTTL  string
	RefreshTokenTTL string
}

func GetConfig() *Config {
	return &Config{
		Debug:    getEnv("DEBUG", "false") == "true",
		HTTPPort: getEnv("API_HTTP_PORT", "8080"),
		GRPCPort: getEnv("API_GRPC_PORT", "50051"),
		Domain:   getEnv("API_DOMAIN", "http://localhost:8080"),
		Postgres: PostgresConfig{
			User:     getEnv("POSTGRES_USER", "postgres"),
			Password: getEnv("POSTGRES_PASSWORD", "postgres"),
			Host:     getEnv("POSTGRES_HOST", "localhost"),
			Port:     getEnv("POSTGRES_PORT", "5432"),
			DB:       getEnv("POSTGRES_DB", "{{PROJECT_NAME}}"),
		},
		Redis: RedisConfig{
			Host:     getEnv("REDIS_HOST", "localhost"),
			Port:     getEnv("REDIS_PORT", "6379"),
			Password: getEnv("REDIS_PASSWORD", ""),
		},
		JWT: JWTConfig{
			Secret:          getEnv("JWT_SECRET", "secret"),
			AccessTokenTTL:  getEnv("JWT_ACCESS_TOKEN_TTL", "3600"),
			RefreshTokenTTL: getEnv("JWT_REFRESH_TOKEN_TTL", "86400"),
		},
	}
}

func getEnv(key, defaultValue string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return defaultValue
}
