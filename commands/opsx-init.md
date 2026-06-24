Inicializá el proyecto actual con la metodología utopia-stdd-registry.

## Qué hacer

### 1. Detectar contexto

Leé el directorio de trabajo actual:
- Si existe `.claude/commands/opsx-status.md` → el proyecto YA está inicializado. Informar: "Este proyecto ya tiene el registry instalado. Ejecutá /opsx-status para ver el estado actual." y detener.
- Si existe `openspec/project.md` con contenido real (no solo placeholders) → proyecto existente con documentación parcial.
- Si no existe nada → proyecto nuevo.

### 2. Preguntar el archetype si no está definido

Si no existe `.agent/config.yaml`, preguntá:

"¿Qué archetype usamos para este proyecto?
1. webapp-nextjs — Next.js 14 + Supabase + TypeScript
2. api-fastapi   — FastAPI + PostgreSQL + Python
3. fullstack     — Next.js + FastAPI + Supabase"

Esperá la respuesta antes de continuar.

### 3. Ejecutar el script de inicialización

Con el archetype confirmado, ejecutá:

```bash
curl -fsSL https://raw.githubusercontent.com/devu2pi/utopia-stdd-registry/main/scripts/init-project.sh | bash -s -- "$(basename $(pwd))" <archetype> .
```

Si el comando falla, mostrá el error y sugerí verificar conexión a internet o acceso a github.com/devu2pi/utopia-stdd-registry.

### 4. Verificar resultado

Después de que el script termine, verificá que existan:
- `.agent/config.yaml`
- `.claude/commands/opsx-status.md`
- `openspec/project.md`
- `CLAUDE.md`

Si alguno falta, reportá cuál y por qué pudo fallar.

### 5. Para proyectos existentes: no pisar archivos con contenido

Si alguno de los archivos anteriores YA existía antes del init con contenido real (no template), avisá al usuario cuáles se preservaron y cuáles se actualizaron.

### 6. Mostrar resumen y próximos pasos

```
## ✓ Proyecto inicializado con utopia-stdd-registry

Registry: github.com/devu2pi/utopia-stdd-registry
Archetype: <archetype>
Comandos instalados: /opsx-status, /opsx-propose, /opsx-apply,
                     /opsx-tdd-plan, /opsx-tdd-verify, /opsx-archive

Próximos pasos:
  1. Completá openspec/project.md con el contexto real del proyecto
  2. Ejecutá /opsx-status para ver el estado inicial
  3. Cuando estés listo: /opsx-propose <nombre-del-primer-modulo>
```
