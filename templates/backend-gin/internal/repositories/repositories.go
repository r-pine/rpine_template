package repositories

import (
	"{{GO_MODULE}}/internal/config"
	"{{GO_MODULE}}/pkg/logging"
	"gorm.io/gorm"
)

type Repository struct {
	log    logging.Logger
	config *config.Config
	db     *gorm.DB
}

func NewRepository(log logging.Logger, config *config.Config, db *gorm.DB) *Repository {
	return &Repository{
		log:    log,
		config: config,
		db:     db,
	}
}
