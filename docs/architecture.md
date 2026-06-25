# Arquitectura STDD Registry

## Visión

El registry es el **marco organizacional** de desarrollo asistido por IA. Define las reglas, el flujo de trabajo, los estándares de código y los patrones por tipo de solución. Los proyectos son **instancias** de ese marco: consumen sus definiciones pero nunca las modifican.

---

## Capas del sistema

```
┌─────────────────────────────────────────────────────────┐
│  CAPA 1 — REGISTRY  (org-level, read-only en runtime)   │
│                                                         │
│  commands/      → orquestan el workflow STDD            │
│  skills/        → reglas inyectadas como contexto IA    │
│  archetypes/    → bundles por tipo de solución          │
│  templates/     → archivos base aplicados al proyecto   │
│  schemas/       → estructura del workflow (tdd-driven)  │
└────────────────────────┬────────────────────────────────┘
                         │ se instala una vez por máquina
                         ▼
┌─────────────────────────────────────────────────────────┐
│  CAPA 2 — MÁQUINA  (user-level, ~/.claude/commands/)    │
│                                                         │
│  stdd-init.md   → bootstrapper global                   │
│  stdd-*.md (6)  → comandos del workflow, disponibles    │
│                   en cualquier proyecto                  │
└────────────────────────┬────────────────────────────────┘
                         │ /stdd-init inicializa
                         ▼
┌─────────────────────────────────────────────────────────┐
│  CAPA 3 — PROYECTO  (project-level, read-write)         │
│                                                         │
│  .agent/config.yaml        → qué skills/archetype usa   │
│  openspec/project.md       → contexto del proyecto      │
│  openspec/changes/<name>/  → trabajo en curso           │
│  openspec/specs/           → specs archivadas           │
│  CLAUDE.md                 → instrucciones del proyecto  │
└─────────────────────────────────────────────────────────┘
```

---

## Responsabilidades por capa

### Registry (Capa 1)

- **Solo lectura** durante el desarrollo de cualquier proyecto
- Fuente de verdad de la metodología, los estándares y las reglas
- Versionado independiente: cambios en el registry no rompen proyectos en curso
- Toda modificación al registry es un cambio en sí mismo, sujeto al mismo flujo STDD

### Máquina / usuario (Capa 2)

- Los **comandos STDD** se instalan una vez a nivel global (`~/.claude/commands/`)
- Disponibles en cualquier proyecto sin configuración adicional
- Se actualizan explícitamente (`stdd-init` o reinstalación manual), no automáticamente
- `stdd-init` es el único comando que puede ejecutarse en un proyecto no inicializado

### Proyecto (Capa 3)

- **Todo el trabajo del workflow ocurre aquí**: proposals, specs, designs, tasks, verificación
- Sigue las reglas del registry pero nunca las modifica
- Los templates del registry se instancian aquí durante `/stdd-init`
- El `CLAUDE.md` del proyecto puede agregar reglas propias, nunca contradicir el registry

---

## Qué instala `/stdd-init` en un proyecto

```
<proyecto>/
├── .agent/
│   └── config.yaml          ← archetype + versiones de skills declaradas
├── .claude/
│   └── (NO comandos — viven en ~/.claude/commands/ a nivel máquina)
├── openspec/
│   ├── project.md           ← contexto del proyecto (completar manualmente)
│   ├── changes/             ← directorio de trabajo del workflow
│   └── specs/               ← specs archivadas post-verificación
└── CLAUDE.md                ← instrucciones + referencia al registry
```

> **Nota:** Los comandos NO se copian al proyecto. Viven a nivel máquina y son genéricos para todos los proyectos.

---

## Skills y archetypes

### Skills

Fragmentos de conocimiento inyectados como contexto en Claude antes de cada interacción. Definen:
- Metodología (`openspec`, `tdd-extension`)
- Estándares de código (`code-review`)
- Patrones arquitecturales (`architecture`)
- Stack tecnológico aprobado (`stack`)

Las skills **no ejecutan código**: son texto que instruye al modelo sobre cómo razonar y qué reglas aplicar.

### Archetypes

Bundles de skills + templates para un tipo de solución. Determinan:
- Qué skills se cargan como contexto
- Qué templates se instancian en el proyecto (estructura de carpetas, configs base)
- Qué reglas de stack aplican (Next.js vs FastAPI vs fullstack)

Un proyecto declara su archetype en `.agent/config.yaml` y no lo cambia.

### Templates

Archivos en `templates/` que el registry provee como punto de partida. Se copian al proyecto durante `/stdd-init` y a partir de ahí son **propiedad del proyecto** — pueden ser modificados para necesidades específicas.

---

## Flujo de trabajo completo

```
[Una vez por máquina]
  Instalar stdd-init en ~/.claude/commands/

[Por proyecto nuevo]
  /stdd-init → detecta contexto → pregunta archetype → ejecuta init-project.sh
             → instancia templates → crea estructura openspec/

[Workflow iterativo — todo en scope proyecto]
  /stdd-propose <nombre>   → crea proposal.md (estado: DRAFT → APPROVED)
  /stdd-apply <nombre>     → genera spec.md + design.md + tasks.md (estado: APPLIED)
  /stdd-plan <nombre>      → define tests antes de implementar (estado: TDD_PLANNED)
  [implementar código]
  /stdd-verify <nombre>    → verifica tests y criterios (estado: TDD_VERIFIED)
  /stdd-archive <nombre>   → mergea spec a openspec/specs/ (estado: ARCHIVED)

[Cuando el equipo decide actualizar la versión del registry]
  Editar .agent/config.yaml → cambiar version
  /stdd-validate            → detecta gap, lee CHANGELOG, reporta acciones pendientes
  [aplicar acciones de migración]
  /stdd-validate            → confirmar que todo está cumplido
```

---

## Separación de concerns: qué vive dónde

| Artefacto | Dónde vive | Quién lo modifica |
|---|---|---|
| Comandos del workflow (`stdd-*.md`) | `~/.claude/commands/` | Registry (actualización explícita) |
| Skills (reglas de contexto IA) | Registry `skills/` | Registry |
| Archetypes | Registry `archetypes/` | Registry |
| Templates base | Registry `templates/` | Registry |
| Archetype declarado por el proyecto | `.agent/config.yaml` | Init (una vez) |
| Contexto del proyecto | `openspec/project.md` | El equipo del proyecto |
| Trabajo en curso | `openspec/changes/` | Workflow STDD |
| Specs archivadas | `openspec/specs/` | `/stdd-archive` |
| Reglas adicionales del proyecto | `CLAUDE.md` | El equipo (nunca contradice registry) |

---

## Versionado

El registry tiene versión semver propia, vinculada a la versión de OpenSpec upstream. Los proyectos declaran la versión en `.agent/config.yaml` y no se actualizan automáticamente.

Ver detalles completos en [versioning.md](versioning.md): formato del CHANGELOG, tipos de acciones de migración (`[context]`, `[action]`, `[breaking]`), y comportamiento del comando `/stdd-validate`.

---

## Principios de diseño

1. **Registry es solo lectura en runtime.** Ningún comando del workflow modifica el registry. Los cambios al registry son un proyecto en sí mismo.

2. **Los comandos son genéricos.** No tienen lógica project-specific. Toda la variación por proyecto viene del contexto (`openspec/project.md`, `.agent/config.yaml`).

3. **Los archetypes manejan la variación por tipo de solución.** El comando `stdd-verify` no sabe si es Next.js o FastAPI — lee `openspec/project.md` para saberlo.

4. **Versionado independiente.** Skills y archetypes tienen versiones propias. Un proyecto puede quedar en `openspec: v1` mientras el registry lanza `v2`, sin romperse.

5. **El proyecto es la unidad de trabajo.** Todo el estado del workflow vive en el proyecto. El registry no guarda estado de ningún proyecto.
