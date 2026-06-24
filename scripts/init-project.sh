#!/bin/bash
# scripts/init-project.sh
# Inicializa un proyecto nuevo con la metodología del registry
#
# Uso:
#   ./init-project.sh <nombre-proyecto> [archetype] [ruta-destino]
#
# Ejemplos:
#   ./init-project.sh mi-app webapp-nextjs
#   ./init-project.sh mi-api api-fastapi ../proyectos/mi-api
#
# Arquetipos disponibles: webapp-nextjs | api-fastapi | fullstack
# Si no se especifica archetype, pregunta interactivamente.

set -euo pipefail

REGISTRY_REPO="devu2pi/utopia-stdd-registry"
REGISTRY_URL="https://github.com/$REGISTRY_REPO"
REGISTRY_RAW="https://raw.githubusercontent.com/$REGISTRY_REPO/main"

# Si el script se ejecuta desde un clone local del registry, usarlo directamente.
# Si se ejecuta remotamente (curl | bash), clonar el registry en un temp dir.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-/dev/null}")" 2>/dev/null && pwd || echo "")"
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/../registry.json" ]; then
  REGISTRY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
  TEMP_REGISTRY=""
else
  REGISTRY_DIR="$(mktemp -d)"
  TEMP_REGISTRY="$REGISTRY_DIR"
  echo -e "\033[0;34m[stdd]\033[0m Descargando registry desde GitHub..."
  git clone --depth=1 --quiet "$REGISTRY_URL" "$REGISTRY_DIR" 2>/dev/null || {
    echo -e "\033[0;31m[stdd]\033[0m ERROR: No se pudo clonar $REGISTRY_URL"
    echo "       Verificá tu conexión o que el repo sea público."
    exit 1
  }
fi

COMMANDS_DIR="$REGISTRY_DIR/commands"
TEMPLATES_DIR="$REGISTRY_DIR/templates"

cleanup() {
  [ -n "$TEMP_REGISTRY" ] && rm -rf "$TEMP_REGISTRY"
}
trap cleanup EXIT

# ── Colores ────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[stdd]${NC} $1"; }
success() { echo -e "${GREEN}[stdd]${NC} ✓ $1"; }
warn()    { echo -e "${YELLOW}[stdd]${NC} ⚠ $1"; }
error()   { echo -e "${RED}[stdd]${NC} ✗ $1"; exit 1; }

# ── Argumentos ─────────────────────────────────────────────────────────────
# Flags
YES_MODE=false
for arg in "$@"; do
  [ "$arg" = "--yes" ] || [ "$arg" = "-y" ] && YES_MODE=true
done

PROJECT_NAME="${1:-}"
ARCHETYPE="${2:-}"
DEST_PATH="${3:-}"

# Limpiar flags de los argumentos posicionales
[[ "$PROJECT_NAME" == --* ]] && PROJECT_NAME=""
[[ "$ARCHETYPE" == --* ]] && ARCHETYPE=""
[[ "$DEST_PATH" == --* ]] && DEST_PATH=""

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  utopia-stdd-registry — init project     ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

# Nombre del proyecto
if [ -z "$PROJECT_NAME" ]; then
  read -rp "Nombre del proyecto (kebab-case): " PROJECT_NAME
fi
if [ -z "$PROJECT_NAME" ]; then
  error "El nombre del proyecto es requerido."
fi

# Archetype
VALID_ARCHETYPES=("webapp-nextjs" "api-fastapi" "fullstack")
if [ -z "$ARCHETYPE" ]; then
  echo "Arquetipos disponibles:"
  echo "  1) webapp-nextjs  — Next.js 14 + Supabase + TypeScript"
  echo "  2) api-fastapi    — FastAPI + PostgreSQL + Python"
  echo "  3) fullstack      — Next.js + FastAPI + Supabase"
  read -rp "Seleccioná (1/2/3): " ARCH_CHOICE
  case "$ARCH_CHOICE" in
    1) ARCHETYPE="webapp-nextjs" ;;
    2) ARCHETYPE="api-fastapi" ;;
    3) ARCHETYPE="fullstack" ;;
    *) error "Opción inválida." ;;
  esac
fi

# Validar archetype
VALID=false
for a in "${VALID_ARCHETYPES[@]}"; do
  [ "$a" = "$ARCHETYPE" ] && VALID=true
done
[ "$VALID" = false ] && error "Archetype '$ARCHETYPE' no válido. Opciones: ${VALID_ARCHETYPES[*]}"

# Destino
if [ -z "$DEST_PATH" ]; then
  DEST_PATH="./$PROJECT_NAME"
fi

# Stack summary según archetype
case "$ARCHETYPE" in
  webapp-nextjs)
    STACK_SUMMARY="Next.js 14+ (App Router) · TypeScript strict · Tailwind CSS · shadcn/ui · Supabase · Zustand · TanStack Query · Vitest · Playwright · Vercel"
    ;;
  api-fastapi)
    STACK_SUMMARY="FastAPI 0.100+ · Python 3.11+ · Pydantic v2 · SQLAlchemy 2.0 · PostgreSQL 15 · Alembic · pytest · Docker · Railway"
    ;;
  fullstack)
    STACK_SUMMARY="Next.js 14+ · FastAPI · TypeScript + Python · Supabase · Tailwind · Vitest + Playwright + pytest"
    ;;
esac

# ── Confirmar ──────────────────────────────────────────────────────────────
echo ""
echo "Configuración:"
echo "  Proyecto:  $PROJECT_NAME"
echo "  Archetype: $ARCHETYPE"
echo "  Stack:     $STACK_SUMMARY"
echo "  Destino:   $DEST_PATH"
echo ""
if [ "$YES_MODE" = false ]; then
  read -rp "¿Confirmar? [s/N] " CONFIRM
  [ "$CONFIRM" != "s" ] && [ "$CONFIRM" != "S" ] && { echo "Cancelado."; exit 0; }
fi

# ── Verificar que el destino no existe ─────────────────────────────────────
if [ -d "$DEST_PATH" ]; then
  if [ "$YES_MODE" = false ]; then
    warn "El directorio '$DEST_PATH' ya existe."
    read -rp "¿Inicializar dentro del directorio existente? [s/N] " OVERWRITE
    [ "$OVERWRITE" != "s" ] && [ "$OVERWRITE" != "S" ] && { echo "Cancelado."; exit 0; }
  else
    info "Proyecto existente — instalando sobre directorio actual."
  fi
fi

# ── Crear estructura ───────────────────────────────────────────────────────
echo ""
info "Creando estructura del proyecto..."

mkdir -p "$DEST_PATH"
mkdir -p "$DEST_PATH/.agent"
mkdir -p "$DEST_PATH/.claude/commands"
mkdir -p "$DEST_PATH/openspec/changes"
mkdir -p "$DEST_PATH/openspec/specs"

# Copiar comandos STDD
info "Instalando comandos STDD..."
cp "$COMMANDS_DIR"/*.md "$DEST_PATH/.claude/commands/"
success "Comandos instalados en .claude/commands/"

# Generar .agent/config.yaml desde template
info "Generando .agent/config.yaml..."
sed \
  -e "s/__REGISTRY_REPO__/tu-org\/utopia-stdd-registry/g" \
  -e "s/__ARCHETYPE__/$ARCHETYPE/g" \
  -e "s/__PROJECT_NAME__/$PROJECT_NAME/g" \
  -e "s/__PROJECT_DESCRIPTION__/Descripción del proyecto — completar/g" \
  "$TEMPLATES_DIR/agent-config.yaml" > "$DEST_PATH/.agent/config.yaml"
success ".agent/config.yaml generado"

# Generar openspec/project.md desde template
info "Generando openspec/project.md..."
sed \
  -e "s/__PROJECT_NAME__/$PROJECT_NAME/g" \
  -e "s/__PROJECT_TYPE__/[$ARCHETYPE]/g" \
  "$TEMPLATES_DIR/project.md" > "$DEST_PATH/openspec/project.md"
success "openspec/project.md generado"

# Generar CLAUDE.md desde template
info "Generando CLAUDE.md..."
sed \
  -e "s/__STACK_SUMMARY__/$STACK_SUMMARY/g" \
  "$TEMPLATES_DIR/CLAUDE.md" > "$DEST_PATH/CLAUDE.md"
success "CLAUDE.md generado"

# Leer archetype.md si existe para info adicional
ARCHETYPE_FILE="$REGISTRY_DIR/archetypes/$ARCHETYPE/archetype.md"
if [ -f "$ARCHETYPE_FILE" ]; then
  cp "$ARCHETYPE_FILE" "$DEST_PATH/openspec/archetype-ref.md"
  success "Referencia del archetype copiada a openspec/archetype-ref.md"
fi

# ── Resumen final ──────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Proyecto inicializado ✓                 ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo "Creado en: $DEST_PATH"
echo ""
echo "Estructura:"
echo "  .agent/config.yaml          ← configuración del registry"
echo "  .claude/commands/           ← comandos STDD (6 comandos)"
echo "  openspec/project.md         ← completar con contexto del proyecto"
echo "  openspec/changes/           ← aquí vivirán los cambios"
echo "  CLAUDE.md                   ← guía para Claude Code"
echo ""
echo -e "${YELLOW}Próximos pasos:${NC}"
echo "  1. cd $DEST_PATH"
echo "  2. Completar openspec/project.md con el contexto real del proyecto"
echo "  3. Abrir Claude Code y ejecutar /stdd-status"
echo "  4. Empezar con /stdd-propose <primer-modulo>"
echo ""
echo "  Registry: $REGISTRY_DIR"
echo "  Archetype: $ARCHETYPE"
echo ""
