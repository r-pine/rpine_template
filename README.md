<div align="center">

<img src="https://raw.githubusercontent.com/r-pine/rpine_template/master/.github/logo.svg" width="120" alt="rpine">

# 🌲 rpine template

### Project Template Generator

*Генератор full-stack проектов с интерактивным CLI на базе [gum](https://github.com/charmbracelet/gum)*

&nbsp;

[![Go](https://img.shields.io/badge/Go-1.23-00ADD8?style=for-the-badge&logo=go&logoColor=white)](https://go.dev)
[![React](https://img.shields.io/badge/React-19-61DAFB?style=for-the-badge&logo=react&logoColor=black)](https://react.dev)
[![Vite](https://img.shields.io/badge/Vite-6-646CFF?style=for-the-badge&logo=vite&logoColor=white)](https://vitejs.dev)
[![Tailwind](https://img.shields.io/badge/Tailwind-v4-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white)](https://tailwindcss.com)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docs.docker.com/compose/)
[![gRPC](https://img.shields.io/badge/gRPC-Proto3-244C5A?style=for-the-badge&logo=grpc&logoColor=white)](https://grpc.io)

&nbsp;

<kbd> <br> &nbsp;&nbsp; [Быстрый старт](#-быстрый-старт) &nbsp;&nbsp; <br> <br> </kbd>&ensp;
<kbd> <br> &nbsp;&nbsp; [Возможности](#-возможности) &nbsp;&nbsp; <br> <br> </kbd>&ensp;
<kbd> <br> &nbsp;&nbsp; [Структура](#-структура-проекта) &nbsp;&nbsp; <br> <br> </kbd>&ensp;
<kbd> <br> &nbsp;&nbsp; [Запуск](#-запуск) &nbsp;&nbsp; <br> <br> </kbd>

&nbsp;

</div>

---

## ⚡ Быстрый старт

```bash
git clone https://github.com/r-pine/rpine_template.git my_project
cd my_project
bash setup.sh
```

> [!TIP]
> Скрипт использует **[gum](https://github.com/charmbracelet/gum)** для красивого интерактивного CLI.
> Если `gum` не установлен — установится автоматически.

<details>
<summary>📸 <b>Как выглядит квиз</b></summary>

&nbsp;

```
  ╔════════════════════════════════════════════╗
  ║                                            ║
  ║    🌲  rpine Project Template Generator    ║
  ║                                            ║
  ╚════════════════════════════════════════════╝

    Generate a full-stack project with Go backend, React frontend,
    Telegram bot, PostgreSQL + Redis, and Nginx/Traefik proxy.

  ▎ Architecture

    Reverse proxy:
    > traefik
      nginx

    Backend framework:
    > gin
      echo

  ╭───────────────────────────────────────────────────────────╮
  │                                                           │
  │    Project        my_project                              │
  │    Domain         example.rpine.xyz                       │
  │    Proxy          traefik (ACME: you@example.com)         │
  │    Backend        echo                                    │
  │    Features       React frontend, Telegram bot            │
  │    PostgreSQL     :5432  (user: user_a3366e16)            │
  │    gRPC           :50051 → :50052                         │
  │                                                           │
  ╰───────────────────────────────────────────────────────────╯

    ✓ Backend (echo)
    ✓ Proto
    ✓ Frontend
    ✓ Traefik config
    ✓ Docker Compose
    ✓ Environment files
    ✓ Placeholders replaced

  ╔════════════════════════════════════════╗
  ║                                        ║
  ║   ✓  Project generated successfully!   ║
  ║                                        ║
  ╚════════════════════════════════════════╝
```

</details>

---

## 🌲 Возможности

> **Один скрипт — полностью готовый проект** с бекендом, фронтендом, ботом, базами данных, reverse proxy, gRPC, SSL и Docker.

### 🔧 Backend (Go)

| | |
|---|---|
| Фреймворк | **Gin** или **Echo** на выбор |
| Архитектура | Clean Architecture (handlers → services → repositories) |
| ORM | GORM (Gin) / Bun (Echo) |
| API Docs | Swagger / OpenAPI (auto-generated via `swag`) |
| gRPC | Встроенный сервер + proto codegen |
| Логирование | logrus |
| Health | `GET /healthcheck` → `{"status":"ok"}` |

### ⚛️ Frontend (React)

| | |
|---|---|
| Stack | React 19 + TypeScript + Vite 6 |
| Стили | TailwindCSS v4 (`@tailwindcss/vite`) |
| Архитектура | Feature-Sliced Design (FSD) |
| Routing | react-router-dom v7 |
| HTTP | axios + @tanstack/react-query |
| Build | Multi-stage Docker (node → nginx:alpine) |

### 🤖 Telegram Bot *(опционально)*

| | |
|---|---|
| Язык | Go (отдельный сервис) |
| Режимы | Webhook + Long Polling |
| Архитектура | Clean Architecture (delivery → usecase → repository) |
| Интеграция | Авто-настройка webhook URL в Nginx/Traefik |

### 🌐 Reverse Proxy

| | Nginx | Traefik |
|---|---|---|
| SSL | Let's Encrypt (nginx-proxy) | ACME автоматически |
| HTTP/3 | — | ✅ |
| `/api/v1` strip | ✅ | ✅ |
| CORS + OPTIONS | ✅ | ✅ |
| gRPC proxy | ✅ (отдельный server block) | ✅ (TCP router) |
| Webhook bot | ✅ | ✅ |

### 🗄️ Database & 📡 gRPC

| | |
|---|---|
| PostgreSQL | v15, уникальные порты per project, auto-generated credentials |
| Redis | v7, requirepass, configurable port |
| Proto | Готовая папка `proto/` + `Makefile` для `protoc` codegen |
| gRPC Health | HealthService example в `.proto` |

---

## 🎯 Параметры генерации

### Интерактивный квиз

| | Параметр | Описание | По умолчанию |
|:---:|---|---|:---:|
| 🧹 | Cleanup | Удалить шаблоны после генерации | `n` |
| 📦 | Project name | snake_case название | `my_project` |
| 🌐 | Domain | Домен проекта | `example.rpine.xyz` |
| 📝 | Go module | Go module path | `github.com/r-pine/<name>` |
| 🔀 | Proxy | `nginx` \| `traefik` | `traefik` |
| ⚙️ | Backend | `gin` \| `echo` | `gin` |
| ⚛️ | Frontend | React + Vite + Tailwind | `y` |
| 🤖 | Bot | Telegram bot | `n` |
| 🔌 | Ports | PG, Redis, HTTP, gRPC | стандартные |
| 📧 | SSL Email | ACME / Let's Encrypt | — |

### 🔐 Автогенерация секретов

> [!IMPORTANT]
> Эти значения генерируются **автоматически** через `openssl rand` и **не запрашиваются** в квизе.

| Секрет | Формат | Длина | Файл |
|---|---|:---:|---|
| `POSTGRES_USER` | `user_<hex>` | 13 | `.envs/.env` |
| `POSTGRES_PASSWORD` | base64 | 32 | `.envs/.env`, `.env.bot` |
| `REDIS_PASSWORD` | base64 | 32 | `.envs/.env` |
| `JWT_SECRET` | base64 | 64 | `.envs/.env` |

---

## 📁 Структура проекта

<details open>
<summary><b>Полное дерево</b></summary>

```
project/
│
├── backend/                      ← Go backend (gin или echo)
│   ├── cmd/main/main.go         # Entry point + Swagger annotations
│   ├── internal/
│   │   ├── config/              # Env config (cleanenv / godotenv)
│   │   ├── db/                  # PostgreSQL + Redis connections
│   │   ├── models/              # DB models
│   │   ├── repositories/        # Data access layer
│   │   ├── services/            # Business logic
│   │   ├── dto/                 # Request/Response DTOs
│   │   ├── http_handlers/       # HTTP handlers (gin)
│   │   ├── handlers/            # HTTP handlers (echo)
│   │   ├── routes/              # Route registration (echo)
│   │   ├── middleware/          # CORS, Auth, Logger
│   │   └── grpc/server.go       # gRPC server bootstrap
│   ├── pkg/logging/             # logrus wrapper
│   ├── Dockerfile               # Multi-stage build + swag init
│   └── go.mod
│
├── frontend/                     ← React SPA (optional)
│   ├── src/
│   │   ├── app/                 # App.tsx, main.tsx, routes, styles
│   │   ├── shared/              # baseApi, config, types
│   │   ├── entities/            # FSD layer
│   │   ├── features/            # FSD layer
│   │   ├── widgets/layout/      # Layout component
│   │   └── pages/               # FSD layer
│   ├── nginx.conf               # SPA try_files (baked into image)
│   ├── Dockerfile               # Multi-stage: node build → nginx
│   └── package.json
│
├── bot/                          ← Telegram bot (optional)
│   ├── cmd/bot/main.go
│   ├── internal/
│   │   ├── config/
│   │   ├── delivery/telegram/   # Bot init, webhook, handlers
│   │   ├── domain/              # Domain models
│   │   ├── repository/
│   │   └── usecase/
│   ├── Dockerfile
│   └── go.mod
│
├── proto/                        ← gRPC definitions
│   ├── <project>.proto          # HealthService example
│   └── Makefile                 # make generate
│
├── nginx-app/                    ← if proxy = nginx
│   ├── nginx.conf
│   └── default.conf             # /api/v1, CORS, gRPC, webhook
│
├── traefik-app/                  ← if proxy = traefik
│   ├── traefik.yml              # entryPoints, ACME, providers
│   └── dynamic/project.yml      # routers, services, middlewares
│
├── ci_traefik/                   ← Traefik edge proxy
│   └── docker-compose.yml
│
├── .envs/
│   ├── .env.example             ← committed (changeme placeholders)
│   ├── .env                     ← gitignored (real secrets)
│   ├── .env.bot                 ← gitignored (bot token + DB URL)
│   ├── .env.web                 ← gitignored (nginx Let's Encrypt)
│   └── .env.front               ← gitignored (VITE_API_BASE_URL)
│
├── docker-compose.yml            ← App services
├── docker-compose.db.yml         ← PostgreSQL + Redis
├── .gitignore
└── .dockerignore
```

</details>

---

## 🚀 Запуск

> [!NOTE]
> Все команды выполняются из корня сгенерированного проекта.

**1** &ensp; Создать Docker-сеть

```bash
docker network create shared-web
```

**2** &ensp; Запустить базы данных

```bash
docker compose -f docker-compose.db.yml up -d
```

**3** &ensp; Собрать и запустить сервисы

```bash
docker compose up -d --build
```

**4** &ensp; Запустить reverse proxy

```bash
# Traefik
cd ci_traefik && docker compose up -d

# Nginx — уже в docker-compose.yml, ничего дополнительного
```

**5** &ensp; Проверить

```bash
# Health check
curl https://your-domain.xyz/api/v1/healthcheck
# → {"status":"ok","message":"my_project API is running"}

# gRPC
grpcurl -plaintext localhost:50052 list
```

---

## 🔒 Окружение

| Файл | Описание | Git |
|---|---|:---:|
| `.envs/.env.example` | Шаблон с `changeme` | ✅ |
| `.envs/.env` | Реальные значения + сгенерированные пароли | ❌ |
| `.envs/.env.bot` | Токен бота + `DATABASE_URL` | ❌ |
| `.envs/.env.bot.example` | Шаблон для бота | ✅ |
| `.envs/.env.web` | `VIRTUAL_HOST`, Let's Encrypt (nginx) | ❌ |
| `.envs/.env.front` | `VITE_API_BASE_URL` | ❌ |
| `ci_traefik/.env` | `ACME_EMAIL` (traefik) | ❌ |

---

<details>
<summary>📡 <b>gRPC — генерация кода</b></summary>

&nbsp;

**Установка инструментов:**

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

**Генерация:**

```bash
cd proto
make generate
# → файлы появятся в proto/gen/
```

</details>

<details>
<summary>🏗️ <b>Архитектура</b></summary>

&nbsp;

```
                       ┌──────────┐
                       │  Client  │
                       └────┬─────┘
                            │
                ┌───────────┴───────────┐
                │   Nginx  /  Traefik   │
                │   SSL · CORS · Route  │
                └──┬────────┬────────┬──┘
                   │        │        │
          /api/v1/ │    /   │        │ :50052
                   │        │        │
            ┌──────┴───┐ ┌──┴──┐ ┌───┴───┐
            │ Backend   │ │Front│ │ gRPC  │
            │ (Go)      │ │end  │ │Server │
            └─────┬─────┘ └─────┘ └───────┘
                  │
         ┌────────┴────────┐
         │                 │
    ┌────┴──────┐   ┌─────┴─────┐
    │PostgreSQL │   │   Redis   │
    │   :5432   │   │   :6379   │
    └───────────┘   └───────────┘
```

</details>

---

<div align="center">

&nbsp;

🌲

**Built by [r-pine](https://github.com/r-pine)**

&nbsp;

</div>
