# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This is the central skill registry for AI-assisted development projects. It defines skills (methodology docs injected as system prompts), archetypes (project templates bundling skills), and schemas (workflow variants). Changes here propagate to all consuming projects.

## Repository structure

- `skills/<name>/v1.md` — skill content injected into AI system prompts
- `skills/openspec/upstream.json` — tracks the upstream OpenSpec version
- `archetypes/<name>/archetype.md` — project template bundling a set of skills
- `schemas/tdd-driven.yaml` — custom workflow schema extending OpenSpec with TDD phases
- `commands/*.md` — Claude Code slash commands implementing the OpenSpec workflow; copied to `.claude/commands/` in each project
- `templates/` — base files copied by `init-project.sh` (CLAUDE.md, project.md, agent-config.yaml)
- `registry.json` — source of truth for latest versions and supported skill list
- `scripts/init-project.sh` — bootstraps a new project with the full methodology
- `scripts/sync-openspec.sh` — manual upstream sync tool

## Key rules

**Versioning:** Skills use independent versioning (`v1.md`, `v2.md`). `registry.json` defines what `latest` resolves to. Breaking changes require a new major version; the old one must be deprecated with 30 days notice. Update `registry.json` when adding or promoting a version.

**Inicializar un proyecto nuevo:**
```bash
./scripts/init-project.sh <nombre> [archetype] [ruta-destino]
# Ejemplo:
./scripts/init-project.sh mi-app webapp-nextjs
```
Esto crea la estructura completa: `.agent/config.yaml`, `.claude/commands/` con los 6 comandos OpenSpec, `openspec/project.md`, y `CLAUDE.md`.

**Agregar comandos a un proyecto existente:**
```bash
cp commands/*.md <proyecto>/.claude/commands/
```

**OpenSpec upstream:** `skills/openspec/v1.md` wraps [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec). Never overwrite it without human review. To check and update the upstream reference:
```bash
cat skills/openspec/upstream.json
./scripts/sync-openspec.sh   # requires gh CLI and node
```

**Branch convention:** `skill/<name>-<version>` for skill changes.

## How consuming projects integrate

Projects declare dependencies in `.agent/config.yaml`:
```yaml
registry:
  source: github
  repo: tu-org/skill-registry
  ref: main

skills:
  openspec: "v1"
  tdd-extension: "v1"
archetype: webapp-nextjs
```

The runtime fetches skill `.md` files and injects them as system prompt context before each API call.

## TDD workflow (tdd-driven schema)

Phases in order: `proposal` → `spec` → `design` → `tdd:plan` → `tasks` → `tdd:verify` → `archive`

Hard gates:
- Do not advance to implementation without a complete `tdd:plan`
- Do not archive without `tdd:verify = VERIFIED ✓`

Commands: `/stdd-propose`, `/stdd-apply`, `/stdd-plan`, `/stdd-verify`, `/stdd-archive`
