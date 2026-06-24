#!/bin/bash
# scripts/sync-openspec.sh
# Sincroniza la referencia upstream de OpenSpec con el registry
# Uso: ./scripts/sync-openspec.sh
# Requiere: gh CLI, node

set -euo pipefail

UPSTREAM_REPO="Fission-AI/OpenSpec"
SKILLS_DIR="skills/openspec"
UPSTREAM_FILE="$SKILLS_DIR/upstream.json"

echo "=== Sync OpenSpec upstream ==="
echo ""

# Verificar versión actual
CURRENT=$(node -e "const f=require('./$UPSTREAM_FILE'); console.log(f.tracked_version)")
echo "Versión trackeada actualmente: $CURRENT"

# Verificar última versión en npm
LATEST=$(npm view @fission-ai/openspec version 2>/dev/null || echo "no-encontrado")
echo "Última versión en npm: $LATEST"

if [ "$LATEST" = "no-encontrado" ]; then
  echo ""
  echo "⚠️  No se pudo verificar la versión de npm."
  echo "   Verificar manualmente: https://github.com/$UPSTREAM_REPO/releases"
  exit 1
fi

echo ""
echo "¿Actualizar referencia upstream a $LATEST? [s/N]"
read -r respuesta

if [ "$respuesta" != "s" ] && [ "$respuesta" != "S" ]; then
  echo "Cancelado."
  exit 0
fi

# Actualizar upstream.json
node -e "
const fs = require('fs');
const f = require('./$UPSTREAM_FILE');
f.tracked_version = '$LATEST';
f.last_synced = new Date().toISOString().split('T')[0];
fs.writeFileSync('./$UPSTREAM_FILE', JSON.stringify(f, null, 2) + '\n');
console.log('upstream.json actualizado.');
"

echo ""
echo "✓ Referencia actualizada a $LATEST"
echo ""
echo "Próximos pasos manuales:"
echo "  1. Revisar CHANGELOG de OpenSpec: https://github.com/$UPSTREAM_REPO/releases"
echo "  2. Actualizar skills/openspec/v1.md si hay cambios de workflow relevantes"
echo "  3. Evaluar si se necesita skills/openspec/v2.md (breaking changes)"
echo "  4. Commit: git commit -am 'chore(openspec): sync upstream to $LATEST'"
