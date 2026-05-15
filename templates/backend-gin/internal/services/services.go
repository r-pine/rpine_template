package services

import (
	"{{GO_MODULE}}/internal/config"
	"{{GO_MODULE}}/internal/repositories"
	"{{GO_MODULE}}/pkg/logging"
)

type Services struct {
	cfg  *config.Config
	log  *logging.Logger
	repo *repositories.Repository
}

func NewServices(cfg *config.Config, log *logging.Logger, repo *repositories.Repository) *Services {
	return &Services{
		cfg:  cfg,
		log:  log,
		repo: repo,
	}
}
