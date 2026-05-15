package http_handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"

	"{{GO_MODULE}}/internal/config"
	"{{GO_MODULE}}/internal/repositories"
	"{{GO_MODULE}}/internal/services"
	"{{GO_MODULE}}/pkg/logging"
)

type HttpHandler struct {
	cfg        config.Config
	log        *logging.Logger
	repository *repositories.Repository
	services   *services.Services
}

func NewHttpHandler(
	cfg config.Config,
	log *logging.Logger,
	repository *repositories.Repository,
	services *services.Services,
) *HttpHandler {
	return &HttpHandler{
		cfg:        cfg,
		log:        log,
		repository: repository,
		services:   services,
	}
}

func (h *HttpHandler) RegisterRoutes(r *gin.Engine) *gin.Engine {
	if h.cfg.App.Debug {
		r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler,
			ginSwagger.URL("/api/v1/swagger/doc.json")))
	}

	r.GET("/healthcheck", h.Healthcheck)

	return r
}

// Healthcheck godoc
// @Summary Health check
// @Description Returns API health status
// @Tags System
// @Accept json
// @Produce json
// @Success 200 {object} map[string]interface{}
// @Router /healthcheck [get]
func (h *HttpHandler) Healthcheck(ctx *gin.Context) {
	ctx.JSON(http.StatusOK, gin.H{
		"status":  "ok",
		"message": "{{PROJECT_NAME}} API is running",
	})
}
