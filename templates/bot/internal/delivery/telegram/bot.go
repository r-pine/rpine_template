package telegram

import (
	"fmt"
	"net/http"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"

	"{{GO_MODULE}}-bot/internal/config"
	"{{GO_MODULE}}-bot/pkg/logging"
)

type Bot struct {
	api *tgbotapi.BotAPI
	cfg *config.Config
	log *logging.Logger
}

func NewBot(cfg *config.Config, log *logging.Logger) (*Bot, error) {
	api, err := tgbotapi.NewBotAPI(cfg.BotToken)
	if err != nil {
		return nil, fmt.Errorf("failed to create bot api: %w", err)
	}

	api.Debug = cfg.Debug

	return &Bot{
		api: api,
		cfg: cfg,
		log: log,
	}, nil
}

func (b *Bot) Start() {
	if b.cfg.WebhookURL != "" {
		b.startWebhook()
	} else {
		b.startPolling()
	}
}

func (b *Bot) startWebhook() {
	wh, err := tgbotapi.NewWebhook(b.cfg.WebhookURL)
	if err != nil {
		b.log.Fatalf("failed to set webhook: %v", err)
	}

	if b.cfg.WebhookSecret != "" {
		wh.SecretToken = b.cfg.WebhookSecret
	}

	_, err = b.api.Request(wh)
	if err != nil {
		b.log.Fatalf("failed to set webhook: %v", err)
	}

	updates := b.api.ListenForWebhook("/webhook/bot")

	go func() {
		b.log.Infoln("starting webhook server on :8443")
		if err := http.ListenAndServe(":8443", nil); err != nil {
			b.log.Fatalf("webhook server error: %v", err)
		}
	}()

	for update := range updates {
		b.handleUpdate(update)
	}
}

func (b *Bot) startPolling() {
	u := tgbotapi.NewUpdate(0)
	u.Timeout = 60

	updates := b.api.GetUpdatesChan(u)

	for update := range updates {
		b.handleUpdate(update)
	}
}

func (b *Bot) handleUpdate(update tgbotapi.Update) {
	if update.Message == nil {
		return
	}

	b.log.Infof("[%s] %s", update.Message.From.UserName, update.Message.Text)

	if update.Message.IsCommand() {
		switch update.Message.Command() {
		case "start":
			msg := tgbotapi.NewMessage(update.Message.Chat.ID, "Welcome to {{PROJECT_NAME}} bot!")
			b.api.Send(msg)
		case "help":
			msg := tgbotapi.NewMessage(update.Message.Chat.ID, "Available commands:\n/start - Start\n/help - Help")
			b.api.Send(msg)
		}
	}
}
