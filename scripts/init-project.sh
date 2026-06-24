#!/bin/bash
# scripts/init-project.sh
# Inicializa un proyecto con la metodología utopia-stdd-registry (STDD)
#
# Uso:
#   ./init-project.sh <nombre> [archetype] [destino] [--yes]
#   curl -fsSL https://raw.githubusercontent.com/devu2pi/utopia-stdd-registry/main/scripts/init-project.sh | bash -s -- <nombre> [archetype] [destino] [--yes]
#
# Arquetipos: webapp-nextjs | api-fastapi | fullstack
# --yes / -y : omite todas las confirmaciones interactivas

REGISTRY_REPO="devu2pi/utopia-stdd-registry"
REGISTRY_URL="https://github.com/$REGISTRY_REPO"

# ── Colores ────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
info()    { echo -e "${BLUE}[stdd]${NC} $1"; }
success() { echo -e "${GREEN}[stdd]${NC} ✓ $1"; }
warn()    { echo -e "${YELLOW}[stdd]${NC} ⚠ $1"; }
error()   { echo -e "${RED}[stdd]${NC} ✗ $1"; exit 1; }

# ── Parsear argumentos ─────────────────────────────────────────────────────
YES_MODE=false
POSITIONAL=()
for arg in "$@"; do
  case "$arg" in
    --yes|-y) YES_MODE=true ;;
    *)        POSITIONAL+=("$arg") ;;
  esac
done

# Si stdin no es TTY (curl | bash, pipe), forzar YES_MODE
[ -t 0 ] || YES_MODE=true

PROJECT_NAME="${POSITIONAL[0]:-}"
ARCHETYPE="${POSITIONAL[1]:-}"
DEST_PATH="${POSITIONAL[2]:-}"

# ── Registry: local o remoto ───────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" 2>/dev/null && pwd || true)"
TEMP_REGISTRY=""

if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/../registry.json" ]; then
  REGISTRY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  REGISTRY_DIR="$(mktemp -d)"
  TEMP_REGISTRY="$REGISTRY_DIR"
  info "Descargando registry desde GitHub..."
  git clone --depth=1 --quiet "$REGISTRY_URL" "$REGISTRY_DIR" 2>/dev/null \
    || error "No se pudo clonar $REGISTRY_URL — verificá conexión y que el repo sea público."
fi

COMMANDS_DIR="$REGISTRY_DIR/commands"
TEMPLATES_DIR="$REGISTRY_DIR/templates"
cleanup() { [ -n "$TEMP_REGISTRY" ] && rm -rf "$TEMP_REGISTRY"; }
trap cleanup EXIT

# ── Header ─────────────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  utopia-stdd-registry — init project     ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

# ── Nombre del proyecto ────────────────────────────────────────────────────
if [ -z "$PROJECT_NAME" ]; then
  if [ "$YES_MODE" = true ]; then
    error "Especificá el nombre del proyecto. Uso: init-project.sh <nombre> [archetype] [destino]"
  fi
  read -rp "Nombre del proyecto (kebab-case): " PROJECT_NAME || true
fi
[ -z "$PROJECT_NAME" ] && error "El nombre del proyecto es requerido."

# ── Archetype ──────────────────────────────────────────────────────────────
VALID_ARCHETYPES=("webapp-nextjs" "api-fastapi" "fullstack")

if [ -z "$ARCHETYPE" ]; then
  if [ "$YES_MODE" = true ]; then
    error "Especificá el archetype. Opciones: webapp-nextjs | api-fastapi | fullstack"
  fi
  echo "Arquetipos disponibles:"
  echo "  1) webapp-nextjs  — Next.js 14 + Supabase + TypeScript"
  echo "  2) api-fastapi    — FastAPI + PostgreSQL + Python"
  echo "  3) fullstack      — Next.js + FastAPI + Supabase"
  read -rp "Seleccioná (1/2/3): " ARCH_CHOICE || true
  case "$ARCH_CHOICE" in
    1) ARCHETYPE="webapp-nextjs" ;;
    2) ARCHETYPE="api-fastapi" ;;
    3) ARCHETYPE="fullstack" ;;
    *) error "Opción inválida." ;;
  esac
fi

VALID=false
for a in "${VALID_ARCHETYPES[@]}"; do [ "$a" = "$ARCHETYPE" ] && VALID=true; done
[ "$VALID" = false ] && error "Archetype '$ARCHETYPE' no válido. Opciones: ${VALID_ARCHETYPES[*]}"

# ── Destino ────────────────────────────────────────────────────────────────
[ -z "$DEST_PATH" ] && DEST_PATH="./$PROJECT_NAME"

case "$ARCHETYPE" in
  webapp-nextjs) STACK_SUMMARY="Next.js 14+ | TypeScript strict | Tailwind | shadcn/ui | Supabase | Zustand | TanStack Query | Vitest | Playwright | Vercel" ;;
  api-fastapi)   STACK_SUMMARY="FastAPI 0.100+ | Python 3.11+ | Pydantic v2 | SQLAlchemy 2.0 | PostgreSQL 15 | Alembic | pytest | Docker | Railway" ;;
  fullstack)     STACK_SUMMARY="Next.js 14+ | FastAPI | TypeScript + Python | Supabase | Tailwind | Vitest + Playwright + pytest" ;;
esac

# ── Confirmar ──────────────────────────────────────────────────────────────
echo "Configuración:"
echo "  Proyecto:  $PROJECT_NAME"
echo "  Archetype: $ARCHETYPE"
echo "  Destino:   $DEST_PATH"
echo ""

if [ "$YES_MODE" = false ]; then
  read -rp "¿Confirmar? [s/N] " CONFIRM || true
  [ "$CONFIRM" != "s" ] && [ "$CONFIRM" != "S" ] && { echo "Cancelado."; exit 0; }
fi

# ── Directorio existente ───────────────────────────────────────────────────
if [ -d "$DEST_PATH" ]; then
  if [ "$YES_MODE" = false ]; then
    warn "El directorio '$DEST_PATH' ya existe."
    read -rp "¿Inicializar dentro del directorio existente? [s/N] " OW || true
    [ "$OW" != "s" ] && [ "$OW" != "S" ] && { echo "Cancelado."; exit 0; }
  else
    info "Proyecto existente — instalando sobre directorio actual."
  fi
fi

# ── Crear estructura ───────────────────────────────────────────────────────
echo ""
info "Creando estructura..."

mkdir -p "$DEST_PATH/.agent"
mkdir -p "$DEST_PATH/.claude/commands"
mkdir -p "$DEST_PATH/openspec/changes"
mkdir -p "$DEST_PATH/openspec/specs"

# Comandos STDD — siempre se sobreescriben (son del registry, no del proyecto)
info "Instalando comandos STDD..."
cp "$COMMANDS_DIR"/*.md "$DEST_PATH/.claude/commands/"
success "Comandos instalados en .claude/commands/ (7 comandos)"

# .agent/config.yaml — solo si no existe
if [ ! -f "$DEST_PATH/.agent/config.yaml" ]; then
  info "Generando .agent/config.yaml..."
  sed \
    -e "s/__ARCHETYPE__/$ARCHETYPE/g" \
    -e "s/__PROJECT_NAME__/$PROJECT_NAME/g" \
    -e "s/__PROJECT_DESCRIPTION__/Descripción del proyecto — completar/g" \
    "$TEMPLATES_DIR/agent-config.yaml" > "$DEST_PATH/.agent/config.yaml"
  success ".agent/config.yaml generado"
else
  warn ".agent/config.yaml ya existe — preservado sin cambios"
fi

# openspec/project.md — solo si no existe o es template vacío
PROJ_MD="$DEST_PATH/openspec/project.md"
if [ ! -f "$PROJ_MD" ] || grep -q "__PROJECT_NAME__" "$PROJ_MD" 2>/dev/null; then
  info "Generando openspec/project.md..."
  sed \
    -e "s/__PROJECT_NAME__/$PROJECT_NAME/g" \
    -e "s/__PROJECT_TYPE__/[$ARCHETYPE]/g" \
    "$TEMPLATES_DIR/project.md" > "$PROJ_MD"
  success "openspec/project.md generado"
else
  warn "openspec/project.md ya existe con contenido — preservado sin cambios"
fi

# CLAUDE.md — solo si no existe
if [ ! -f "$DEST_PATH/CLAUDE.md" ]; then
  info "Generando CLAUDE.md..."
  sed -e "s/__STACK_SUMMARY__/$STACK_SUMMARY/g" \
    "$TEMPLATES_DIR/CLAUDE.md" > "$DEST_PATH/CLAUDE.md"
  success "CLAUDE.md generado"
else
  warn "CLAUDE.md ya existe — preservado sin cambios"
fi

# Archetype ref
ARCHETYPE_FILE="$REGISTRY_DIR/archetypes/$ARCHETYPE/archetype.md"
if [ -f "$ARCHETYPE_FILE" ] && [ ! -f "$DEST_PATH/openspec/archetype-ref.md" ]; then
  cp "$ARCHETYPE_FILE" "$DEST_PATH/openspec/archetype-ref.md"
  success "Referencia del archetype copiada a openspec/archetype-ref.md"
fi

# ── Resumen ────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Proyecto inicializado ✓                 ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo "  .agent/config.yaml     ← configuración del registry"
echo "  .claude/commands/      ← 7 comandos STDD"
echo "  openspec/project.md    ← completar con contexto del proyecto"
echo "  CLAUDE.md              ← guía para Claude Code"
echo ""
echo -e "${YELLOW}Próximos pasos:${NC}"
echo "  1. Completar openspec/project.md si tiene placeholders"
echo "  2. En Claude Code: /stdd-status"
echo "  3. Para el primer cambio: /stdd-propose <nombre-modulo>"
echo ""
