#!/usr/bin/env bash
set -euo pipefail

REGISTRY_BASE="https://raw.githubusercontent.com/devu2pi/utopia-stdd-registry/main"
INSTALL_DIR="${HOME}/.claude/commands"

echo "Obteniendo versión actual del registry..."
REGISTRY_JSON=$(curl -fsSL "${REGISTRY_BASE}/registry.json")

VERSION=$(echo "$REGISTRY_JSON" | grep '"version"' | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')
FILES=$(echo "$REGISTRY_JSON" | grep -oE '"stdd-[^"]+\.md"' | tr -d '"')

echo "Versión: ${VERSION}"
echo "Destino: ${INSTALL_DIR}"
echo ""

mkdir -p "$INSTALL_DIR"

for file in $FILES; do
  echo "  ↓ ${file}"
  curl -fsSL "${REGISTRY_BASE}/commands/${file}" -o "${INSTALL_DIR}/${file}"
done

echo ""
echo "✓ ${VERSION} instalada en ${INSTALL_DIR}"
echo ""
echo "Para actualizar en el futuro usá /stdd-upgrade desde cualquier proyecto."
