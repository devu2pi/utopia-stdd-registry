# CHANGELOG — utopia-stdd-registry

Formato de acciones de migración:
- `[context]` — información para el modelo, explica el por qué del cambio
- `[action]` — paso ejecutable concreto
- `[breaking]` — requerido para continuar el workflow; bloquea `/stdd-validate` hasta completarse

---

## [1.1.0] — 2026-06-24

### Qué cambió

Renombramiento completo de prefix `opsx-` a `stdd-` en todos los comandos. El prefix anterior implicaba que los comandos pertenecían a OpenSpec upstream (Fission-AI); `stdd-` refleja que son propios de esta metodología extendida.

### Cambios por componente

- **commands**: todos los comandos renombrados de `opsx-*` a `stdd-*`
- **docs**: landing page actualizada con nuevos nombres
- **scripts/init-project.sh**: actualizado para instalar comandos con prefix `stdd-`

### Acciones de migración

#### [context] Por qué se cambió el prefix
`opsx-` era ambiguo — podía confundirse con comandos del upstream OpenSpec de Fission-AI. `stdd-` (Spec & Testing Driven Development) identifica claramente que son comandos de esta metodología propia.

#### [breaking] Renombrar comandos en `.claude/commands/` del proyecto
Si el proyecto tenía los comandos anteriores instalados:
```bash
cd .claude/commands/
for f in opsx-*.md; do mv "$f" "stdd-${f#opsx-}"; done
```

---

## [1.3.0] — 2026-06-25

### Qué cambió

Agrega el comando `stdd-implement` que cubre la etapa de implementación del workflow STDD.
Hasta esta versión la implementación era una caja negra entre `/stdd-plan` y `/stdd-verify`
— no había trazabilidad ni estado explícito. Este comando formaliza esa etapa.

### Cambios por componente

- **commands**: agrega `stdd-implement.md`
- **registry.json**: versión bumpeada a 1.3.0, `stdd-implement.md` en lista de archivos

### Flujo actualizado

```
/stdd-propose   → crea proposal
/stdd-apply     → genera spec + design + tasks
/stdd-plan      → define tests (estado: TDD_PLANNED)
/stdd-implement → implementa tareas (estado: IN_PROGRESS → IMPLEMENTED)  ← NUEVO
/stdd-verify    → verifica criterios de aceptación
/stdd-archive   → archiva el cambio verificado
```

### Acciones de migración

#### [context] Por qué se agrega este comando
La implementación era la única etapa sin comando propio. Esto impedía trazabilidad del
progreso, no había estado `IN_PROGRESS` en el historial, y no había protocolo claro para
marcar tareas completadas o registrar deuda técnica durante la implementación.

#### [action] Instalar el nuevo comando globalmente
```bash
curl -fsSL https://raw.githubusercontent.com/devu2pi/utopia-stdd-registry/main/commands/stdd-implement.md \
  -o ~/.claude/commands/stdd-implement.md
```

#### [action] Actualizar `registry.version` en `.agent/config.yaml`
Cambiar la versión declarada a `"1.3.0"`.

---

## [1.2.0] — 2026-06-25

### Qué cambió

Redefinición arquitectural: los comandos STDD pasan de vivir en `.claude/commands/` de cada proyecto a instalarse una sola vez a nivel global (`~/.claude/commands/`). Agrega el comando `stdd-validate` para verificar compatibilidad entre proyecto y versión del registry. Agrega documentación de arquitectura y sistema de versionado.

### Cambios por componente

- **commands**: scope cambiado de project a user (`~/.claude/commands/`). Agrega `stdd-validate.md`
- **scripts/init-project.sh**: ya no copia comandos al proyecto; ya no crea `.claude/commands/`
- **registry.json**: `install_path` actualizado a `~/.claude/commands/`, `scope: user`
- **docs/architecture.md**: nuevo — define las tres capas del sistema
- **docs/versioning.md**: nuevo — define el modelo de versionado, CHANGELOG y migraciones

### Acciones de migración

#### [context] Por qué los comandos son globales ahora
Los comandos no tienen lógica project-specific: toda la variación viene de `openspec/project.md` y `.agent/config.yaml`. Tenerlos en cada proyecto generaba duplicados (user + project) y obligaba a actualizarlos en cada proyecto por separado. A nivel global se instalan una vez y están disponibles en cualquier proyecto.

#### [breaking] Eliminar comandos del proyecto si estaban copiados
Si el proyecto tiene `.claude/commands/stdd-*.md`:
```bash
rm .claude/commands/stdd-*.md
# Si la carpeta queda vacía, podés eliminarla también:
rmdir .claude/commands/ 2>/dev/null || true
```

#### [action] Instalar comandos a nivel global
```bash
mkdir -p ~/.claude/commands
curl -fsSL https://raw.githubusercontent.com/devu2pi/utopia-stdd-registry/main/commands/stdd-init.md -o ~/.claude/commands/stdd-init.md
curl -fsSL https://raw.githubusercontent.com/devu2pi/utopia-stdd-registry/main/commands/stdd-status.md -o ~/.claude/commands/stdd-status.md
curl -fsSL https://raw.githubusercontent.com/devu2pi/utopia-stdd-registry/main/commands/stdd-propose.md -o ~/.claude/commands/stdd-propose.md
curl -fsSL https://raw.githubusercontent.com/devu2pi/utopia-stdd-registry/main/commands/stdd-apply.md -o ~/.claude/commands/stdd-apply.md
curl -fsSL https://raw.githubusercontent.com/devu2pi/utopia-stdd-registry/main/commands/stdd-plan.md -o ~/.claude/commands/stdd-plan.md
curl -fsSL https://raw.githubusercontent.com/devu2pi/utopia-stdd-registry/main/commands/stdd-verify.md -o ~/.claude/commands/stdd-verify.md
curl -fsSL https://raw.githubusercontent.com/devu2pi/utopia-stdd-registry/main/commands/stdd-archive.md -o ~/.claude/commands/stdd-archive.md
curl -fsSL https://raw.githubusercontent.com/devu2pi/utopia-stdd-registry/main/commands/stdd-validate.md -o ~/.claude/commands/stdd-validate.md
```

#### [action] Actualizar `registry.version` en `.agent/config.yaml`
Cambiar la versión declarada a `"1.2.0"`.
