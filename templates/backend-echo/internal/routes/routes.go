package routes

import (
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/uptrace/bun"

	"{{GO_MODULE}}/internal/config"
	"{{GO_MODULE}}/internal/handlers"
)

func RegisterRoutes(e *echo.Echo, db *bun.DB, cfg *config.Config) {
	h := handlers.NewHandler(db, cfg)

	e.GET("/healthcheck", h.Healthcheck)
}

// Healthcheck godoc
// @Summary Health check
// @Description Returns API health status
// @Tags System
// @Accept json
// @Produce json
// @Success 200 {object} map[string]interface{}
// @Router /healthcheck [get]
func healthcheck(c echo.Context) error {
	return c.JSON(http.StatusOK, map[string]interface{}{
		"status":  "ok",
		"message": "{{PROJECT_NAME}} API is running",
	})
}
