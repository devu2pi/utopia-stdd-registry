# Versionado del Registry y Migraciones

## Modelo de versiones

El registry tiene una versión propia (`registry.json → version`) que es independiente de las versiones de cada skill o archetype. Esta versión sigue semver:

- **PATCH** (`1.0.x`): correcciones sin cambio de comportamiento (typos, aclaraciones)
- **MINOR** (`1.x.0`): features nuevas, skills nuevas, nuevos archetypes — retrocompatibles
- **MAJOR** (`x.0.0`): cambios breaking: skills renombradas, reglas incompatibles con versiones anteriores, cambio de OpenSpec upstream

La versión de OpenSpec que usa el registry está trackeada en `skills/openspec/upstream.json`. Un bump de OpenSpec upstream implica al menos un MINOR del registry.

---

## Cómo un proyecto apunta al registry

En `.agent/config.yaml` el proyecto declara la versión del registry que consume:

```yaml
registry:
  source: github
  repo: devu2pi/utopia-stdd-registry
  ref: main          # o un tag: "v1.2.0"
  version: "1.1.0"  # versión declarada en el momento del init

skills:
  openspec: "v1"
  tdd-extension: "v1"
  architecture: "v1"
  stack: "v1"
  code-review: "v1"

archetype: webapp-nextjs
```

**El proyecto no se actualiza automáticamente.** Cambiar de versión es una decisión explícita del equipo: se edita `.agent/config.yaml` y se corre `/stdd-validate` para verificar compatibilidad.

---

## CHANGELOG del registry

Cada versión del registry tiene una entrada en `CHANGELOG.md` con tres secciones:

```markdown
## [1.2.0] — 2026-07-01

### Qué cambió
Descripción para humanos: motivación del cambio, qué problema resuelve.

### Cambios por componente
- **skill/stack v2**: reemplaza Axios por fetch nativo + React Query v5
- **archetype/webapp-nextjs v2**: actualiza template de layout a App Router
- **commands**: agrega validación de lock file en stdd-verify

### Acciones de migración
Lista ordenada de acciones requeridas para proyectos que actualicen a esta versión.
Cada acción tiene tipo: `context` (información para el modelo) o `action` (paso ejecutable).

#### [context] Por qué se reemplaza Axios
Axios agrega 40kb al bundle y fetch nativo en Next.js 14+ con React Query v5 
cubre todos los casos de uso. El skill stack/v2 ya no incluye Axios como dependencia aprobada.

#### [action] Reemplazar Axios por fetch + React Query
```bash
npm uninstall axios
npm install @tanstack/react-query@5
```
Luego buscar todos los `import axios` en el proyecto y reemplazar con el patrón
del skill `stack/v2` (ver `skills/stack/v2.md → Fetching de datos`).

#### [action] Actualizar layout principal
Copiar el template `templates/webapp-nextjs/app/layout.tsx` sobre el existente,
preservando customizaciones de `metadata` y `providers`.
```

---

## Formato de acción de migración

Cada acción de migración tiene estructura definida para que el comando `stdd-validate` pueda procesarla:

```
#### [tipo] Título descriptivo
```

Tipos disponibles:
- `[context]` — información para el modelo, sin pasos ejecutables. Explica el por qué.
- `[action]` — paso ejecutable con instrucciones concretas (comandos, ediciones de archivo, búsquedas).
- `[breaking]` — acción requerida para que el proyecto no rompa. Bloquea la validación hasta completarse.

---

## Comando `/stdd-validate`

Verifica que el proyecto cumple con la versión de registry a la que apunta, o detecta gaps si se cambió la versión en `.agent/config.yaml`.

### Cuándo usarlo

- Después de cambiar `version` en `.agent/config.yaml` (upgrade o downgrade)
- Cuando el registry publicó una nueva versión y el equipo decidió adoptarla
- Como health-check periódico para detectar drift entre el proyecto y el registry

### Qué hace

1. Lee `version` en `.agent/config.yaml` (versión declarada por el proyecto)
2. Lee `version` en `registry.json` del registry (versión actual)
3. Lee `CHANGELOG.md` del registry para obtener todas las entradas entre ambas versiones
4. Para cada entrada de migración:
   - Muestra acciones `[context]` como información
   - Verifica acciones `[action]` y `[breaking]` contra el estado actual del proyecto
5. Reporta: qué está cumplido, qué está pendiente, qué es bloqueante

### Output esperado

```
## Validación de versión del registry

Versión declarada en proyecto:  1.1.0
Versión actual del registry:    1.2.0
OpenSpec upstream:              v2 (proyecto usa v1)

### Acciones pendientes (1.1.0 → 1.2.0)

[✓] Axios removido del package.json
[✗] @tanstack/react-query v5 no está instalado  ← BREAKING
[✗] Layout principal no fue actualizado al App Router
[i] Contexto sobre fetch nativo disponible en skills/stack/v2.md

### Resultado: BLOQUEADO — 1 acción breaking pendiente
Resolvé las acciones marcadas con ✗ antes de continuar el workflow.
Ejecutá /stdd-validate nuevamente para confirmar.
```

---

## Relación entre versiones

```
registry v1.1.0
  └── openspec upstream: v1 (Fission-AI/OpenSpec)
  └── skill/openspec: v1
  └── skill/stack: v1  (Axios aprobado)
  └── archetype/webapp-nextjs: v1

registry v1.2.0
  └── openspec upstream: v1 (sin cambio)
  └── skill/stack: v2  (Axios → fetch + React Query)
  └── archetype/webapp-nextjs: v2  (App Router layout)
  └── commands: patch (agrega validación lock file)

registry v2.0.0  [hipotético]
  └── openspec upstream: v2 (breaking upstream)
  └── skill/openspec: v2  (nuevas fases de workflow)
  └── TODOS los proyectos deben ejecutar /stdd-validate
```

---

## Principios de versionado

1. **El proyecto controla cuándo actualiza.** El registry no fuerza upgrades.
2. **El CHANGELOG es el contrato de migración.** Todo cambio breaking debe tener al menos una acción `[breaking]` documentada.
3. **Las acciones `[context]` dan memoria al modelo.** Son el puente entre decisiones del registry y el código del proyecto — sin ellas el modelo no entiende por qué algo cambió.
4. **`stdd-validate` no modifica el proyecto.** Solo reporta. Las acciones las ejecuta el equipo o el modelo bajo supervisión.
5. **Versiones antiguas se deprecan con 30 días de aviso**, documentado en `deprecated` del `registry.json`.
