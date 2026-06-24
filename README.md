# skill-registry

Gobierno central de estándares, metodologías y patrones para proyectos de desarrollo asistidos por IA.

Este repo es mantenido por el equipo de Arquitectura. Cualquier cambio impacta todos los proyectos que consuman skills desde aquí.

---

## Qué contiene

```
skill-registry/
├── skills/
│   ├── openspec/          ← metodología SDD base (wrapper de Fission-AI/OpenSpec)
│   ├── tdd-extension/     ← extensión TDD sobre OpenSpec (fases de verificación)
│   ├── code-review/       ← estándares de revisión de código
│   ├── architecture/      ← patrones arquitecturales centrales
│   └── stack/             ← tecnologías aprobadas y configuraciones
├── archetypes/
│   ├── webapp-nextjs/     ← arquetipo SPA/SSR con Next.js + Supabase
│   ├── api-fastapi/       ← arquetipo API REST con FastAPI + PostgreSQL
│   └── fullstack/         ← arquetipo fullstack completo
├── schemas/               ← schemas custom de OpenSpec (TDD, RFC, etc.)
├── docs/                  ← guías de uso e integración
└── registry.json          ← índice central con versiones activas
```

---

## Cómo consumen los proyectos

Cada proyecto declara qué skills necesita en `.agent/config.yaml`:

```yaml
registry:
  source: github
  repo: tu-org/skill-registry
  ref: main          # o un tag: v1.2.0

skills:
  openspec:      "v1"
  tdd-extension: "v1"
  code-review:   "latest"
  architecture:  "v1"
  stack:         "latest"

archetype: webapp-nextjs   # opcional — precarga stack + patterns
```

El servidor o Claude Code lee ese config, fetchea los skills del registry e inyecta el contenido como system prompt antes de cada llamada a la API de Anthropic.

---

## Versionado

- Cada skill tiene versiones independientes (`v1.md`, `v2.md`)
- `latest` apunta siempre a la versión más reciente
- `registry.json` es la fuente de verdad de qué versión es `latest`
- Cambios breaking → nueva versión mayor, deprecar la anterior con aviso de 30 días

---

## Agregar o modificar una skill

1. Crear branch `skill/<nombre>-<version>`
2. Editar o crear el archivo en `skills/<nombre>/`
3. Actualizar `registry.json` si corresponde
4. PR con descripción del cambio y proyectos impactados
5. Merge → propagación automática a proyectos con `latest`

---

## Upstream OpenSpec

La skill `openspec` es un wrapper del repo oficial [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec).

El proceso de sync con upstream:
```bash
# ver versión actual trackeada
cat skills/openspec/upstream.json

# actualizar (manual, requiere revisión humana)
./scripts/sync-openspec.sh
```

Nunca se sobreescribe upstream sin revisión. Los cambios de OpenSpec se mergean a nuestra capa de extensión, no al revés.
