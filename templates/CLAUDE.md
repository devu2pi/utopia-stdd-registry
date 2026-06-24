# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Inicio de sesión

**Leer siempre primero:** `openspec/project.md` — es el source of truth del proyecto.

Luego ejecutar `/stdd-status` para ver el estado de los cambios activos.

---

## Stack

__STACK_SUMMARY__

---

## Metodología: OpenSpec tdd-driven

Todo cambio de código sigue este workflow — sin excepciones:

```
/stdd-propose <nombre>   → proponer cambio, esperar aprobación
/stdd-apply <nombre>     → generar spec + design + tasks
/stdd-plan <nombre>  → definir tests ANTES de implementar
[implementar]            → código + tests en paralelo
/stdd-verify <nombre>→ verificar que todo pasa
/stdd-archive <nombre>   → solo si tdd:verify = VERIFIED ✓
```

**Reglas duras:**
- Nunca escribir código sin spec aprobada en `openspec/changes/`
- Nunca archivar con tareas `[ ]` incompletas o verify ≠ VERIFIED ✓
- Cada módulo del sistema = un cambio OpenSpec independiente

---

## Comandos disponibles

| Comando | Cuándo usarlo |
|---------|--------------|
| `/stdd-status` | Al iniciar sesión o para ver estado general |
| `/stdd-propose <nombre>` | Para iniciar un nuevo cambio |
| `/stdd-apply <nombre>` | Después de aprobar una proposal |
| `/stdd-plan <nombre>` | Después de apply, antes de implementar |
| `/stdd-verify <nombre>` | Después de implementar |
| `/stdd-archive <nombre>` | Al cerrar un cambio verificado |

---

## Estructura del proyecto

```
src/                    ← código fuente
tests/
├── unit/               ← Vitest
└── e2e/                ← Playwright
openspec/
├── project.md          ← leer primero siempre
├── specs/              ← specs archivadas (source of truth)
└── changes/            ← cambios activos
    └── <nombre>/
        ├── proposal.md
        ├── spec.md
        ├── design.md
        ├── tasks.md
        └── status.json
.agent/
└── config.yaml         ← skill registry config
.claude/
└── commands/           ← comandos OpenSpec
```
