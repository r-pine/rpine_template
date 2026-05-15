#!/usr/bin/env bash
set -uo pipefail

trap 'echo "" && echo "Aborted." && exit 1' INT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ─── Install gum if missing ──────────────────────────────────────────────────
ensure_gum() {
    if command -v gum &>/dev/null; then
        return
    fi
    echo "Installing gum (beautiful terminal UI)..."
    if command -v apt-get &>/dev/null; then
        mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | gpg --dearmor -o /etc/apt/keyrings/charm.gpg 2>/dev/null
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | tee /etc/apt/sources.list.d/charm.list >/dev/null
        apt-get update -qq && apt-get install -y -qq gum >/dev/null 2>&1
    elif command -v brew &>/dev/null; then
        brew install gum >/dev/null 2>&1
    elif command -v pacman &>/dev/null; then
        pacman -S --noconfirm gum >/dev/null 2>&1
    else
        echo "Cannot auto-install gum. Install manually: https://github.com/charmbracelet/gum"
        exit 1
    fi
}

ensure_gum

# ─── Validation helpers ─────────────────────────────────────────────────────
validate_project_name() {
    [[ "$1" =~ ^[a-z][a-z0-9_]*$ ]]
}

validate_domain() {
    [[ "$1" =~ ^[a-zA-Z0-9]([a-zA-Z0-9\-]*\.)+[a-zA-Z]{2,}$ ]]
}

validate_port() {
    [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -ge 1 ] && [ "$1" -le 65535 ]
}

# ─── Input helpers ───────────────────────────────────────────────────────────
ask_input() {
    local prompt="$1" placeholder="$2" default="$3" validator="${4:-}"
    local value
    while true; do
        value=$(gum input \
            --prompt "  $prompt: " \
            --placeholder "$placeholder" \
            --value "$default" \
            --prompt.foreground "#7C3AED" \
            --cursor.foreground "#7C3AED" \
            --width 60)
        if [ -n "$validator" ] && ! $validator "$value"; then
            gum style --foreground "#EF4444" "  ✗ Invalid input, try again"
            continue
        fi
        if [ -z "$value" ]; then
            gum style --foreground "#EF4444" "  ✗ This field is required"
            continue
        fi
        echo "$value"
        return
    done
}

ask_port() {
    local prompt="$1" default="$2"
    ask_input "$prompt" "$default" "$default" validate_port
}

# ═══════════════════════════════════════════════════════════════════════════════
# HEADER
# ═══════════════════════════════════════════════════════════════════════════════

clear
echo ""
gum style \
    --border double \
    --border-foreground "#7C3AED" \
    --padding "1 4" \
    --margin "0 2" \
    --bold \
    --foreground "#7C3AED" \
    "🌲  rpine Project Template Generator"
echo ""
gum style --foreground "#A1A1AA" --margin "0 4" \
    "Generate a full-stack project with Go backend, React frontend," \
    "Telegram bot, PostgreSQL + Redis, and Nginx/Traefik proxy."
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# QUIZ
# ═══════════════════════════════════════════════════════════════════════════════

# ── Cleanup ──────────────────────────────────────────────────────────────────
CLEANUP="n"
gum confirm --prompt.foreground "#7C3AED" "Delete setup script and templates after generation?" --default=false && CLEANUP="y" || true

# ── Project Settings ─────────────────────────────────────────────────────────
echo ""
gum style --bold --foreground "#7C3AED" --margin "0 2" "▎ Project Settings"
echo ""

PROJECT_NAME=$(ask_input "Project name" "my_project (snake_case)" "my_project" validate_project_name)
PROJECT_DOMAIN=$(ask_input "Domain" "example.rpine.xyz" "example.rpine.xyz" validate_domain)
GO_MODULE=$(ask_input "Go module" "github.com/r-pine/$PROJECT_NAME" "github.com/r-pine/$PROJECT_NAME")

# ── Architecture ─────────────────────────────────────────────────────────────
echo ""
gum style --bold --foreground "#7C3AED" --margin "0 2" "▎ Architecture"
echo ""

gum style --foreground "#A1A1AA" --margin "0 4" "Reverse proxy:"
PROXY_TYPE=$(gum choose --cursor.foreground "#7C3AED" --selected.foreground "#7C3AED" --item.foreground "#E4E4E7" "traefik" "nginx")

gum style --foreground "#A1A1AA" --margin "0 4" "Backend framework:"
BACKEND_FRAMEWORK=$(gum choose --cursor.foreground "#7C3AED" --selected.foreground "#7C3AED" --item.foreground "#E4E4E7" "gin" "echo")

INCLUDE_FRONTEND="n"
gum confirm --prompt.foreground "#7C3AED" "Include frontend (React + Vite + TailwindCSS)?" && INCLUDE_FRONTEND="y" || true

INCLUDE_BOT="n"
gum confirm --prompt.foreground "#7C3AED" "Include Telegram bot?" --default=false && INCLUDE_BOT="y" || true

# ── Telegram Bot ─────────────────────────────────────────────────────────────
TELEGRAM_BOT_TOKEN=""
TELEGRAM_WEBHOOK_SECRET=""
if [[ "$INCLUDE_BOT" == "y" ]]; then
    echo ""
    gum style --bold --foreground "#7C3AED" --margin "0 2" "▎ Telegram Bot"
    echo ""
    TELEGRAM_BOT_TOKEN=$(ask_input "Bot token" "123456:ABC-DEF..." "")
    TELEGRAM_WEBHOOK_SECRET=$(ask_input "Webhook secret" "random string" "")
fi

# ── Ports ────────────────────────────────────────────────────────────────────
echo ""
gum style --bold --foreground "#7C3AED" --margin "0 2" "▎ Ports"
echo ""

POSTGRES_PORT=$(ask_port "PostgreSQL port" "5432")
REDIS_PORT=$(ask_port "Redis port" "6379")
BACKEND_PORT=$(ask_port "Backend HTTP port" "8080")
GRPC_PORT=$(ask_port "gRPC internal port" "50051")
GRPC_EXTERNAL_PORT=$(ask_port "gRPC external port" "50052")

NGINX_PORT="8080"
LETSENCRYPT_EMAIL=""
ACME_EMAIL=""

if [[ "$PROXY_TYPE" == "nginx" ]]; then
    NGINX_PORT=$(ask_port "Nginx external port" "8080")
    echo ""
    gum style --bold --foreground "#7C3AED" --margin "0 2" "▎ SSL"
    echo ""
    LETSENCRYPT_EMAIL=$(ask_input "Let's Encrypt email" "you@example.com" "")
fi

if [[ "$PROXY_TYPE" == "traefik" ]]; then
    echo ""
    gum style --bold --foreground "#7C3AED" --margin "0 2" "▎ SSL"
    echo ""
    ACME_EMAIL=$(ask_input "ACME email (Let's Encrypt)" "you@example.com" "")
fi

# ─── Generate secrets ─────────────────────────────────────────────────────────
POSTGRES_USER="user_$(openssl rand -hex 4)"
POSTGRES_PASSWORD=$(openssl rand -base64 48 | tr -d '/+=\n' | head -c 32)
REDIS_PASSWORD=$(openssl rand -base64 48 | tr -d '/+=\n' | head -c 32)
JWT_SECRET=$(openssl rand -base64 64 | tr -d '/+=\n' | head -c 64)

# ═══════════════════════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════

echo ""

PROXY_DISPLAY="$PROXY_TYPE"
[[ "$PROXY_TYPE" == "traefik" ]] && PROXY_DISPLAY="traefik (ACME: $ACME_EMAIL)"
[[ "$PROXY_TYPE" == "nginx" ]] && PROXY_DISPLAY="nginx (port: $NGINX_PORT, SSL: $LETSENCRYPT_EMAIL)"

FEATURES=""
[[ "$INCLUDE_FRONTEND" == "y" ]] && FEATURES="React frontend"
[[ "$INCLUDE_BOT" == "y" ]] && { [[ -n "$FEATURES" ]] && FEATURES="$FEATURES, "; FEATURES="${FEATURES}Telegram bot"; }
[[ -z "$FEATURES" ]] && FEATURES="none"

SUMMARY=$(cat <<EOF
  Project        $PROJECT_NAME
  Domain         $PROJECT_DOMAIN
  Go Module      $GO_MODULE
  Proxy          $PROXY_DISPLAY
  Backend        $BACKEND_FRAMEWORK
  Features       $FEATURES
  PostgreSQL     :$POSTGRES_PORT  (user: $POSTGRES_USER)
  Redis          :$REDIS_PORT
  Backend HTTP   :$BACKEND_PORT
  gRPC           :$GRPC_PORT → :$GRPC_EXTERNAL_PORT
  Cleanup        $CLEANUP
EOF
)

gum style \
    --border rounded \
    --border-foreground "#7C3AED" \
    --padding "1 2" \
    --margin "0 2" \
    --foreground "#E4E4E7" \
    --bold \
    "$SUMMARY"

echo ""

if ! gum confirm --prompt.foreground "#22C55E" --affirmative "Generate!" --negative "Cancel" "Proceed with project generation?" 2>/dev/null; then
    gum style --foreground "#EF4444" "Aborted."
    exit 0
fi

# ═══════════════════════════════════════════════════════════════════════════════
# GENERATION
# ═══════════════════════════════════════════════════════════════════════════════

echo ""

generate_project() {
    # ─── Clean existing generated dirs ───────────────────────────────────────
    for d in backend frontend bot proto nginx-app traefik-app ci_traefik ci_nginx .envs; do
        rm -rf "$d"
    done
    rm -f docker-compose.yml docker-compose.db.yml .gitignore .dockerignore

    # ─── Copy backend ────────────────────────────────────────────────────────
    cp -r "templates/backend-${BACKEND_FRAMEWORK}" backend

    # ─── Copy proto ──────────────────────────────────────────────────────────
    cp -r templates/proto proto

    # ─── Copy frontend ───────────────────────────────────────────────────────
    if [[ "$INCLUDE_FRONTEND" == "y" ]]; then
        cp -r templates/frontend frontend
    fi

    # ─── Copy bot ────────────────────────────────────────────────────────────
    if [[ "$INCLUDE_BOT" == "y" ]]; then
        cp -r templates/bot bot
    fi

    # ─── Copy proxy configs ──────────────────────────────────────────────────
    if [[ "$PROXY_TYPE" == "nginx" ]]; then
        cp -r templates/nginx-app nginx-app

        if [[ "$INCLUDE_BOT" == "y" ]]; then
            sed -i 's|# BOT_WEBHOOK_LOCATION|location /webhook/bot {\
        proxy_pass http://backend/webhook/bot;\
        proxy_set_header Host $host;\
        proxy_set_header X-Real-IP $remote_addr;\
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\
        proxy_set_header X-Forwarded-Proto $scheme;\
    }|' nginx-app/default.conf
        else
            sed -i '/# BOT_WEBHOOK_LOCATION/d' nginx-app/default.conf
        fi

        if [[ "$INCLUDE_FRONTEND" == "y" ]]; then
            FRONTEND_BLOCK="location / {\\
        proxy_pass http://${PROJECT_NAME}_frontend:80;\\
        proxy_set_header Host \\\$host;\\
        proxy_set_header X-Real-IP \\\$remote_addr;\\
        proxy_set_header X-Forwarded-For \\\$proxy_add_x_forwarded_for;\\
        proxy_set_header X-Forwarded-Proto \\\$scheme;\\
    }"
            sed -i "s|# FRONTEND_LOCATION|${FRONTEND_BLOCK}|" nginx-app/default.conf
        else
            sed -i '/# FRONTEND_LOCATION/d' nginx-app/default.conf
        fi

    elif [[ "$PROXY_TYPE" == "traefik" ]]; then
        cp -r templates/traefik-app traefik-app
        cp -r templates/ci_traefik ci_traefik

        if [[ "$INCLUDE_BOT" == "y" ]]; then
            sed -i "s|# BOT_ROUTER|${PROJECT_NAME}-webhook:\n      rule: \"Host(\`${PROJECT_DOMAIN}\`) \&\& PathPrefix(\`/webhook/bot\`)\"\n      entryPoints:\n        - websecure\n      service: ${PROJECT_NAME}-api\n      tls:\n        certResolver: le|" traefik-app/dynamic/project.yml
        else
            sed -i '/# BOT_ROUTER/d' traefik-app/dynamic/project.yml
        fi

        if [[ "$INCLUDE_FRONTEND" == "y" ]]; then
            sed -i "s|# FRONTEND_ROUTER|${PROJECT_NAME}-frontend:\n      rule: \"Host(\`${PROJECT_DOMAIN}\`)\"\n      entryPoints:\n        - websecure\n      service: ${PROJECT_NAME}-frontend\n      tls:\n        certResolver: le\n      priority: 1|" traefik-app/dynamic/project.yml
            sed -i "s|# FRONTEND_SERVICE|${PROJECT_NAME}-frontend:\n      loadBalancer:\n        servers:\n          - url: \"http://${PROJECT_NAME}_frontend:80\"|" traefik-app/dynamic/project.yml
        else
            sed -i '/# FRONTEND_ROUTER/d' traefik-app/dynamic/project.yml
            sed -i '/# FRONTEND_SERVICE/d' traefik-app/dynamic/project.yml
        fi
    fi

    # ─── Docker Compose ──────────────────────────────────────────────────────
    cp templates/compose/docker-compose-base.yml docker-compose.yml

    if [[ "$INCLUDE_FRONTEND" == "y" ]]; then
        cat templates/compose/docker-compose-frontend.yml >> docker-compose.yml
    fi
    if [[ "$INCLUDE_BOT" == "y" ]]; then
        cat templates/compose/docker-compose-bot.yml >> docker-compose.yml
    fi
    if [[ "$PROXY_TYPE" == "nginx" ]]; then
        cat templates/compose/docker-compose-nginx.yml >> docker-compose.yml
    fi
    cat templates/compose/docker-compose-networks.yml >> docker-compose.yml

    cp templates/compose/docker-compose.db.yml docker-compose.db.yml

    # ─── Environment files ───────────────────────────────────────────────────
    mkdir -p .envs

    cp templates/envs/env.example .envs/.env.example
    cp templates/envs/env.example .envs/.env
    sed -i "s/POSTGRES_USER=changeme/POSTGRES_USER=${POSTGRES_USER}/" .envs/.env
    sed -i "s/POSTGRES_PASSWORD=changeme/POSTGRES_PASSWORD=${POSTGRES_PASSWORD}/" .envs/.env
    sed -i "s/REDIS_PASSWORD=changeme/REDIS_PASSWORD=${REDIS_PASSWORD}/" .envs/.env
    sed -i "s/JWT_SECRET=changeme/JWT_SECRET=${JWT_SECRET}/" .envs/.env

    if [[ "$INCLUDE_BOT" == "y" ]]; then
        cp templates/envs/env.bot.example .envs/.env.bot.example
        cp templates/envs/env.bot.example .envs/.env.bot
        sed -i "s|TELEGRAM_BOT_TOKEN=your_bot_token|TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}|" .envs/.env.bot
        sed -i "s|TELEGRAM_WEBHOOK_SECRET=changeme|TELEGRAM_WEBHOOK_SECRET=${TELEGRAM_WEBHOOK_SECRET}|" .envs/.env.bot
        sed -i "s|DATABASE_URL=.*|DATABASE_URL=postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres-${PROJECT_NAME}:${POSTGRES_PORT}/${PROJECT_NAME}|" .envs/.env.bot
    fi

    if [[ "$PROXY_TYPE" == "nginx" ]]; then
        cp templates/envs/env.web.example .envs/.env.web.example
        cp templates/envs/env.web.example .envs/.env.web
        sed -i "s|LETSENCRYPT_EMAIL=changeme@example.com|LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL}|" .envs/.env.web
    fi

    if [[ "$PROXY_TYPE" == "traefik" ]]; then
        cp templates/envs/ci_traefik.env.example ci_traefik/.env.example
        cp templates/envs/ci_traefik.env.example ci_traefik/.env
    fi

    if [[ "$INCLUDE_FRONTEND" == "y" ]]; then
        cp templates/envs/env.front.example .envs/.env.front.example
        cp templates/envs/env.front.example .envs/.env.front
    fi

    # ─── Misc files ──────────────────────────────────────────────────────────
    cp templates/gitignore.tpl .gitignore
    cp templates/dockerignore.tpl .dockerignore

    # ─── Placeholder substitution ────────────────────────────────────────────
    find . -maxdepth 1 -mindepth 1 -not -name 'templates' -not -name 'setup.sh' -not -name '.git' -not -name '*.plan.md' | while read -r dir; do
        if [ -d "$dir" ] || [ -f "$dir" ]; then
            find "$dir" -type f \( \
                -name "*.go" -o -name "*.mod" -o -name "*.yml" -o -name "*.yaml" \
                -o -name "*.json" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" \
                -o -name "*.html" -o -name "*.css" -o -name "*.conf" -o -name ".env*" \
                -o -name "*.proto" -o -name "Makefile" \
                -o -name "Dockerfile" -o -name ".gitignore" -o -name ".dockerignore" \
                -o -name "*.md" \
            \) -exec sed -i \
                -e "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" \
                -e "s|{{PROJECT_DOMAIN}}|${PROJECT_DOMAIN}|g" \
                -e "s|{{GO_MODULE}}|${GO_MODULE}|g" \
                -e "s|{{BACKEND_PORT}}|${BACKEND_PORT}|g" \
                -e "s|{{GRPC_PORT}}|${GRPC_PORT}|g" \
                -e "s|{{GRPC_EXTERNAL_PORT}}|${GRPC_EXTERNAL_PORT}|g" \
                -e "s|{{POSTGRES_PORT}}|${POSTGRES_PORT}|g" \
                -e "s|{{REDIS_PORT}}|${REDIS_PORT}|g" \
                -e "s|{{NGINX_PORT}}|${NGINX_PORT}|g" \
                -e "s|{{ACME_EMAIL}}|${ACME_EMAIL}|g" \
                -e "s|{{LETSENCRYPT_EMAIL}}|${LETSENCRYPT_EMAIL}|g" \
                {} +
        fi
    done

    # ─── Rename proto file ───────────────────────────────────────────────────
    if [ -f "proto/service.proto" ]; then
        mv "proto/service.proto" "proto/${PROJECT_NAME}.proto"
    fi

    # ─── Create go.sum placeholders ──────────────────────────────────────────
    touch backend/go.sum
    if [[ "$INCLUDE_BOT" == "y" ]]; then
        touch bot/go.sum
    fi
}

gum spin --spinner dot --spinner.foreground "#7C3AED" --title "Generating project..." -- bash -c "$(declare -f generate_project); generate_project"

# ─── Cleanup ─────────────────────────────────────────────────────────────────
if [[ "$CLEANUP" == "y" ]]; then
    gum spin --spinner dot --spinner.foreground "#7C3AED" --title "Cleaning up..." -- \
        bash -c "rm -rf templates/ setup.sh"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# DONE
# ═══════════════════════════════════════════════════════════════════════════════

echo ""
gum style \
    --border double \
    --border-foreground "#22C55E" \
    --padding "1 3" \
    --margin "0 2" \
    --foreground "#22C55E" \
    --bold \
    "✓  Project generated successfully!"

echo ""

NEXT_STEPS="  1. Create Docker network (if not exists):
     docker network create shared-web

  2. Start databases:
     docker compose -f docker-compose.db.yml up -d

  3. Start services:
     docker compose up -d --build"

if [[ "$PROXY_TYPE" == "traefik" ]]; then
    NEXT_STEPS="$NEXT_STEPS

  4. Start Traefik edge proxy:
     cd ci_traefik && docker compose up -d"
fi

gum style --border rounded --border-foreground "#3B82F6" --padding "1 2" --margin "0 2" --foreground "#E4E4E7" "$NEXT_STEPS"

echo ""

ENDPOINTS="  API       https://${PROJECT_DOMAIN}/api/v1/healthcheck
  gRPC      ${PROJECT_DOMAIN}:${GRPC_EXTERNAL_PORT}"
if [[ "$INCLUDE_FRONTEND" == "y" ]]; then
    ENDPOINTS="  Frontend  https://${PROJECT_DOMAIN}/
$ENDPOINTS"
fi

gum style --border rounded --border-foreground "#7C3AED" --padding "1 2" --margin "0 2" --bold --foreground "#E4E4E7" "$ENDPOINTS"

echo ""

if [[ "$CLEANUP" != "y" ]]; then
    gum style --foreground "#F59E0B" --margin "0 4" \
        "💡 templates/ and setup.sh are still present." \
        "   You can delete them manually or re-run with cleanup."
    echo ""
fi
