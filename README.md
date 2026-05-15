# rpine Project Template Generator

Генератор проектов с Go-бекендом, React-фронтендом и инфраструктурой.

## Быстрый старт

```bash
git clone <repo-url> my_project
cd my_project
bash setup.sh
```

## Возможности

- **Go Backend**: Gin или Echo на выбор, clean architecture, Swagger, healthcheck, gRPC
- **React Frontend**: Vite 6, React 19, TypeScript, TailwindCSS v4, FSD-архитектура
- **Telegram Bot**: Отдельный Go-сервис с webhook/polling
- **Reverse Proxy**: Nginx или Traefik с SSL, CORS, gRPC
- **Database**: PostgreSQL 15 + Redis 7
- **Docker**: Multi-stage builds, Docker Compose
- **Proto/gRPC**: Готовая папка `proto/` с Makefile для кодогенерации

## Квиз при генерации

| Параметр | Описание | По умолчанию |
|---|---|---|
| Cleanup | Удалить шаблоны после генерации | `n` |
| Project name | Название проекта (snake_case) | `my_project` |
| Domain | Домен проекта | `example.rpine.xyz` |
| Go module | Go module path | `github.com/r-pine/<name>` |
| Proxy | nginx / traefik | `traefik` |
| Backend | gin / echo | `gin` |
| Frontend | Включить React | `y` |
| Bot | Включить Telegram бота | `n` |
| Ports | PostgreSQL, Redis, HTTP, gRPC | стандартные |

## Структура сгенерированного проекта

```
project/
├── backend/            # Go backend (gin или echo)
├── frontend/           # React frontend (опционально)
├── bot/                # Telegram bot (опционально)
├── proto/              # Proto-модели + Makefile
├── nginx-app/          # Nginx конфигурация (если nginx)
├── traefik-app/        # Traefik конфигурация (если traefik)
├── ci_traefik/         # Traefik edge (если traefik)
├── .envs/              # Переменные окружения
├── docker-compose.yml  # Основные сервисы
├── docker-compose.db.yml # PostgreSQL + Redis
├── .gitignore
└── .dockerignore
```

## Запуск

```bash
# Создать Docker-сеть
docker network create shared-web

# Запустить базы данных
docker compose -f docker-compose.db.yml up -d

# Запустить сервисы
docker compose up -d --build

# Если Traefik — запустить edge proxy
cd ci_traefik && docker compose up -d
```

## Переменные окружения

- `.envs/.env.example` — шаблон (коммитится в git)
- `.envs/.env` — реальные значения (в .gitignore)
- Пароли генерируются автоматически при запуске `setup.sh`
