#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_header() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║          rpine Project Template Generator            ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "${GREEN}▸ $1${NC}"
}

print_warn() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# ─── Validation helpers ─────────────────────────────────────────────────────
validate_project_name() {
    if [[ ! "$1" =~ ^[a-z][a-z0-9_]*$ ]]; then
        print_error "Project name must start with a letter, contain only lowercase letters, digits, and underscores"
        return 1
    fi
}

validate_domain() {
    if [[ ! "$1" =~ ^[a-zA-Z0-9]([a-zA-Z0-9\-]*\.)+[a-zA-Z]{2,}$ ]]; then
        print_error "Invalid domain format (example: myapp.rpine.xyz)"
        return 1
    fi
}

validate_port() {
    if [[ ! "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 1 ] || [ "$1" -gt 65535 ]; then
        print_error "Port must be a number between 1 and 65535"
        return 1
    fi
}

validate_choice() {
    local value="$1"
    shift
    for opt in "$@"; do
        [[ "$value" == "$opt" ]] && return 0
    done
    print_error "Invalid choice. Options: $*"
    return 1
}

ask() {
    local prompt="$1" default="$2" var_name="$3" validator="${4:-}"
    while true; do
        if [ -n "$default" ]; then
            read -rp "$(echo -e "${BOLD}$prompt${NC} [${CYAN}$default${NC}]: ")" input
            input="${input:-$default}"
        else
            read -rp "$(echo -e "${BOLD}$prompt${NC}: ")" input
        fi
        if [ -n "$validator" ]; then
            if $validator "$input"; then
                break
            fi
        else
            if [ -n "$input" ]; then
                break
            fi
            print_error "This field is required"
        fi
    done
    eval "$var_name=\"$input\""
}

ask_yn() {
    local prompt="$1" default="$2" var_name="$3"
    while true; do
        read -rp "$(echo -e "${BOLD}$prompt${NC} [${CYAN}$default${NC}]: ")" input
        input="${input:-$default}"
        input=$(echo "$input" | tr '[:upper:]' '[:lower:]')
        if [[ "$input" == "y" || "$input" == "n" ]]; then
            eval "$var_name=\"$input\""
            return
        fi
        print_error "Please enter y or n"
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

print_header

echo -e "${BOLD}This script will generate a project from the rpine template.${NC}"
echo ""

# ─── Quiz ─────────────────────────────────────────────────────────────────────

ask_yn "Delete setup script and templates after generation? (y/N)" "n" CLEANUP

echo ""
echo -e "${CYAN}── Project Settings ──${NC}"
ask "Project name (lowercase, snake_case)" "my_project" PROJECT_NAME validate_project_name
ask "Project domain" "example.rpine.xyz" PROJECT_DOMAIN validate_domain
ask "Go module path" "github.com/r-pine/${PROJECT_NAME}" GO_MODULE

echo ""
echo -e "${CYAN}── Architecture ──${NC}"

while true; do
    read -rp "$(echo -e "${BOLD}Reverse proxy (nginx/traefik)${NC} [${CYAN}traefik${NC}]: ")" PROXY_TYPE
    PROXY_TYPE="${PROXY_TYPE:-traefik}"
    validate_choice "$PROXY_TYPE" "nginx" "traefik" && break
done

while true; do
    read -rp "$(echo -e "${BOLD}Backend framework (gin/echo)${NC} [${CYAN}gin${NC}]: ")" BACKEND_FRAMEWORK
    BACKEND_FRAMEWORK="${BACKEND_FRAMEWORK:-gin}"
    validate_choice "$BACKEND_FRAMEWORK" "gin" "echo" && break
done

ask_yn "Include frontend (React + Vite + TailwindCSS)? (y/n)" "y" INCLUDE_FRONTEND
ask_yn "Include Telegram bot? (y/n)" "n" INCLUDE_BOT

if [[ "$INCLUDE_BOT" == "y" ]]; then
    echo ""
    echo -e "${CYAN}── Telegram Bot ──${NC}"
    ask "Telegram bot token" "" TELEGRAM_BOT_TOKEN
    ask "Telegram webhook secret (random string)" "" TELEGRAM_WEBHOOK_SECRET
fi

echo ""
echo -e "${CYAN}── Ports ──${NC}"
ask "PostgreSQL port" "5432" POSTGRES_PORT validate_port
ask "Redis port" "6379" REDIS_PORT validate_port
ask "Backend HTTP port" "8080" BACKEND_PORT validate_port
ask "gRPC internal port" "50051" GRPC_PORT validate_port
ask "gRPC external port (proxy)" "50052" GRPC_EXTERNAL_PORT validate_port

if [[ "$PROXY_TYPE" == "nginx" ]]; then
    ask "Nginx external port" "8080" NGINX_PORT validate_port
    echo ""
    echo -e "${CYAN}── SSL ──${NC}"
    ask "Let's Encrypt email (for nginx-proxy)" "" LETSENCRYPT_EMAIL
fi

if [[ "$PROXY_TYPE" == "traefik" ]]; then
    echo ""
    echo -e "${CYAN}── SSL ──${NC}"
    ask "ACME email (for Traefik Let's Encrypt)" "" ACME_EMAIL
fi

# ─── Generate secrets ─────────────────────────────────────────────────────────
print_step "Generating secrets..."
POSTGRES_USER="user_$(openssl rand -hex 4)"
POSTGRES_PASSWORD=$(openssl rand -base64 48 | tr -d '/+=\n' | head -c 32)
REDIS_PASSWORD=$(openssl rand -base64 48 | tr -d '/+=\n' | head -c 32)
JWT_SECRET=$(openssl rand -base64 64 | tr -d '/+=\n' | head -c 64)

# ─── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                  Project Summary                     ║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════╣${NC}"
echo -e "  Project:       ${GREEN}$PROJECT_NAME${NC}"
echo -e "  Domain:        ${GREEN}$PROJECT_DOMAIN${NC}"
echo -e "  Go Module:     ${GREEN}$GO_MODULE${NC}"
echo -e "  Proxy:         ${GREEN}$PROXY_TYPE${NC}"
echo -e "  Backend:       ${GREEN}$BACKEND_FRAMEWORK${NC}"
echo -e "  Frontend:      ${GREEN}$INCLUDE_FRONTEND${NC}"
echo -e "  Bot:           ${GREEN}$INCLUDE_BOT${NC}"
echo -e "  PostgreSQL:    ${GREEN}:$POSTGRES_PORT${NC} (user: ${GREEN}$POSTGRES_USER${NC})"
echo -e "  Redis:         ${GREEN}:$REDIS_PORT${NC}"
echo -e "  Backend HTTP:  ${GREEN}:$BACKEND_PORT${NC}"
echo -e "  gRPC:          ${GREEN}:$GRPC_PORT -> :$GRPC_EXTERNAL_PORT${NC}"
if [[ "$PROXY_TYPE" == "nginx" ]]; then
echo -e "  Nginx port:    ${GREEN}:$NGINX_PORT${NC}"
fi
echo -e "  Cleanup:       ${GREEN}$CLEANUP${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

read -rp "$(echo -e "${BOLD}Proceed with generation? (Y/n)${NC}: ")" confirm
confirm="${confirm:-y}"
if [[ "$(echo "$confirm" | tr '[:upper:]' '[:lower:]')" != "y" ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
print_step "Starting project generation..."

# ─── Clean existing generated dirs ───────────────────────────────────────────
for d in backend frontend bot proto nginx-app traefik-app ci_traefik ci_nginx .envs; do
    rm -rf "$d"
done
rm -f docker-compose.yml docker-compose.db.yml .gitignore .dockerignore

# ─── Copy backend ─────────────────────────────────────────────────────────────
print_step "Copying backend ($BACKEND_FRAMEWORK)..."
cp -r "templates/backend-${BACKEND_FRAMEWORK}" backend

# ─── Copy proto ───────────────────────────────────────────────────────────────
print_step "Copying proto..."
cp -r templates/proto proto

# ─── Copy frontend ────────────────────────────────────────────────────────────
if [[ "$INCLUDE_FRONTEND" == "y" ]]; then
    print_step "Copying frontend..."
    cp -r templates/frontend frontend
fi

# ─── Copy bot ─────────────────────────────────────────────────────────────────
if [[ "$INCLUDE_BOT" == "y" ]]; then
    print_step "Copying bot..."
    cp -r templates/bot bot
fi

# ─── Copy proxy configs ──────────────────────────────────────────────────────
if [[ "$PROXY_TYPE" == "nginx" ]]; then
    print_step "Copying nginx configuration..."
    cp -r templates/nginx-app nginx-app

    # Inject bot webhook location into nginx config
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

    # Inject frontend location into nginx config
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
    print_step "Copying traefik configuration..."
    cp -r templates/traefik-app traefik-app
    cp -r templates/ci_traefik ci_traefik

    # Inject bot router into traefik dynamic config
    if [[ "$INCLUDE_BOT" == "y" ]]; then
        sed -i "s|# BOT_ROUTER|${PROJECT_NAME}-webhook:\n      rule: \"Host(\`${PROJECT_DOMAIN}\`) \&\& PathPrefix(\`/webhook/bot\`)\"\n      entryPoints:\n        - websecure\n      service: ${PROJECT_NAME}-api\n      tls:\n        certResolver: le|" traefik-app/dynamic/project.yml
    else
        sed -i '/# BOT_ROUTER/d' traefik-app/dynamic/project.yml
    fi

    # Inject frontend router + service into traefik dynamic config
    if [[ "$INCLUDE_FRONTEND" == "y" ]]; then
        sed -i "s|# FRONTEND_ROUTER|${PROJECT_NAME}-frontend:\n      rule: \"Host(\`${PROJECT_DOMAIN}\`)\"\n      entryPoints:\n        - websecure\n      service: ${PROJECT_NAME}-frontend\n      tls:\n        certResolver: le\n      priority: 1|" traefik-app/dynamic/project.yml

        sed -i "s|# FRONTEND_SERVICE|${PROJECT_NAME}-frontend:\n      loadBalancer:\n        servers:\n          - url: \"http://${PROJECT_NAME}_frontend:80\"|" traefik-app/dynamic/project.yml
    else
        sed -i '/# FRONTEND_ROUTER/d' traefik-app/dynamic/project.yml
        sed -i '/# FRONTEND_SERVICE/d' traefik-app/dynamic/project.yml
    fi
fi

# ─── Copy docker-compose files ───────────────────────────────────────────────
print_step "Generating docker-compose.yml..."

# Build docker-compose.yml dynamically
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

print_step "Copying docker-compose.db.yml..."
cp templates/compose/docker-compose.db.yml docker-compose.db.yml

# ─── Copy env files ──────────────────────────────────────────────────────────
print_step "Creating environment files..."
mkdir -p .envs

# .env.example (with changeme placeholders)
cp templates/envs/env.example .envs/.env.example

# .env (with real generated secrets)
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
    # ACME_EMAIL is already a placeholder that will be replaced by sed below
fi

if [[ "$INCLUDE_FRONTEND" == "y" ]]; then
    cp templates/envs/env.front.example .envs/.env.front.example
    cp templates/envs/env.front.example .envs/.env.front
fi

# ─── Copy misc files ─────────────────────────────────────────────────────────
print_step "Creating .gitignore and .dockerignore..."
cp templates/gitignore.tpl .gitignore
cp templates/dockerignore.tpl .dockerignore

# ─── Placeholder substitution ────────────────────────────────────────────────
print_step "Replacing placeholders..."

# Set NGINX_PORT default if not set (traefik case)
NGINX_PORT="${NGINX_PORT:-8080}"
ACME_EMAIL="${ACME_EMAIL:-}"
LETSENCRYPT_EMAIL="${LETSENCRYPT_EMAIL:-}"
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
TELEGRAM_WEBHOOK_SECRET="${TELEGRAM_WEBHOOK_SECRET:-}"

# Find all generated files (skip templates/ directory)
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

# ─── Rename proto file ───────────────────────────────────────────────────────
if [ -f "proto/service.proto" ]; then
    mv "proto/service.proto" "proto/${PROJECT_NAME}.proto"
fi

# ─── Create go.sum placeholders ──────────────────────────────────────────────
touch backend/go.sum
if [[ "$INCLUDE_BOT" == "y" ]]; then
    touch bot/go.sum
fi

# ─── Rename project directory ─────────────────────────────────────────────────
PROJECT_SLUG=$(echo "$PROJECT_NAME" | tr '_' '-')
CURRENT_DIR=$(basename "$SCRIPT_DIR")
if [[ "$CURRENT_DIR" != "$PROJECT_SLUG" ]]; then
    PARENT_DIR=$(dirname "$SCRIPT_DIR")
    NEW_DIR="${PARENT_DIR}/${PROJECT_SLUG}"
    if [ -d "$NEW_DIR" ]; then
        print_warn "Directory ${NEW_DIR} already exists, skipping rename"
    else
        print_step "Renaming project directory: ${CURRENT_DIR} -> ${PROJECT_SLUG}"
        cd "$PARENT_DIR"
        mv "$CURRENT_DIR" "$PROJECT_SLUG"
        cd "$NEW_DIR"
    fi
fi

# ─── Cleanup ─────────────────────────────────────────────────────────────────
if [[ "$CLEANUP" == "y" ]]; then
    print_step "Cleaning up templates and setup script..."
    rm -rf templates/
    rm -f setup.sh
    rm -rf .git

    print_step "Initializing new git repository..."
    git init
    git add .
    git commit -m "Initial commit: ${PROJECT_NAME} project generated from rpine template"
fi

# ─── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            Project generated successfully!           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Project: ${BOLD}${PROJECT_NAME}${NC}"
echo -e "Domain:  ${BOLD}${PROJECT_DOMAIN}${NC}"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo ""
echo -e "  1. Create Docker network (if not exists):"
echo -e "     ${CYAN}docker network create shared-web${NC}"
echo ""
echo -e "  2. Start databases:"
echo -e "     ${CYAN}docker compose -f docker-compose.db.yml up -d${NC}"
echo ""
echo -e "  3. Start services:"
echo -e "     ${CYAN}docker compose up -d --build${NC}"
echo ""
if [[ "$PROXY_TYPE" == "traefik" ]]; then
echo -e "  4. Start Traefik edge proxy:"
echo -e "     ${CYAN}cd ci_traefik && docker compose up -d${NC}"
echo ""
fi
echo -e "  API:      ${CYAN}https://${PROJECT_DOMAIN}/api/v1/healthcheck${NC}"
if [[ "$INCLUDE_FRONTEND" == "y" ]]; then
echo -e "  Frontend: ${CYAN}https://${PROJECT_DOMAIN}/${NC}"
fi
echo -e "  gRPC:     ${CYAN}${PROJECT_DOMAIN}:${GRPC_EXTERNAL_PORT}${NC}"
echo ""
if [[ "$CLEANUP" != "y" ]]; then
echo -e "${YELLOW}Tip: templates/ and setup.sh are still present. You can delete them manually or re-run with cleanup enabled.${NC}"
fi
