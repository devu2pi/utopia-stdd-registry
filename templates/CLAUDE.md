# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Inicio de sesión

**Leer siempre primero:** `openspec/project.md` — es el source of truth del proyecto.

Luego ejecutar `/opsx-status` para ver el estado de los cambios activos.

---

## Stack

__STACK_SUMMARY__

---

## Metodología: OpenSpec tdd-driven

Todo cambio de código sigue este workflow — sin excepciones:

```
/opsx-propose <nombre>   → proponer cambio, esperar aprobación
/opsx-apply <nombre>     → generar spec + design + tasks
/opsx-tdd-plan <nombre>  → definir tests ANTES de implementar
[implementar]            → código + tests en paralelo
/opsx-tdd-verify <nombre>→ verificar que todo pasa
/opsx-archive <nombre>   → solo si tdd:verify = VERIFIED ✓
```

**Reglas duras:**
- Nunca escribir código sin spec aprobada en `openspec/changes/`
- Nunca archivar con tareas `[ ]` incompletas o verify ≠ VERIFIED ✓
- Cada módulo del sistema = un cambio OpenSpec independiente

---

## Comandos disponibles

| Comando | Cuándo usarlo |
|---------|--------------|
| `/opsx-status` | Al iniciar sesión o para ver estado general |
| `/opsx-propose <nombre>` | Para iniciar un nuevo cambio |
| `/opsx-apply <nombre>` | Después de aprobar una proposal |
| `/opsx-tdd-plan <nombre>` | Después de apply, antes de implementar |
| `/opsx-tdd-verify <nombre>` | Después de implementar |
| `/opsx-archive <nombre>` | Al cerrar un cambio verificado |

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
