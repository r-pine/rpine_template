package handlers

import (
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/uptrace/bun"

	"{{GO_MODULE}}/internal/config"
)

type Handler struct {
	db  *bun.DB
	cfg *config.Config
}

func NewHandler(db *bun.DB, cfg *config.Config) *Handler {
	return &Handler{
		db:  db,
		cfg: cfg,
	}
}

func (h *Handler) Healthcheck(c echo.Context) error {
	return c.JSON(http.StatusOK, map[string]interface{}{
		"status":  "ok",
		"message": "{{PROJECT_NAME}} API is running",
	})
}
