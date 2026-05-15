package db

import (
	"fmt"

	"{{GO_MODULE}}/internal/config"
	"{{GO_MODULE}}/pkg/logging"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func NewPostgresDB(cfg *config.Config, log *logging.Logger) (*gorm.DB, error) {
	dsn := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		cfg.Postgres.Host,
		cfg.Postgres.Port,
		cfg.Postgres.User,
		cfg.Postgres.Password,
		cfg.Postgres.DB,
	)

	database, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		return nil, fmt.Errorf("failed to connect to postgres: %w", err)
	}

	return database, nil
}
