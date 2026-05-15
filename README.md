<div align="center">

<br>

<a href="https://rpine.xyz">
  <img src="https://static.tildacdn.one/tild3763-3834-4366-a239-663565303964/logo.svg" width="180" alt="RPine">
</a>

<br>
<br>

### `rpine_template`

**Full-Stack Project Generator**

Интерактивный CLI для генерации production-ready проектов<br>
Go · React · Telegram · PostgreSQL · Redis · gRPC · Docker

<br>

[![Go](https://img.shields.io/badge/Go-1.23-00b56a?style=for-the-badge&logo=go&logoColor=white)](#)
[![React](https://img.shields.io/badge/React-19-25bfda?style=for-the-badge&logo=react&logoColor=white)](#)
[![Vite](https://img.shields.io/badge/Vite-6-646CFF?style=for-the-badge&logo=vite&logoColor=white)](#)
[![Tailwind](https://img.shields.io/badge/Tailwind-v4-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white)](#)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)](#)
[![gRPC](https://img.shields.io/badge/gRPC-Proto3-00b56a?style=for-the-badge&logo=grpc&logoColor=white)](#)

<br>

[Быстрый старт](#-быстрый-старт) · [Возможности](#-что-внутри) · [Структура](#-структура) · [Запуск](#-запуск) · [Окружение](#-окружение)

<br>

</div>

---

<br>

## ⚡ Быстрый старт

```bash
git clone https://github.com/r-pine/rpine_template.git my_project
cd my_project
bash setup.sh
```

> [!TIP]
> Скрипт автоматически установит **[gum](https://github.com/charmbracelet/gum)** — инструмент для красивого интерактивного CLI.

<br>

<details>
<summary>&emsp;📸&ensp;<b>Preview интерфейса</b></summary>
<br>

```
  ╔════════════════════════════════════════════╗
  ║                                            ║
  ║    🌲  rpine Project Template Generator    ║
  ║                                            ║
  ╚════════════════════════════════════════════╝

    Generate a full-stack project with Go backend,
    React frontend, Telegram bot, PostgreSQL + Redis,
    and Nginx/Traefik proxy.

  ▎ Architecture

    Reverse proxy:
    > traefik
      nginx

    Backend framework:
    > gin
      echo

  ╭───────────────────────────────────────────────────╮
  │                                                   │
  │    Project        my_project                      │
  │    Domain         app.rpine.xyz                   │
  │    Proxy          traefik (ACME: ssl@rpine.xyz)   │
  │    Backend        echo                            │
  │    Features       React frontend, Telegram bot    │
  │    PostgreSQL     :5432  (user: user_a3366e16)    │
  │    gRPC           :50051 → :50052                 │
  │                                                   │
  ╰───────────────────────────────────────────────────╯

    ✓ Backend (echo)
    ✓ Proto
    ✓ Frontend
    ✓ Telegram Bot
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

<br>

---

<br>

## 🌲 Что внутри

<br>

<table>
<tr><td>

**🔧 &ensp;Backend — Go**

</td><td>

**Gin** или **Echo** на выбор — clean architecture, Swagger, healthcheck, gRPC сервер, GORM/Bun ORM, logrus

</td></tr>
<tr><td>

**⚛️ &ensp;Frontend — React**

</td><td>

React 19 · TypeScript · Vite 6 · TailwindCSS v4 · FSD-архитектура · react-router v7 · axios · react-query

</td></tr>
<tr><td>

**🤖 &ensp;Telegram Bot**

</td><td>

Отдельный Go-сервис · webhook + polling · clean architecture · авто-настройка URL в proxy

</td></tr>
<tr><td>

**🌐 &ensp;Reverse Proxy**

</td><td>

**Nginx** (CORS, strip prefix, gRPC) или **Traefik** (ACME SSL, HTTP/3, TCP gRPC router)

</td></tr>
<tr><td>

**🗄️ &ensp;Database**

</td><td>

PostgreSQL 15 + Redis 7 · уникальные порты · автогенерация credentials

</td></tr>
<tr><td>

**📡 &ensp;gRPC**

</td><td>

`proto/` с Makefile для codegen · Nginx/Traefik proxy · HealthService example

</td></tr>
<tr><td>

**🐳 &ensp;Docker**

</td><td>

Multi-stage builds · Docker Compose · shared-web network · separate DB compose

</td></tr>
</table>

<br>

---

<br>

## 🎯 Параметры

<br>

**Квиз** — скрипт задаёт вопросы и генерирует проект:

| | Параметр | Описание | Default |
|:---:|---|---|:---:|
| 📦 | **Project name** | snake_case | `my_project` |
| 🌐 | **Domain** | Домен проекта | `example.rpine.xyz` |
| 📝 | **Go module** | Go module path | `github.com/r-pine/<name>` |
| 🔀 | **Proxy** | `nginx` \| `traefik` | `traefik` |
| ⚙️ | **Backend** | `gin` \| `echo` | `gin` |
| ⚛️ | **Frontend** | React + Vite + Tailwind | `y` |
| 🤖 | **Bot** | Telegram bot service | `n` |
| 🔌 | **Ports** | PG, Redis, HTTP, gRPC | стандартные |
| 📧 | **SSL Email** | ACME / Let's Encrypt | — |
| 🧹 | **Cleanup** | Удалить шаблоны | `n` |

<br>

> [!IMPORTANT]
> **Секреты генерируются автоматически** через `openssl rand` и не запрашиваются:
>
> | Секрет | Длина | Куда |
> |---|:---:|---|
> | `POSTGRES_USER` | 13 | `.envs/.env` |
> | `POSTGRES_PASSWORD` | 32 | `.envs/.env` · `.env.bot` |
> | `REDIS_PASSWORD` | 32 | `.envs/.env` |
> | `JWT_SECRET` | 64 | `.envs/.env` |

<br>

---

<br>

## 📁 Структура

<br>

```
project/
│
├─ backend/                       Go backend (gin / echo)
│  ├─ cmd/main/main.go           entry point + swagger
│  ├─ internal/
│  │  ├─ config/                 env config
│  │  ├─ db/                     postgres + redis
│  │  ├─ models/                 DB models
│  │  ├─ repositories/           data access
│  │  ├─ services/               business logic
│  │  ├─ dto/                    request / response
│  │  ├─ http_handlers/          handlers (gin)
│  │  ├─ handlers/               handlers (echo)
│  │  ├─ routes/                 routes (echo)
│  │  ├─ middleware/             CORS, auth, logger
│  │  └─ grpc/server.go          gRPC bootstrap
│  ├─ pkg/logging/               logrus
│  ├─ Dockerfile                 multi-stage + swag
│  └─ go.mod
│
├─ frontend/                      React SPA
│  ├─ src/
│  │  ├─ app/                    App, main, routes, css
│  │  ├─ shared/                 api, config, types
│  │  ├─ entities/               FSD
│  │  ├─ features/               FSD
│  │  ├─ widgets/layout/         Layout
│  │  └─ pages/                  FSD
│  ├─ nginx.conf                 SPA routing (in image)
│  ├─ Dockerfile                 node → nginx:alpine
│  └─ package.json
│
├─ bot/                           Telegram bot
│  ├─ cmd/bot/main.go
│  ├─ internal/
│  │  ├─ delivery/telegram/      webhook + handlers
│  │  ├─ domain/                 models
│  │  ├─ repository/
│  │  └─ usecase/
│  ├─ Dockerfile
│  └─ go.mod
│
├─ proto/                         gRPC
│  ├─ <name>.proto               HealthService
│  └─ Makefile                   make generate
│
├─ nginx-app/                     nginx proxy config
├─ traefik-app/                   traefik + dynamic routes
├─ ci_traefik/                    traefik edge compose
│
├─ .envs/                         environment
│  ├─ .env.example               → git (changeme)
│  ├─ .env                       → gitignored (real)
│  ├─ .env.bot                   → gitignored
│  ├─ .env.web                   → gitignored
│  └─ .env.front                 → gitignored
│
├─ docker-compose.yml             services
├─ docker-compose.db.yml          postgres + redis
├─ .gitignore
└─ .dockerignore
```

<br>

---

<br>

## 🚀 Запуск

<br>

**`1`** &ensp; Docker-сеть

```bash
docker network create shared-web
```

**`2`** &ensp; Базы данных

```bash
docker compose -f docker-compose.db.yml up -d
```

**`3`** &ensp; Сервисы

```bash
docker compose up -d --build
```

**`4`** &ensp; Reverse proxy

```bash
# traefik
cd ci_traefik && docker compose up -d

# nginx — уже в docker-compose.yml
```

**`5`** &ensp; Проверить

```bash
curl https://your-domain.xyz/api/v1/healthcheck
# {"status":"ok","message":"my_project API is running"}

grpcurl -plaintext localhost:50052 list
```

<br>

---

<br>

## 🔒 Окружение

| Файл | Описание | Git |
|---|---|:---:|
| `.envs/.env.example` | Шаблон (`changeme`) | ✅ |
| `.envs/.env` | Реальные пароли (auto-generated) | ❌ |
| `.envs/.env.bot` | Bot token + DATABASE_URL | ❌ |
| `.envs/.env.bot.example` | Шаблон бота | ✅ |
| `.envs/.env.web` | VIRTUAL_HOST · Let's Encrypt | ❌ |
| `.envs/.env.front` | VITE_API_BASE_URL | ❌ |
| `ci_traefik/.env` | ACME_EMAIL | ❌ |

<br>

<details>
<summary>&emsp;📡&ensp;<b>gRPC codegen</b></summary>
<br>

```bash
# install tools
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# generate
cd proto && make generate
```

</details>

<details>
<summary>&emsp;🏗️&ensp;<b>Архитектура</b></summary>
<br>

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
    └───────────┘   └───────────┘
```

</details>

<br>

---

<div align="center">

<br>

<a href="https://rpine.xyz">
  <img src="https://static.tildacdn.one/tild3763-3834-4366-a239-663565303964/logo.svg" width="100" alt="RPine">
</a>

<br>
<br>

**[rpine.xyz](https://rpine.xyz)** · [GitHub](https://github.com/r-pine)

<br>

</div>
