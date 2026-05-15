package config

import (
	"log"
	"sync"

	"github.com/ilyakaznacheev/cleanenv"
)

type Config struct {
	App      AppConfig
	Postgres PostgresConfig
	Redis    RedisConfig
	JWT      JWTConfig
}

type AppConfig struct {
	HTTPPort string `env:"API_HTTP_PORT" env-default:"8080"`
	GRPCPort string `env:"API_GRPC_PORT" env-default:"50051"`
	Domain   string `env:"API_DOMAIN" env-default:"http://localhost:8080"`
	Debug    bool   `env:"DEBUG" env-default:"false"`
}

type PostgresConfig struct {
	User     string `env:"POSTGRES_USER" env-default:"postgres"`
	Password string `env:"POSTGRES_PASSWORD" env-default:"postgres"`
	Host     string `env:"POSTGRES_HOST" env-default:"localhost"`
	Port     string `env:"POSTGRES_PORT" env-default:"5432"`
	DB       string `env:"POSTGRES_DB" env-default:"{{PROJECT_NAME}}"`
}

type RedisConfig struct {
	Host     string `env:"REDIS_HOST" env-default:"localhost"`
	Port     string `env:"REDIS_PORT" env-default:"6379"`
	Password string `env:"REDIS_PASSWORD" env-default:""`
}

type JWTConfig struct {
	Secret          string `env:"JWT_SECRET" env-default:"secret"`
	AccessTokenTTL  int32  `env:"JWT_ACCESS_TOKEN_TTL" env-default:"3600"`
	RefreshTokenTTL int32  `env:"JWT_REFRESH_TOKEN_TTL" env-default:"86400"`
}

var instance *Config
var once sync.Once

func GetConfig() *Config {
	once.Do(func() {
		instance = &Config{}
		if err := cleanenv.ReadConfig(".envs/.env", instance); err != nil {
			help, _ := cleanenv.GetDescription(instance, nil)
			log.Print(help)
			log.Fatal(err)
		}
	})
	return instance
}
