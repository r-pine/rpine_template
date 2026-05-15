package db

import (
	"database/sql"
	"fmt"

	"github.com/uptrace/bun"
	"github.com/uptrace/bun/dialect/pgdialect"
	"github.com/uptrace/bun/driver/pgdriver"

	"{{GO_MODULE}}/internal/config"
)

func NewPostgresDB(cfg *config.Config) (*bun.DB, error) {
	dsn := fmt.Sprintf(
		"postgres://%s:%s@%s:%s/%s?sslmode=disable",
		cfg.Postgres.User,
		cfg.Postgres.Password,
		cfg.Postgres.Host,
		cfg.Postgres.Port,
		cfg.Postgres.DB,
	)

	sqldb := sql.OpenDB(pgdriver.NewConnector(pgdriver.WithDSN(dsn)))
	database := bun.NewDB(sqldb, pgdialect.New())

	if err := database.Ping(); err != nil {
		return nil, fmt.Errorf("failed to connect to postgres: %w", err)
	}

	return database, nil
}
