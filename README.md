<div align="center">

```
        🌲
       /\  \
      /  \  \
     /    \  \
    /  🟢  \  \
   /________\  \
       ||
```

# 🌲 rpine template

**Project Template Generator**

*Генератор full-stack проектов с интерактивным CLI*

[![Go](https://img.shields.io/badge/Go-1.23-00ADD8?style=flat-square&logo=go&logoColor=white)](https://go.dev)
[![React](https://img.shields.io/badge/React-19-61DAFB?style=flat-square&logo=react&logoColor=black)](https://react.dev)
[![Vite](https://img.shields.io/badge/Vite-6-646CFF?style=flat-square&logo=vite&logoColor=white)](https://vitejs.dev)
[![TailwindCSS](https://img.shields.io/badge/Tailwind-v4-06B6D4?style=flat-square&logo=tailwindcss&logoColor=white)](https://tailwindcss.com)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=flat-square&logo=docker&logoColor=white)](https://docs.docker.com/compose/)
[![gRPC](https://img.shields.io/badge/gRPC-Proto3-244C5A?style=flat-square&logo=grpc&logoColor=white)](https://grpc.io)

---

</div>

## ⚡ Быстрый старт

```bash
git clone https://github.com/r-pine/rpine_template.git my_project
cd my_project
bash setup.sh
```

> Скрипт использует [gum](https://github.com/charmbracelet/gum) для красивого интерактивного CLI. Если `gum` не установлен — установится автоматически.

<div align="center">

```
  ╔════════════════════════════════════════════╗
  ║    🌲  rpine Project Template Generator    ║
  ╚════════════════════════════════════════════╝

    ▎ Architecture

      Reverse proxy:
      > traefik
        nginx

      Backend framework:
      > gin
        echo
```

</div>

---

## 🌲 Возможности

<table>
<tr>
<td width="50%">

### 🔧 Backend (Go)
- **Gin** или **Echo** на выбор
- Clean Architecture
- Swagger / OpenAPI документация
- Healthcheck endpoint
- gRPC сервер
- GORM (Gin) / Bun (Echo) ORM
- logrus логирование

</td>
<td width="50%">

### ⚛️ Frontend (React)
- React 19 + TypeScript
- Vite 6
- TailwindCSS v4
- Feature-Sliced Design (FSD)
- react-router-dom v7
- axios + @tanstack/react-query
- Multi-stage Docker build

</td>
</tr>
<tr>
<td width="50%">

### 🤖 Telegram Bot
- Отдельный Go-сервис
- Webhook + Polling режимы
- Clean Architecture
- Автоматическая настройка URL

</td>
<td width="50%">

### 🌐 Reverse Proxy
- **Nginx**: CORS, /api/v1 strip, gRPC
- **Traefik**: ACME SSL, HTTP/3, gRPC
- Автоматические сертификаты
- WebSocket поддержка

</td>
</tr>
<tr>
<td width="50%">

### 🗄️ Database
- PostgreSQL 15
- Redis 7
- Уникальные порты per project
- Auto-generated credentials

</td>
<td width="50%">

### 📡 gRPC
- Готовая папка `proto/`
- Makefile для кодогенерации
- Nginx/Traefik проксирование
- HealthCheck service example

</td>
</tr>
</table>

---

## 🎯 Интерактивный квиз

Скрипт задаёт вопросы и генерирует проект под ваши нужды:

| 🌲 | Параметр | Описание | По умолчанию |
|:---:|---|---|:---:|
| 🧹 | **Cleanup** | Удалить шаблоны после генерации | `n` |
| 📦 | **Project name** | Название (snake_case) | `my_project` |
| 🌐 | **Domain** | Домен проекта | `example.rpine.xyz` |
| 📝 | **Go module** | Go module path | `github.com/r-pine/<name>` |
| 🔀 | **Proxy** | `nginx` / `traefik` | `traefik` |
| ⚙️ | **Backend** | `gin` / `echo` | `gin` |
| ⚛️ | **Frontend** | React + Vite + Tailwind | `y` |
| 🤖 | **Bot** | Telegram bot | `n` |
| 🔌 | **Ports** | PostgreSQL, Redis, HTTP, gRPC | стандартные |
| 📧 | **SSL Email** | Let's Encrypt / ACME | — |

### 🔐 Автогенерация секретов

Следующие значения генерируются **автоматически** и не запрашиваются:

| Секрет | Длина | Куда попадает |
|---|:---:|---|
| `POSTGRES_USER` | 13 chars | `.envs/.env` |
| `POSTGRES_PASSWORD` | 32 chars | `.envs/.env`, `.env.bot` |
| `REDIS_PASSWORD` | 32 chars | `.envs/.env` |
| `JWT_SECRET` | 64 chars | `.envs/.env` |

---

## 📁 Структура проекта

```
🌲 project/
├── 🔧 backend/                 # Go backend
│   ├── cmd/main/main.go       # Entry point
│   ├── internal/
│   │   ├── config/            # Environment config
│   │   ├── db/                # PostgreSQL + Redis
│   │   ├── models/            # DB models
│   │   ├── repositories/      # Data access layer
│   │   ├── services/          # Business logic
│   │   ├── http_handlers/     # HTTP handlers (gin)
│   │   ├── handlers/          # HTTP handlers (echo)
│   │   ├── routes/            # Route registration (echo)
│   │   ├── middleware/        # CORS, Auth, Logger
│   │   └── grpc/              # gRPC server
│   ├── pkg/logging/           # logrus wrapper
│   ├── Dockerfile
│   └── go.mod
│
├── ⚛️  frontend/                # React SPA (optional)
│   ├── src/
│   │   ├── app/               # App, routes, styles
│   │   ├── shared/            # API client, config, types
│   │   ├── entities/          # FSD: entities
│   │   ├── features/          # FSD: features
│   │   ├── widgets/           # FSD: layout
│   │   └── pages/             # FSD: pages
│   ├── Dockerfile
│   └── package.json
│
├── 🤖 bot/                     # Telegram bot (optional)
│   ├── cmd/bot/main.go
│   ├── internal/
│   │   ├── config/
│   │   ├── delivery/telegram/
│   │   ├── domain/
│   │   ├── repository/
│   │   └── usecase/
│   ├── Dockerfile
│   └── go.mod
│
├── 📡 proto/                    # gRPC proto files
│   ├── <project>.proto
│   └── Makefile
│
├── 🌐 nginx-app/               # Nginx config (if nginx)
├── 🌐 traefik-app/             # Traefik config (if traefik)
├── 🌐 ci_traefik/              # Traefik edge proxy
│
├── 🔒 .envs/                   # Environment variables
│   ├── .env.example            # Template (in git)
│   └── .env                    # Real values (gitignored)
│
├── 🐳 docker-compose.yml       # App services
├── 🐳 docker-compose.db.yml    # PostgreSQL + Redis
├── 📄 .gitignore
└── 📄 .dockerignore
```

---

## 🚀 Запуск

### 1. Создать Docker-сеть

```bash
docker network create shared-web
```

### 2. Запустить базы данных

```bash
docker compose -f docker-compose.db.yml up -d
```

### 3. Собрать и запустить сервисы

```bash
docker compose up -d --build
```

### 4. Запустить reverse proxy

**Traefik:**
```bash
cd ci_traefik && docker compose up -d
```

**Nginx:** настроен автоматически в `docker-compose.yml`

### 5. Проверить

```bash
# API healthcheck
curl https://your-domain.xyz/api/v1/healthcheck

# gRPC (grpcurl)
grpcurl -plaintext localhost:50052 list
```

---

## 🔒 Переменные окружения

| Файл | Описание | В Git? |
|---|---|:---:|
| `.envs/.env.example` | Шаблон с `changeme` | ✅ |
| `.envs/.env` | Реальные значения + сгенерированные пароли | ❌ |
| `.envs/.env.bot` | Токен бота + DATABASE_URL | ❌ |
| `.envs/.env.bot.example` | Шаблон для бота | ✅ |
| `.envs/.env.web` | VIRTUAL_HOST, Let's Encrypt (nginx) | ❌ |
| `.envs/.env.front` | VITE_API_BASE_URL | ❌ |
| `ci_traefik/.env` | ACME_EMAIL (traefik) | ❌ |

---

## 📡 gRPC

```bash
# Генерация Go-кода из proto
cd proto && make generate

# Файлы появятся в proto/gen/
```

Требуется установка:
```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

---

## 🏗️ Архитектура

```
                    ┌─────────────┐
                    │   Client    │
                    └──────┬──────┘
                           │
               ┌───────────┴───────────┐
               │  Nginx / Traefik      │
               │  SSL, CORS, routing   │
               └───┬───────┬───────┬───┘
                   │       │       │
          /api/v1/ │   /   │       │ :50052
                   │       │       │
            ┌──────┴──┐ ┌──┴───┐ ┌─┴────┐
            │ Backend  │ │Front │ │ gRPC │
            │  (Go)    │ │(React│ │      │
            └────┬─────┘ └──────┘ └──────┘
                 │
        ┌────────┴────────┐
        │                 │
   ┌────┴─────┐    ┌─────┴────┐
   │PostgreSQL │    │  Redis   │
   └──────────┘    └──────────┘
```

---

<div align="center">

**Built with 🌲 by [r-pine](https://github.com/r-pine)**

</div>
